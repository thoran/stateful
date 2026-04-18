# Stateful/ActiveRecord/ClassMethods.rb
# Stateful::ActiveRecord::ClassMethods

module Stateful
  module ActiveRecord
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

      def stateful_column_name=(stateful_column_name)
        @stateful_column_name = stateful_column_name
      end

      def stateful_column_name
        @stateful_column_name
      end

      def stateful_attribute_name_for_machine(machine_name = nil)
        if machine_name
          "#{machine_name}_state"
        else
          instance_variable_get(:@stateful_column_name)
        end
      end

      def define_stateful_attribute_setter_method(machine_name: nil)
        stateful_column_name = stateful_attribute_name_for_machine(machine_name)
        define_method("#{stateful_column_name}=") do |state|
          instance_variable_set("@#{stateful_column_name}", self.class.stateful_state_machine(machine_name).find(state))
          write_attribute(stateful_column_name, instance_variable_get("@#{stateful_column_name}").name)
          self.save
          instance_variable_get("@#{stateful_column_name}")
        end
      end

      def define_stateful_attribute_getter_method(machine_name: nil)
        stateful_column_name = stateful_attribute_name_for_machine(machine_name)
        define_method(stateful_column_name) do
          instance_variable_set("@#{stateful_column_name}", self.class.stateful_state_machine(machine_name).find(read_attribute(stateful_column_name)))
          if state = instance_variable_get("@#{stateful_column_name}")
            state
          else
            initial_state = self.class.stateful_state_machine(machine_name).initial_state
            self.send("#{stateful_column_name}=", initial_state.name)
            initial_state
          end
        end
      end
    end
  end
end
