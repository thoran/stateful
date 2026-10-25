# Stateful/ClassMethods.rb
# Stateful::ClassMethods

require_relative './InvalidTransition'
require_relative './StateMachine'

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

    # adapter methods

    def define_named_machine_methods(machine_name)
      define_stateful_attribute_setter_method(machine_name: machine_name)
      define_stateful_attribute_getter_method(machine_name: machine_name)
      define_next_state_method(machine_name: machine_name)
      define_transitions_method(machine_name: machine_name)
      define_initial_stateQ_method(machine_name: machine_name)
      define_final_stateQ_method(machine_name: machine_name)
    end

    def define_event_method(transition, machine_name: nil)
      attribute_name = stateful_attribute_name_for_machine(machine_name)
      define_method(transition.event_name) do
        current_state = self.send(attribute_name)
        next_state_name = current_state.next_state_name(transition.event_name)
        raise Stateful::InvalidTransition.new(transition.event_name, current_state.name) unless next_state_name
        next_state = self.class.stateful_state_machine(machine_name).find(next_state_name)
        self.send("#{attribute_name}=", next_state)
      end
    end

    def define_status_predicate_method(state_name, machine_name: nil)
      attribute_name = stateful_attribute_name_for_machine(machine_name)
      define_method("#{state_name}?") do
        self.send(attribute_name).name == state_name
      end
    end

    def define_next_state_method(machine_name: nil)
      attribute_name = stateful_attribute_name_for_machine(machine_name)
      method_name = machine_name ? "#{machine_name}_next_state" : :next_state
      define_method(method_name) do |event_name|
        next_state_name = self.send(attribute_name).next_state_name(event_name)
        self.class.stateful_state_machine(machine_name).find(next_state_name)
      end
    end

    def define_transitions_method(machine_name: nil)
      attribute_name = stateful_attribute_name_for_machine(machine_name)
      method_name = machine_name ? "#{machine_name}_transitions" : :transitions
      define_method(method_name) do
        self.send(attribute_name).transitions
      end
    end

    def define_initial_stateQ_method(machine_name: nil)
      attribute_name = stateful_attribute_name_for_machine(machine_name)
      method_name = machine_name ? "#{machine_name}_initial_state?" : :initial_state?
      define_method(method_name) do
        self.send(attribute_name) == self.class.stateful_state_machine(machine_name).initial_state
      end
    end

    def define_final_stateQ_method(machine_name: nil)
      attribute_name = stateful_attribute_name_for_machine(machine_name)
      method_name = machine_name ? "#{machine_name}_final_state?" : :final_state?
      define_method(method_name) do
        self.class.stateful_state_machine(machine_name).final_states.include?(self.send(attribute_name))
      end
    end

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
