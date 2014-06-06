RSpec::Matchers.define :have_callback do |type, name, options|
  match do |record|
    callbacks = record.__send__(:"_#{type}_callbacks")
    callbacks.any? do |callback|
      callback.raw_filter == name &&
        (options[:kind].nil? || callback.kind == options[:kind]) &&
        (options[:on].nil? || callback.options[:on] == options[:on])
    end
  end
end
