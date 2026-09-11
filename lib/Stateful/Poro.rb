# Stateful/Poro.rb
# Stateful::Poro

require_relative './ClassMethods'
require_relative './InstanceMethods'
require_relative './Poro/ClassMethods'

module Stateful
  module Poro
    class << self

      def set_variable_name(klass)
        unless klass.instance_variable_get(:@stateful_variable_name)
          klass.instance_variable_set(:@stateful_variable_name, 'current_state')
        end
      end

      def extended(klass)
        klass.extend(Stateful::ClassMethods)
        klass.send(:include, Stateful::InstanceMethods)
        set_variable_name(klass)
        klass.extend(Stateful::Poro::ClassMethods)
      end
      alias_method :included, :extended

    end # class << self
  end
end
