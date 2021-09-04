require "spec_helper"

describe Allowed::Limit do
  subject { ExampleRecord }

  it "defines a class variable for throttles" do
    expect(subject).to respond_to(:_throttles)
  end
end

describe Allowed::Limit, "#allow" do
  subject { ExampleRecord }

  let(:limit)   { 100 }
  let(:block)   { -> { } }
  let(:options) { { message: "Over limit." } }

  it "adds throttle to the record" do
    subject.allow(limit, options)

    expect(subject).to have_throttle(limit, options)
  end

  it "assigns block to callback" do
    subject.allow(limit, options, &block)

    expect(subject).to have_throttle(limit, options.merge(callback: block))
  end

  it "adds validation callback" do
    subject.allow(limit, options)

    expect(subject).to have_callback(:before, :validate, :validate_throttles)
  end

  it "adds after rollback callback" do
    subject.allow(limit, options)

    expect(subject).to have_callback(:after, :validation, :handle_throttles)
  end

  it "only calls validation callback on create" do
    subject.allow(limit, options)

    instance = subject.new

    expect(instance).to receive(:validate_throttles).once

    instance.save
    instance.save
  end

  it "calls rollback callback on validation failure" do
    subject.allow :max_count, callback: -> (record) { record.callback_triggered = true }

    limit = 1
    limit.times { subject.create! }
    instance = subject.new(max_count: limit)

    expect(instance.valid?).to be_falsey
    expect(instance.save).to be_falsey
    expect(instance.callback_triggered).to be true
  end

  it "does not call rollback callback on validation success" do
    subject.allow :max_count, callback: -> (record) { record.callback_triggered = true }

    limit = 1
    instance = subject.new(max_count: limit)

    expect(instance.valid?).to be_truthy
    expect(instance.save).to be_truthy
    expect(instance.callback_triggered).to be_nil
  end

  it "doesn't unwind callback behavior due to the transaction closing" do
    subject.allow :max_count, callback: -> (record) do
      Alert.create!(message: "Too many created!")
    end

    instance = subject.new(max_count: 0)

    expect(instance.save).to be_falsey
    expect(Alert.count).to equal 1
  end

  it "doesn't unwind changes to the record due to transactions closing" do
    Widget.allow 1, scope: :account_id, callback: -> (widget) { widget.account.touch(:flagged_at) }

    account = Account.create!(flagged_at: nil)
    Widget.create!(account: account)
    instance = Widget.new(account: account)
    expect(instance.save).to be_falsey
    expect(account.reload.flagged_at).to_not be_nil
  end
end

describe Allowed::Limit, "#handle_throttles" do
  subject { ExampleRecord.new }

  let(:callback)         { double("callback", call: true) }
  let(:invalid_throttle) { double("throttle", callback: callback) }

  before do
    subject.instance_variable_set("@_throttle_failures", [invalid_throttle])
  end

  it "calls callback for throttle failures" do
    subject.__send__(:handle_throttles)

    expect(callback).to have_received(:call).with(subject).once
  end

  it "clears the failed throttles" do
    subject.__send__(:handle_throttles)

    expect(subject.instance_variable_get("@_throttle_failures")).to be_empty
  end
end

describe Allowed::Limit, "#validate_throttles" do
  subject { ExampleRecord.new }

  let(:message)          { "Over limit." }
  let(:valid_throttle)   { double("throttle", valid?: true) }
  let(:invalid_throttle) { double("throttle", valid?: false, message: message) }

  before do
    subject.class._throttles = [valid_throttle, invalid_throttle]
  end

  it "adds error messages to base" do
    subject.__send__(:validate_throttles)

    expect(subject.errors[:base].size).to eq(1)
    expect(subject.errors[:base]).to include(message)
  end

  it "stores throttle failures" do
    subject.__send__(:validate_throttles)

    expect(subject.instance_variable_get("@_throttle_failures")).to eq([invalid_throttle])
  end
end
