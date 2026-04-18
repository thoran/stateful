# Stateful/Poro/ClassMethods.rb
# Stateful::Poro::ClassMethods

module Stateful
  module Poro
    module ClassMethods
      class << self
        def extended(klass)
          klass.define_stateful_attribute_setter_method
          klass.define_stateful_attribute_getter_method
          klass.define_next_state_method
          klass.define_transitions_method
          klass.define_initial_stateQ_method
          klass.define_final_stateQ_method
        end
      end # class << self

      def stateful_variable_name=(stateful_variable_name)
        @stateful_variable_name = stateful_variable_name
      end

      def stateful_variable_name
        @stateful_variable_name
      end

      def stateful_attribute_name_for_machine(machine_name = nil)
        if machine_name
          "#{machine_name}_state"
        else
          instance_variable_get(:@stateful_variable_name)
        end
      end

      def define_stateful_attribute_setter_method(machine_name: nil)
        attribute_name = stateful_attribute_name_for_machine(machine_name)
        define_method("#{attribute_name}=") do |state|
          instance_variable_set("@#{attribute_name}", self.class.stateful_state_machine(machine_name).find(state))
        end
      end

      def define_stateful_attribute_getter_method(machine_name: nil)
        attribute_name = stateful_attribute_name_for_machine(machine_name)
        define_method(attribute_name) do
          if state = instance_variable_get("@#{attribute_name}")
            state
          else
            initial_state = self.class.stateful_state_machine(machine_name).initial_state
            self.send("#{attribute_name}=", initial_state.name)
            initial_state
          end
        end
      end
    end
  end
end
