# test/Sequel/WithMultipleStateMachinesAndStatefulBlock.rb

gem 'minitest'
gem 'minitest-spec-context'

require 'minitest/autorun'
require 'minitest-spec-context'

require_relative './test_helper'

require_relative '../../lib/stateful'

DB.create_table :sequel_machine12s do
  primary_key :id
  String :fulfilment_state
  String :payment_state
end

class SequelMachine12 < Sequel::Model
  extend Stateful

  stateful do
    state_machine :fulfilment do
      initial_state :pending do
        on :items_collected => :ready
      end

      state :ready do
        on :dispatch => :dispatched
      end

      final_state :dispatched
    end

    state_machine :payment do
      initial_state :unpaid do
        on :pay => :paid
      end

      state :paid do
        on :refund => :refunded
      end

      final_state :refunded
    end
  end
end

describe Stateful::Sequel do
  let(:machine){SequelMachine12.create}

  context "initial states" do
    it "must be in the fulfilment initial state" do
      _(machine.fulfilment_initial_state?).must_equal true
    end

    it "must be in the payment initial state" do
      _(machine.payment_initial_state?).must_equal true
    end

    it "must have the correct fulfilment state name" do
      _(machine.fulfilment_state.name).must_equal :pending
    end

    it "must have the correct payment state name" do
      _(machine.payment_state.name).must_equal :unpaid
    end

    it "must have fulfilment transitions" do
      _(machine.fulfilment_transitions.size).must_equal 1
      _(machine.fulfilment_transitions.first.event_name).must_equal :items_collected
    end

    it "must have payment transitions" do
      _(machine.payment_transitions.size).must_equal 1
      _(machine.payment_transitions.first.event_name).must_equal :pay
    end

    it "must not be in a fulfilment final state" do
      _(machine.fulfilment_final_state?).must_equal false
    end

    it "must not be in a payment final state" do
      _(machine.payment_final_state?).must_equal false
    end

    it "must have domain predicates" do
      _(machine.pending?).must_equal true
      _(machine.unpaid?).must_equal true
    end
  end

  context "independent state transitions" do
    before do
      machine.pay
    end

    it "must still be in the fulfilment initial state" do
      _(machine.fulfilment_initial_state?).must_equal true
      _(machine.pending?).must_equal true
    end

    it "must have advanced the payment state" do
      _(machine.payment_state.name).must_equal :paid
      _(machine.paid?).must_equal true
    end

    it "must not be in the payment initial state" do
      _(machine.payment_initial_state?).must_equal false
    end

    it "must have persisted the payment state" do
      machine.refresh
      _(machine.payment_state.name).must_equal :paid
    end

    it "must have persisted the fulfilment state as initial" do
      machine.refresh
      _(machine.fulfilment_state.name).must_equal :pending
    end
  end

  context "both machines advanced" do
    before do
      machine.items_collected
      machine.pay
    end

    it "must be in the ready fulfilment state" do
      _(machine.fulfilment_state.name).must_equal :ready
      _(machine.ready?).must_equal true
    end

    it "must be in the paid payment state" do
      _(machine.payment_state.name).must_equal :paid
      _(machine.paid?).must_equal true
    end

    it "must have correct fulfilment transitions" do
      _(machine.fulfilment_transitions.size).must_equal 1
      _(machine.fulfilment_transitions.first.event_name).must_equal :dispatch
    end

    it "must have correct payment transitions" do
      _(machine.payment_transitions.size).must_equal 1
      _(machine.payment_transitions.first.event_name).must_equal :refund
    end

    it "must have persisted both states" do
      machine.refresh
      _(machine.fulfilment_state.name).must_equal :ready
      _(machine.payment_state.name).must_equal :paid
    end
  end

  context "fulfilment final state" do
    before do
      machine.items_collected
      machine.dispatch
    end

    it "must be in the fulfilment final state" do
      _(machine.fulfilment_final_state?).must_equal true
      _(machine.dispatched?).must_equal true
    end

    it "must have no fulfilment transitions" do
      _(machine.fulfilment_transitions.empty?).must_equal true
    end
  end

  context "payment final state" do
    before do
      machine.pay
      machine.refund
    end

    it "must be in the payment final state" do
      _(machine.payment_final_state?).must_equal true
      _(machine.refunded?).must_equal true
    end

    it "must have no payment transitions" do
      _(machine.payment_transitions.empty?).must_equal true
    end
  end

  context "active?" do
    it "must be active when all machines are in initial states" do
      _(machine.active?).must_equal true
    end

    it "must be active when one machine has reached final state" do
      machine.items_collected
      machine.dispatch
      _(machine.fulfilment_final_state?).must_equal true
      _(machine.active?).must_equal true
    end

    it "must not be active when all machines have reached final states" do
      machine.items_collected
      machine.dispatch
      machine.pay
      machine.refund
      _(machine.active?).must_equal false
    end

    it "must be able to check a specific machine" do
      machine.items_collected
      machine.dispatch
      _(machine.active?(:fulfilment)).must_equal false
      _(machine.active?(:payment)).must_equal true
    end
  end
end
