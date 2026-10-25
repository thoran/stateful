# Stateful/InvalidTransition.rb
# Stateful::InvalidTransition

module Stateful
  class InvalidTransition < StandardError
    attr_reader :event_name
    attr_reader :state_name

    def initialize(event_name, state_name)
      @event_name, @state_name = event_name, state_name
      super("no transition for #{event_name.inspect} from #{state_name.inspect}")
    end
  end
end
