# Stateful/State.rb
# Stateful::State

require_relative 'Transition'

module Stateful
  class State
    attr_accessor :name
    attr_accessor :transitions

    def initialize(name, options = {})
      @name = name
      @options = options
      @transitions = []
    end

    def event(event)
      event_name, new_state = event.keys.first, event.values.first
      transitions << Transition.new(event_name, new_state)
      transitions.shuffle! if non_deterministic_event_ordering?
      transitions
    end
    alias_method :on, :event

    def next_state_name(event_name)
      if matching_transition = transitions.detect{|transition| transition.event_name == event_name}
        matching_transition.next_state_name
      end
    end

    private

    def non_deterministic_event_ordering?
      @options[:non_deterministic_event_ordering] ||
        @options[:non_deterministic] ||
        (@options.key?(:deterministic) && !@options[:deterministic])
    end
  end
end
