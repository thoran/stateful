# Stateful

## Description

A Ruby state machine which allows you to easily add state to Poro and ActiveRecord objects.

## Installation

Add this line to your application's Gemfile:
```ruby
gem 'stateful.rb'
```
And then execute:
```shell
$ bundle
```
Or install it yourself as:
```shell
$ gem install stateful.rb
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

### 2. Poro with persistence non-specific extend (it just works it out), without a stateful block declaration, an initial_state block, and multiple final states

```ruby
class PoroMachine
  extend Stateful

  initial_state :initial_state do
    on :an_event => :next_state
    on :another_event => :final_state
  end

  state :next_state do
    on :yet_another_event => :final_state1
  end

  final_state :final_state0, :final_state1
end

poro_machine = PoroMachine.new
poro_machine.state.name
# => :initial_state
poro_machine.an_event
poro_machine.state.name
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

### 4. ActiveRecord with persistence non-specific extend (it just works it out), without a stateful block declaration, an initial_state block, and multiple final states

```ruby
class ActiveRecordMachine < ActiveRecord::Base
  extend Stateful

  initial_state :initial_state do
    on :an_event => :next_state
    on :another_event => :final_state
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

### 5. It's also possible to define a state machine (either Poro or ActiveRecord) which has a custom variable (Poro) or column (ActiveRecord) name, which fires off the events in a random or non-deterministic order, and which has no final state
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

## Contributing

1. Fork it: https://github.com/thoran/Stateful/fork
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create a new pull request
