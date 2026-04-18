require_relative './lib/Stateful/VERSION'

class Gem::Specification
  def development_dependencies=(gems)
    gems.each{|gem| add_development_dependency(*gem)}
  end
end

Gem::Specification.new do |spec|
  spec.name = 'stateful.rb'
  spec.version = Stateful::VERSION

  spec.summary = "A Ruby state machine."
  spec.description = "Easily add state to Poro, ActiveRecord, and Sequel objects."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'http://github.com/thoran/stateful'
  spec.license = 'MIT'

  # The required version of Ruby is this higher than it strictly needs to be solely because the migrations have been made to require AR 6.0, but otherwise this should work with much lower versions of Ruby and ActiveRecord, even down to 2.3 (or lower) and AR 3 (or lower).
  spec.required_ruby_version = '>= 2.5'

  spec.require_paths = ['lib']

  spec.files = [
    'stateful.rb.gemspec',
    'CHANGELOG.md',
    'Gemfile',
    'README.md',
    Dir['lib/**/*.rb'],
    Dir['test/**/*.rb']
  ].flatten

  spec.development_dependencies = %w{
    minitest
    minitest-spec-context
    activerecord
    sequel
    sqlite3
  }
end
