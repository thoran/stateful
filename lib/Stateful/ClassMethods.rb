# Stateful/ClassMethods.rb
# Stateful::ClassMethods

require_relative 'StateMachine'

module Stateful
  module ClassMethods
    def state_machines
      @state_machines ||= {}
    end

    def stateful_state_machine(machine_name = nil)
      if machine_name
        state_machines[machine_name] ||= Stateful::StateMachine.new(self, machine_name: machine_name)
      else
        @stateful_state_machine ||= Stateful::StateMachine.new(self)
      end
    end

    # start DSL

    def stateful(options = {}, &block)
      stateful_state_machine.options = options unless options.empty?
      class_eval(&block) if block
    end

    def state_machine(name, options = {}, &block)
      unless state_machines.key?(name)
        define_named_machine_methods(name)
      end
      sm = stateful_state_machine(name)
      sm.options = options unless options.empty?
      sm.instance_eval(&block) if block
    end

    def initial_state(state_name = nil, options = {}, &block)
      stateful_state_machine.initial_state(state_name, options, &block)
    end

    def state(state_name, options = {}, &block)
      stateful_state_machine.state(state_name, options, &block)
    end

    def final_state(*state_names)
      stateful_state_machine.final_state(*state_names)
    end

    def final_states(*state_names)
      stateful_state_machine.final_states(*state_names)
    end

    # end DSL

    # predicate methods

    def final_state?
      if state_machines.empty?
        !final_states.empty?
      else
        state_machines.all?{|_name, states| !states.final_states.empty?}
      end
    end
    alias_method :has_final_state?, :final_state?
  end
end
