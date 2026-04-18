# Stateful/Sequel/ClassMethods.rb
# Stateful::Sequel::ClassMethods

module Stateful
  module Sequel
    module ClassMethods
      class << self
        def extended(klass)
          klass.define_stateful_column_name_setter_method
          klass.define_stateful_column_name_getter_method
          klass.define_next_state_method
          klass.define_transitions_method
          klass.define_initial_stateQ_method
          klass.define_final_stateQ_method
        end
      end # class << self

      def define_named_machine_methods(machine_name)
        define_stateful_column_name_setter_method(machine_name: machine_name)
        define_stateful_column_name_getter_method(machine_name: machine_name)
        define_next_state_method(machine_name: machine_name)
        define_transitions_method(machine_name: machine_name)
        define_initial_stateQ_method(machine_name: machine_name)
        define_final_stateQ_method(machine_name: machine_name)
      end

      def stateful_column_name=(stateful_column_name)
        @stateful_column_name = stateful_column_name
      end

      def stateful_column_name
        @stateful_column_name
      end

      def column_name_for_machine(machine_name = nil)
        if machine_name
          "#{machine_name}_state"
        else
          instance_variable_get(:@stateful_column_name)
        end
      end

      def define_event_method(transition, machine_name: nil)
        stateful_column_name = column_name_for_machine(machine_name)
        define_method(transition.event_name) do
          next_state_name = self.send(stateful_column_name).next_state_name(transition.event_name)
          next_state = self.class.stateful_state_machine(machine_name).find(next_state_name)
          self.send("#{stateful_column_name}=", next_state)
        end
      end

      def define_status_predicate_method(state_name, machine_name: nil)
        stateful_column_name = column_name_for_machine(machine_name)
        define_method("#{state_name}?") do
          self.send(stateful_column_name).name == state_name
        end
      end

      def define_stateful_column_name_setter_method(machine_name: nil)
        stateful_column_name = column_name_for_machine(machine_name)
        define_method("#{stateful_column_name}=") do |state|
          instance_variable_set("@#{stateful_column_name}", self.class.stateful_state_machine(machine_name).find(state))
          self[stateful_column_name.to_sym] = instance_variable_get("@#{stateful_column_name}").name.to_s
          self.save
          instance_variable_get("@#{stateful_column_name}")
        end
      end

      def define_stateful_column_name_getter_method(machine_name: nil)
        stateful_column_name = column_name_for_machine(machine_name)
        define_method(stateful_column_name) do
          instance_variable_set("@#{stateful_column_name}", self.class.stateful_state_machine(machine_name).find(self[stateful_column_name.to_sym]))
          if state = instance_variable_get("@#{stateful_column_name}")
            state
          else
            initial_state = self.class.stateful_state_machine(machine_name).initial_state
            self.send("#{stateful_column_name}=", initial_state.name)
            initial_state
          end
        end
      end

      def define_next_state_method(machine_name: nil)
        stateful_column_name = column_name_for_machine(machine_name)
        method_name = machine_name ? "#{machine_name}_next_state" : :next_state
        define_method(method_name) do |event_name|
          next_state_name = self.send(stateful_column_name).next_state_name(event_name)
          self.class.stateful_state_machine(machine_name).find(next_state_name)
        end
      end

      def define_transitions_method(machine_name: nil)
        stateful_column_name = column_name_for_machine(machine_name)
        method_name = machine_name ? "#{machine_name}_transitions" : :transitions
        define_method(method_name) do
          self.send(stateful_column_name).transitions
        end
      end

      def define_initial_stateQ_method(machine_name: nil)
        stateful_column_name = column_name_for_machine(machine_name)
        method_name = machine_name ? "#{machine_name}_initial_state?" : :initial_state?
        define_method(method_name) do
          self.send(stateful_column_name) == self.class.stateful_state_machine(machine_name).initial_state
        end
      end

      def define_final_stateQ_method(machine_name: nil)
        stateful_column_name = column_name_for_machine(machine_name)
        method_name = machine_name ? "#{machine_name}_final_state?" : :final_state?
        define_method(method_name) do
          self.class.stateful_state_machine(machine_name).final_states.include?(self.send(stateful_column_name))
        end
      end
    end
  end
end
