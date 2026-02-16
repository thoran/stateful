# Stateful/States.rb
# Stateful::States

require_relative 'State'

module Stateful
  class States

    attr_reader :all

    def initialize(klass, options = {})
      @klass = klass
      @options = options
      @all = []
      @initial_state = nil
      @final_states = []
    end

    def detect(candidate_state)
      candidate_state_name = (
        if candidate_state.is_a?(State)
          candidate_state.name
        else
          candidate_state && candidate_state.to_sym
        end
      )
      self.all.detect{|state| state.name == candidate_state_name}
    end
    alias_method :find, :detect

    def missing?(state)
      !detect(state)
    end
    alias_method :new_state?, :missing?

    def present?(state)
      !!detect(state)
    end

    def find_or_create(state_name, options = {})
      find(state_name) || (
        state = State.new(state_name, options)
        all << state
        state
      )
    end

    def initial_state(state_name = nil, options = {}, &block)
      if state_name
        @initial_state = state(state_name, options, &block)
      else
        @initial_state
      end
    end

    def final_state(*state_names)
      final_states(*state_names).first
    end
    alias_method :final_state=, :final_state

    def final_states(*state_names)
      state_names = state_names.flatten
      if !state_names.empty?
        state_names.each do |state_name|
          final_state = State.new(state_name)
          @final_states << final_state
          all << final_state
        end
        @final_states
      else
        @final_states
      end
    end

    def state(state_name, options = {}, &block)
      options.merge!(non_deterministic_event_ordering: global_non_deterministic_event_ordering?)
      state = find_or_create(state_name, options)
      state.instance_eval(&block) if block
      state.transitions.each do |transition|
        @klass.define_event_method(transition)
      end
      @klass.define_status_predicate_method(state_name)
      state
    end

    def stateful(options = {}, &block)
      @options = options
      instance_eval(&block) if block
    end

    private

    def global_non_deterministic_event_ordering?
      @options[:global_non_deterministic_event_ordering] ||
        @options[:non_deterministic_event_ordering] ||
        @options[:non_deterministic] ||
        (@options.key?(:deterministic) && !@options[:deterministic])
    end

  end
end
