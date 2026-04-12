require_relative './lib/Stateful/VERSION'

Gem::Specification.new do |spec|
  spec.name = 'stateful.rb' # I would have preferred 'stateful', but there's a gem with the name of stateful already.
  spec.version = Stateful::VERSION

  spec.summary = "A Ruby state machine."
  spec.description = "Easily add state to Poro and ActiveRecord objects."

  spec.author = 'thoran'
  spec.email = 'code@thoran.com'
  spec.homepage = 'http://github.com/thoran/Stateful'
  spec.license = 'MIT'

  spec.files = Dir['lib/**/*.rb']
  spec.required_ruby_version = '>= 2.5' # The required version of Ruby is this high solely because the migrations have been made to require AR 6.0, but otherwise this should work with much lower versions of Ruby and ActiveRecord, even down to 2.3 (or lower) and AR 3 (or lower).

  spec.add_development_dependency('minitest')
  spec.add_development_dependency('minitest-spec-context')
  spec.add_development_dependency('activerecord')
  spec.add_development_dependency('sqlite3')
end
