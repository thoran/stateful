# Stateful.rb
# Stateful

module Stateful

  class << self

    def extended(klass)
      if Object.const_defined?(:ActiveRecord) && defined?(::ActiveRecord::Base) && klass < ::ActiveRecord::Base
        require_relative File.join('Stateful', 'ActiveRecord')
        klass.extend(Stateful::ActiveRecord)
      else
        require_relative File.join('Stateful', 'Poro')
        klass.extend(Stateful::Poro)
      end
    end
    alias_method :included, :extended

  end # class << self

end
