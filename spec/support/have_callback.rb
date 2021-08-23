RSpec::Matchers.define :have_callback do |kind, type, name|
  match do |record|
    callbacks = record.__send__(:"_#{type}_callbacks")
    callbacks.any? do |callback|
      callback.matches?(kind, name)
    end
  end
end
