RSpec::Matchers.define :have_throttle do |limit, options|
  match do |record|
    record._throttles.any? do |throttle|
      throttle.limit == limit && throttle.options == options
    end
  end
end
