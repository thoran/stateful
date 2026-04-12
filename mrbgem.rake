require_relative 'lib/Stateful/VERSION'

MRuby::Gem::Specification.new('mruby-stateful') do |spec|
  spec.version = Stateful::VERSION

  spec.summary = 'A state machine for mRuby.'

  spec.authors = 'thoran'
  spec.license = 'MIT'

  spec.rbfiles = ['mruby/stub_require_relative.rb'] + (Dir.glob('lib/**/*.rb').reject{|f| f.include?('ActiveRecord')})

  spec.add_dependency 'mruby-metaprog', core: 'mruby-metaprog'
  spec.add_dependency 'mruby-eval', core: 'mruby-eval'
  spec.add_dependency 'mruby-array-ext', core: 'mruby-array-ext'
end
