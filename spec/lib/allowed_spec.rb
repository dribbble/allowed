require "spec_helper"

describe Allowed do
  it "includes Limit in ActiveRecord::Base" do
    expect(ActiveRecord::Base.ancestors).to include(Allowed::Limit)
  end
end
