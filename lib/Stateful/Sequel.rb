# Stateful/Sequel.rb
# Stateful::Sequel

require_relative 'ClassMethods'
require_relative 'InstanceMethods'
require_relative File.join('Sequel', 'ClassMethods')

module Stateful
  module Sequel

    class << self

      def set_column_name(klass)
        unless klass.instance_variable_get(:@stateful_column_name)
          klass.instance_variable_set(:@stateful_column_name, 'current_state')
        end
      end

      def extended(klass)
        klass.extend(Stateful::ClassMethods)
        klass.send(:include, Stateful::InstanceMethods)
        set_column_name(klass)
        klass.extend(Stateful::Sequel::ClassMethods)
      end
      alias_method :included, :extended

    end # class << self

  end
end
