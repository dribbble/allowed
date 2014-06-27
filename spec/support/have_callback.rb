RSpec::Matchers.define :have_callback do |type, name, options|
  match do |record|
    options ||= {}
    callbacks = record.__send__(:"_#{type}_callbacks")
    callbacks.any? do |callback|
      return false unless callback.raw_filter == name
      return false unless options[:kind].nil? || callback.kind == options[:kind]
      return true  if options[:on].nil?

      if callback.respond_to?(:options)
        options[:on] == callback.options[:on]
      else
        if_options = callback.instance_variable_get("@if")
        if_options.any? do |if_option|
          if_option =~ /#{options[:on]}/
        end
      end
    end
  end
end
