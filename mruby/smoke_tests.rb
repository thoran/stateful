# mruby/smoke_tests.rb
# Smoke tests for mRuby compatibility.

# Run with: ./test_mruby-stateful

# --- Test helpers ---

def assert(description, &block)
  if block.call
    puts "  PASS: #{description}"
  else
    puts "  FAIL: #{description}"
    $failure_count += 1
  end
  $test_count += 1
end

$test_count = 0
$failure_count = 0

# --- 1. Module#extended hook ---

puts "1. Module#extended hook"

class ExtendedTest
  extend Stateful
end

assert("extended hook wires up Stateful::ClassMethods"){ExtendedTest.respond_to?(:stateful_state_machine)}
assert("extended hook wires up Stateful::Poro::ClassMethods"){ExtendedTest.respond_to?(:define_event_method)}
assert("extended hook wires up Stateful::InstanceMethods"){ExtendedTest.method_defined?(:active?)}

# --- 2. Single state machine ---

puts
puts "2. Single state machine"

class TrafficLight
  extend Stateful

  initial_state :green do
    on :timer => :yellow
  end

  state :yellow do
    on :timer => :red
  end

  state :red do
    on :timer => :green
  end
end

light = TrafficLight.new

assert("starts in initial state"){light.initial_state?}
assert("initial state name is :green"){light.current_state.name == :green}
assert("green? predicate"){light.green?}
assert("not yellow?"){!light.yellow?}
assert("has transitions"){light.transitions.size == 1}
assert("next_state for :timer is yellow"){light.next_state(:timer).name == :yellow}

light.timer
assert("after timer: now yellow"){light.yellow?}
assert("no longer initial state"){!light.initial_state?}

light.timer
assert("after second timer: now red"){light.red?}

light.timer
assert("after third timer: back to green"){light.green?}

# --- 3. Final states ---

puts
puts "3. Final states"

class Order
  extend Stateful

  initial_state :pending do
    on :confirm => :confirmed
    on :cancel => :cancelled
  end

  state :confirmed do
    on :ship => :shipped
  end

  final_states :shipped, :cancelled
end

order = Order.new

assert("starts pending"){order.pending?}
assert("is active"){order.active?}
assert("not in final state"){!order.final_state?}
assert("class knows it has final states"){Order.final_state?}

order.confirm
assert("now confirmed"){order.confirmed?}
assert("still active"){order.active?}
assert("still not in final state"){!order.final_state?}

order.ship
assert("now shipped"){order.shipped?}
assert("in final state"){order.final_state?}
assert("no longer active"){!order.active?}
assert("no transitions from final state"){order.transitions.empty?}

cancelled_order = Order.new
cancelled_order.cancel
assert("cancelled order is in final state"){cancelled_order.final_state?}
assert("cancelled order is not active"){!cancelled_order.active?}

# --- 4. Multiple state machines ---

puts
puts "4. Multiple state machines"

class Purchase
  extend Stateful

  state_machine :fulfilment do
    initial_state :pending do
      on :collect => :ready
    end

    state :ready do
      on :dispatch => :dispatched
    end

    final_state :dispatched
  end

  state_machine :payment do
    initial_state :unpaid do
      on :pay => :paid
    end

    state :paid do
      on :refund => :refunded
    end

    final_state :refunded
  end
end

purchase = Purchase.new

assert("fulfilment starts pending"){purchase.fulfilment_state.name == :pending}
assert("payment starts unpaid"){purchase.payment_state.name == :unpaid}
assert("pending? predicate"){purchase.pending?}
assert("unpaid? predicate"){purchase.unpaid?}
assert("fulfilment initial state"){purchase.fulfilment_initial_state?}
assert("payment initial state"){purchase.payment_initial_state?}
assert("active overall"){purchase.active?}

purchase.pay
assert("payment advanced to paid"){purchase.paid?}
assert("fulfilment unchanged"){purchase.pending?}
assert("active?(specific) for fulfilment"){purchase.active?(:fulfilment)}
assert("active?(specific) for payment"){purchase.active?(:payment)}

purchase.collect
purchase.dispatch
assert("fulfilment now dispatched"){purchase.dispatched?}
assert("fulfilment in final state"){purchase.fulfilment_final_state?}
assert("still active overall (payment not final)"){purchase.active?}
assert("fulfilment no longer active"){!purchase.active?(:fulfilment)}

purchase.refund
assert("payment now refunded"){purchase.refunded?}
assert("no longer active overall"){!purchase.active?}

# --- 5. Custom variable name ---

puts
puts "5. Custom variable name"

class Job
  @stateful_variable_name = 'status'

  extend Stateful

  initial_state :queued do
    on :start => :running
  end

  state :running do
    on :finish => :done
  end

  final_state :done
end

job = Job.new

assert("responds to custom variable name"){job.respond_to?(:status)}
assert("status returns initial state"){job.status.name == :queued}

job.start
assert("status reflects transition"){job.status.name == :running}

job.finish
assert("status reflects final state"){job.status.name == :done}
assert("final_state? works with custom variable"){job.final_state?}

# --- Summary ---

puts
if $failure_count == 0
  puts "All #{$test_count} tests passed."
else
  puts "#{$failure_count} of #{$test_count} tests FAILED."
end
