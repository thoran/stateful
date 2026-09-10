# test/VERSION.rb

gem 'minitest'
gem 'minitest-spec-context'

require 'minitest/autorun'
require 'minitest-spec-context'
require_relative '../lib/Stateful'

describe Stateful do
  describe "VERSION" do
    it "is a string" do
      _(Stateful::VERSION).must_be_instance_of String
    end

    it "is three numbers separated by dots" do
      _(Stateful::VERSION).must_match(/\A\d+\.\d+\.\d+\z/)
    end

    it "matches the newest entry in the CHANGELOG" do
      changelog = File.read(File.expand_path('../CHANGELOG.md', __dir__))
      _(changelog[/^## (\d+\.\d+\.\d+) \(/, 1]).must_equal Stateful::VERSION
    end
  end
end
