# Stateful/InstanceMethods.rb
# Stateful::InstanceMethods

module Stateful
  module InstanceMethods
    def state_machines
      self.class.state_machines
    end

    def state_machine(name)
      state_machines[name]
    end

    def all_states(machine_name = nil)
      self.class.stateful_state_machine(machine_name)
    end

    def initial_state(machine_name = nil)
      self.class.stateful_state_machine(machine_name).initial_state
    end

    def final_state(machine_name = nil)
      self.class.stateful_state_machine(machine_name).final_state
    end

    def final_states(machine_name = nil)
      self.class.stateful_state_machine(machine_name).final_states
    end

    # predicate methods

    def active?(machine_name = nil)
      if machine_name
        !send("#{machine_name}_final_state?")
      elsif state_machines.empty?
        !final_state?
      else
        state_machines.keys.any?{|name| !send("#{name}_final_state?")}
      end
    end
  end
end
