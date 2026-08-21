# Stateful

## Description

A Ruby state machine which allows you to easily add state to Poro, ActiveRecord, and Sequel objects. Works with both CRuby and mRuby.

## Installation

### CRuby

Add this line to your application's Gemfile:

```ruby
gem 'stateful.rb'
```

And then execute:

```shell
$ bundle install
```

Or install it yourself as:

```shell
$ gem install stateful.rb
```

### mRuby

Add this to your `build_config.rb`:

```ruby
conf.gem github: 'thoran/stateful'
```

## Usage

### 1. Poro with persistence-specific extend and a stateful block declaration

```ruby
class PoroMachine
  extend Stateful::Poro

  stateful do
    initial_state :initial_state

    state :initial_state do
      on :an_event => :next_state
      on :another_event => :final_state
    end

    state :next_state do
      on :yet_another_event => :final_state
    end

    final_state :final_state
  end
end

poro_machine = PoroMachine.new
poro_machine.initial_state.name
# => :initial_state
poro_machine.final_state.name
# => :final_state
```

### 2. Poro with persistence non-specific extend, without a stateful block declaration, an initial_state block, and multiple final states

```ruby
class PoroMachine
  extend Stateful

  initial_state :initial_state do
    on :an_event => :next_state
    on :another_event => :final_state0
  end

  state :next_state do
    on :yet_another_event => :final_state1
  end

  final_state :final_state0, :final_state1
end

poro_machine = PoroMachine.new
poro_machine.current_state.name
# => :initial_state
poro_machine.an_event
poro_machine.current_state.name
# => :next_state
```

### 3. ActiveRecord with persistence-specific extend and a stateful block declaration

```ruby
class ActiveRecordMachine < ActiveRecord::Base
  extend Stateful::ActiveRecord

  stateful do
    initial_state :initial_state

    state :initial_state do
      on :an_event => :next_state
      on :another_event => :final_state
    end

    state :next_state do
      on :yet_another_event => :final_state
    end

    final_state :final_state
  end
end

active_record_machine = ActiveRecordMachine.new
active_record_machine.initial_state?
# => true
active_record_machine.an_event
active_record_machine.next_state?
# => true
```

### 4. ActiveRecord with persistence non-specific extend, without a stateful block declaration, an initial_state block, and multiple final states

```ruby
class ActiveRecordMachine < ActiveRecord::Base
  extend Stateful

  initial_state :initial_state do
    on :an_event => :next_state
    on :another_event => :final_state0
  end

  state :next_state do
    on :yet_another_event => :final_state0
    on :and_yet_another_event => :final_state1
  end

  final_state :final_state0, :final_state1
end

active_record_machine = ActiveRecordMachine.new
active_record_machine.an_event
active_record_machine.final_state?
# => false
active_record_machine.yet_another_event
active_record_machine.final_state?
# => true
```

### 5. Sequel with persistence-specific extend and a stateful block declaration

```ruby
class SequelMachine < Sequel::Model
  extend Stateful::Sequel

  stateful do
    initial_state :initial_state

    state :initial_state do
      on :an_event => :next_state
      on :another_event => :final_state
    end

    state :next_state do
      on :yet_another_event => :final_state
    end

    final_state :final_state
  end
end

sequel_machine = SequelMachine.create
sequel_machine.initial_state?
# => true
sequel_machine.an_event
sequel_machine.next_state?
# => true
```

### 6. Sequel with persistence non-specific extend, without a stateful block declaration, an initial_state block, and multiple final states

```ruby
class SequelMachine < Sequel::Model
  extend Stateful

  initial_state :initial_state do
    on :an_event => :next_state
    on :another_event => :final_state0
  end

  state :next_state do
    on :yet_another_event => :final_state0
    on :and_yet_another_event => :final_state1
  end

  final_state :final_state0, :final_state1
end

sequel_machine = SequelMachine.create
sequel_machine.an_event
sequel_machine.final_state?
# => false
sequel_machine.yet_another_event
sequel_machine.final_state?
# => true
```

### 7. Custom attribute name and non-deterministic event ordering

It's also possible to define a state machine which has a custom attribute name, which fires off the events in a random or non-deterministic order, and which has no final state.

```ruby
class ActiveRecordMachine < ActiveRecord::Base

  @stateful_column_name = 'status' # This needs to be set before the class is extended. The default is 'current_state'.

  extend Stateful

  initial_state :initial_state, non_deterministic: true do
    on :an_event => :another_state
    on :another_event => :yet_another_state
  end

  state :another_state do
    on :another_event => :yet_another_state
  end

  state :yet_another_state do
    on :yet_another_event => :another_state
  end
end

active_record_machine = ActiveRecordMachine.new
# Supposing that both :an_event or :another_event messages are able to fire, then if the order of the evaluation of the transitions is non-deterministic, then the state change is also.  Non-deterministic event ordering really only makes sense in the context of the sibling library thoran/Eventful, which will evaluate the transitions automatically and will do so in the order as presented by Stateful.
active_record_machine.another_event # With non-deterministic event firing it could check for :another_event before checking :an_event.
active_record_machine.current_state.name
# => :yet_another_state
active_record_machine.an_event
active_record_machine.current_state.name
# => :yet_another_state
active_record_machine.final_state?
# => false
active_record_machine.yet_another_event
active_record_machine.final_state?
# => false
```

### 8. Multiple state machines per class

A single class can have multiple independent (orthogonal) state machines. Each machine gets its own namespaced methods, while domain predicates and event methods remain unnamespaced.

```ruby
class Order
  extend Stateful

  state_machine :fulfilment do
    initial_state :pending do
      on :items_collected => :ready
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

order = Order.new

order.fulfilment_state.name # state accessors are namespaced.
# => :pending
order.payment_state.name
# => :unpaid

order.fulfilment_initial_state? # General/overlapping predicates are namespaced.
# => true
order.payment_final_state?
# => false

order.fulfilment_transitions.first.event_name # Transitions are namespaced.
# => :items_collected

order.pending? # Domain predicates are not namespaced.
# => true
order.unpaid?
# => true

order.pay # Event methods are not namespaced.
order.paid?
# => true

# State machines are orthogonal
order.fulfilment_initial_state?
# => true
```

Multiple state machines can also be declared inside a stateful block:

```ruby
class Order
  extend Stateful

  stateful do
    state_machine :fulfilment do
      initial_state :pending do
        on :items_collected => :ready
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
end
```

For ActiveRecord and Sequel, each machine uses a column named `<machine_name>_state`:

```ruby
class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.string :fulfilment_state
      t.string :payment_state
    end
  end
end
```

For Poro, each machine uses an instance variable named `@<machine_name>_state`.

## Contributing

1. Fork it: https://github.com/thoran/Stateful/fork
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create a new pull request


## License

MIT
