# test/Poro/WithInvalidEvent.rb

gem 'minitest'
gem 'minitest-spec-context'

require 'minitest/autorun'
require 'minitest-spec-context'
require_relative '../../lib/stateful'

class PoroMachine13
  extend Stateful

  initial_state :unstarted do
    on :start => :connecting
  end

  state :connecting do
    on :handshake_ok => :open
  end

  final_state :open
end

class PoroMachine14
  extend Stateful

  state_machine :link do
    initial_state :unstarted do
      on :start => :connecting
    end

    state :connecting do
      on :handshake_ok => :open
    end

    final_state :open
  end
end

describe Stateful::Poro do
  context "an event with no transition from a non-final state" do
    let(:machine){PoroMachine13.new}

    before do
      machine.start
    end

    it "must raise Stateful::InvalidTransition" do
      error = _{machine.start}.must_raise Stateful::InvalidTransition
      _(error.event_name).must_equal :start
      _(error.state_name).must_equal :connecting
      _(error.message).must_equal "no transition for :start from :connecting"
    end

    it "must stay in the current state" do
      _{machine.start}.must_raise Stateful::InvalidTransition
      _(machine.current_state.name).must_equal :connecting
      _(machine.initial_state?).must_equal false
    end
  end

  context "an event with no transition from a final state" do
    let(:machine){PoroMachine13.new}

    before do
      machine.start
      machine.handshake_ok
    end

    it "must raise Stateful::InvalidTransition" do
      error = _{machine.start}.must_raise Stateful::InvalidTransition
      _(error.event_name).must_equal :start
      _(error.state_name).must_equal :open
      _(error.message).must_equal "no transition for :start from :open"
    end

    it "must stay in the final state" do
      _{machine.start}.must_raise Stateful::InvalidTransition
      _(machine.current_state.name).must_equal :open
      _(machine.final_state?).must_equal true
    end
  end

  context "an event with no transition in a named machine" do
    let(:machine){PoroMachine14.new}

    before do
      machine.start
      machine.handshake_ok
    end

    it "must raise Stateful::InvalidTransition" do
      error = _{machine.start}.must_raise Stateful::InvalidTransition
      _(error.event_name).must_equal :start
      _(error.state_name).must_equal :open
      _(error.message).must_equal "no transition for :start from :open"
    end

    it "must stay in the final state" do
      _{machine.start}.must_raise Stateful::InvalidTransition
      _(machine.link_state.name).must_equal :open
      _(machine.link_final_state?).must_equal true
    end
  end
end
