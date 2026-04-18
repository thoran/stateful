# test/ActiveRecord/WithInitialStateBlock.rb

gem 'minitest'
gem 'minitest-spec-context'

require 'minitest/autorun'
require 'minitest-spec-context'

require_relative './test_helper'

require_relative '../../lib/Stateful'

class CreateTableMachines < ActiveRecord::Migration[6.0]
  def change
    create_table :active_record_machine4s do |t|
      t.string :current_state
    end
  end
end

class ActiveRecordMachine4 < ActiveRecord::Base
  extend Stateful

  initial_state :initial_state do
    on :an_event => :next_state
    on :another_event => :final_state
  end

  state :next_state do
    on :yet_another_event => :final_state
  end

  final_state :final_state
end

CreateTableMachines.new.change

describe Stateful::ActiveRecord do
  let(:machine){ActiveRecordMachine4.create}

  it "must have an initial state" do
    _(machine.initial_state).wont_be_nil
  end

  it "must have a final state (if one has been specified)" do
    if ActiveRecordMachine4.final_state?
      _(machine.final_state).wont_be_nil
    end
  end

  context "initial_state" do
    it "must have an initial state before any events occur" do
      _(machine.initial_state?).must_equal true
    end

    it "must have an initial state consistent with what is given" do
      _(machine.initial_state).must_equal ActiveRecordMachine4.stateful_state_machine.initial_state
    end

    it "must have an initial state with name as per the name given" do
      _(machine.initial_state.name).must_equal :initial_state
    end

    it "must not be in the final state (assuming that initial and final are different states)" do
      _(machine.final_state?).must_equal false
    end

    it "must know what it's next state is given an event name" do
      _(machine.next_state(:an_event)).must_equal ActiveRecordMachine4.stateful_state_machine.find(:next_state)
      _(machine.next_state(:another_event)).must_equal ActiveRecordMachine4.stateful_state_machine.find(:final_state)
    end

    it "must have an intial state which has as set of transitions to other states" do
      _(machine.transitions.class).must_equal Array
    end

    it "must have two transitions to other states" do
      _(machine.transitions.size).must_equal 2
    end

    it "must know what transitions are available" do
      _(machine.transitions.collect{|t| [t.event_name, t.next_state_name]}).must_equal [[:an_event, :next_state], [:another_event, :final_state]]
    end

    it "must be active" do
      _(machine.active?).must_equal true
    end
  end

  context "next_state" do
    before do
      machine.an_event
    end

    it "must not be in the initial state" do
      _(machine.initial_state?).must_equal false
    end

    it "must not be in the final state" do
      _(machine.final_state?).must_equal false
    end

    it "must be in the next_state state" do
      _(machine.current_state.name).must_equal :next_state
      _(machine.next_state?).must_equal true
    end

    it "must have a set of transitions to other states" do
      _(machine.transitions.class).must_equal Array
    end

    it "must have one transition to other states" do
      _(machine.transitions.size).must_equal 1
    end

    it "must know what transitions are available" do
      _(machine.transitions.collect{|t| [t.event_name, t.next_state_name]}).must_equal [[:yet_another_event, :final_state]]
    end

    it "must be active" do
      _(machine.active?).must_equal true
    end
  end

  context "final_state" do
    before do
      machine.another_event
    end

    it "must have a final state" do
      _(machine.final_state?).must_equal true
    end

    it "must have a final state consistent with what is given" do
      _(machine.final_state).must_equal ActiveRecordMachine4.stateful_state_machine.final_state
    end

    it "must have a state with name as per the name given" do
      _(machine.current_state.name).must_equal :final_state
    end

    it "must not be in the initial state (assuming that initial and final are different states)" do
      _(machine.initial_state?).must_equal false
    end

    it "must have no transitions" do
      _(machine.transitions.empty?).must_equal true
    end

    it "must not be active" do
      _(machine.active?).must_equal false
    end
  end
end
