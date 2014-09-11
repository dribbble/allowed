require "spec_helper"

describe Allowed::Throttle, ".new" do
  subject { Allowed::Throttle.new(limit, options) }

  let(:limit)   { 100 }
  let(:options) { { message: "Over limit." } }

  it "sets limit" do
    expect(subject.limit).to eq(limit)
  end

  it "sets options" do
    expect(subject.options).to eq(options)
  end
end

describe Allowed::Throttle, "#message" do
  it "returns message if provided" do
    message  = "The message."
    throttle = Allowed::Throttle.new(1, message: message)

    expect(throttle.message).to eq(message)
  end

  it "returns default message if not provided" do
    throttle = Allowed::Throttle.new(1)

    expect(throttle.message).to eq("Limit reached.")
  end
end

describe Allowed::Throttle, "#valid?, with an unless block" do
  let(:record) { ExampleRecord.new }

  before do
    2.times { ExampleRecord.create }
  end

  it "returns true when skipped" do
    throttle = Allowed::Throttle.new(1, unless: -> (record) { true })

    expect(throttle).to be_valid(record)
  end

  it "returns false when not skipped" do
    throttle = Allowed::Throttle.new(1)

    expect(throttle).to_not be_valid(record)
  end
end

describe Allowed::Throttle, "#valid?, with an unless method symbol" do
  let(:record) { ExampleRecord.new }

  before do
    2.times { ExampleRecord.create }
  end

  it "returns true when skipped" do
    ExampleRecord.class_eval do
      def custom_method
        true
      end
    end

    throttle = Allowed::Throttle.new(1, unless: :custom_method)

    expect(throttle).to be_valid(record)
  end

  it "returns false when not skipped" do
    ExampleRecord.class_eval do
      def custom_method
        false
      end
    end

    throttle = Allowed::Throttle.new(1, unless: :custom_method)

    expect(throttle).to_not be_valid(record)
  end
end

describe Allowed::Throttle, "#valid?, within limit" do
  subject { Allowed::Throttle.new(1) }

  it "returns true" do
    expect(subject).to be_valid(ExampleRecord.new)
  end
end

describe Allowed::Throttle, "#valid?, above limit" do
  subject { Allowed::Throttle.new(1) }

  before do
    2.times { ExampleRecord.create }
  end

  it "returns false" do
    expect(subject).to_not be_valid(ExampleRecord.new)
  end
end

describe Allowed::Throttle, "#valid?, with limit method symbol" do
  subject { Allowed::Throttle.new(:custom_limit) }

  let(:record) { ExampleRecord.new }

  before do
    2.times { ExampleRecord.create }
  end

  it "returns true if higher than the count" do
    ExampleRecord.class_eval do
      def custom_limit
        3
      end
    end

    expect(subject).to be_valid(record)
  end

  it "returns false if lower than the count" do
    ExampleRecord.class_eval do
      def custom_limit
        1
      end
    end

    expect(subject).to_not be_valid(record)
  end
end

describe Allowed::Throttle, "#valid?, with custom timeframe" do
  subject { Allowed::Throttle.new(1, per: 5.minutes) }

  before do
    2.times { ExampleRecord.create(created_at: 6.minutes.ago) }
  end

  it "uses timeframe for count" do
    expect(subject).to be_valid(ExampleRecord.new)
  end
end

describe Allowed::Throttle, "#valid?, with custom scope attributes" do
  subject { Allowed::Throttle.new(1, scope: :user_id) }

  before do
    ExampleRecord.create(user_id: 2)
    ExampleRecord.create(user_id: 2)
  end

  it "uses scope attributes for count" do
    expect(subject).to be_valid(ExampleRecord.new(user_id: 1))
    expect(subject).to_not be_valid(ExampleRecord.new(user_id: 2))
  end
end
