# Stateful/Transition.rb
# Stateful::Transition

module Stateful
  class Transition
    attr_reader :event_name
    attr_reader :next_state_name

    def initialize(event_name, next_state_name)
      @event_name, @next_state_name = event_name, next_state_name
    end
  end
end
