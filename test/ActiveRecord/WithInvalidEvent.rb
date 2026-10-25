# test/ActiveRecord/WithInvalidEvent.rb

gem 'minitest'
gem 'minitest-spec-context'

require 'minitest/autorun'
require 'minitest-spec-context'

require_relative './test_helper'

require_relative '../../lib/stateful'

class CreateTableMachines < ActiveRecord::Migration[6.0]
  def change
    create_table :active_record_machine13s do |t|
      t.string :current_state
    end
    create_table :active_record_machine14s do |t|
      t.string :link_state
    end
  end
end

class ActiveRecordMachine13 < ActiveRecord::Base
  extend Stateful

  initial_state :unstarted do
    on :start => :connecting
  end

  state :connecting do
    on :handshake_ok => :open
  end

  final_state :open
end

class ActiveRecordMachine14 < ActiveRecord::Base
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

CreateTableMachines.new.change

describe Stateful::ActiveRecord do
  context "an event with no transition from a non-final state" do
    let(:machine){ActiveRecordMachine13.create}

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

    it "must keep the current state persisted" do
      _{machine.start}.must_raise Stateful::InvalidTransition
      _(ActiveRecordMachine13.find(machine.id).current_state.name).must_equal :connecting
    end
  end

  context "an event with no transition from a final state" do
    let(:machine){ActiveRecordMachine13.create}

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

    it "must keep the final state persisted" do
      _{machine.start}.must_raise Stateful::InvalidTransition
      _(ActiveRecordMachine13.find(machine.id).current_state.name).must_equal :open
    end
  end

  context "an event with no transition in a named machine" do
    let(:machine){ActiveRecordMachine14.create}

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

    it "must keep the final state persisted" do
      _{machine.start}.must_raise Stateful::InvalidTransition
      _(ActiveRecordMachine14.find(machine.id).link_state.name).must_equal :open
    end
  end
end
