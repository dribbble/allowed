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

    expect(subject).to have_callback(:validate, :validate_throttles)
  end

  it "only calls validation callback on create" do
    instance = subject.new
    instance.stubs(:validate_throttles)

    instance.save
    instance.save

    expect(instance).to have_received(:validate_throttles).once
  end

  it "adds after rollback callback" do
    subject.allow(limit, options)

    expect(subject).to have_callback(:rollback, :handle_throttles, kind: :after, on: :create)
  end
end

describe Allowed::Limit, "#handle_throttles" do
  subject { ExampleRecord.new }

  let(:callback)         { mock(call: true) }
  let(:invalid_throttle) { mock(callback: callback) }

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
  let(:valid_throttle)   { mock(valid?: true) }
  let(:invalid_throttle) { mock(valid?: false, message: message) }

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
