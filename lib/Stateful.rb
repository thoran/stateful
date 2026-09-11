# Stateful.rb
# Stateful

require_relative 'Stateful/VERSION'

module Stateful
  class << self

    def extended(klass)
      if Object.const_defined?(:ActiveRecord) && defined?(::ActiveRecord::Base) && klass < ::ActiveRecord::Base
        require_relative 'Stateful/ActiveRecord'
        klass.extend(Stateful::ActiveRecord)
      elsif Object.const_defined?(:Sequel) && defined?(::Sequel::Model) && klass < ::Sequel::Model
        require_relative 'Stateful/Sequel'
        klass.extend(Stateful::Sequel)
      else
        require_relative 'Stateful/Poro'
        klass.extend(Stateful::Poro)
      end
    end
    alias_method :included, :extended

  end # class << self
end
