module Allowed
  module Limit
    extend ActiveSupport::Concern

    included do
      class_attribute :_throttles
    end

    module ClassMethods
      def allow(limit, options = {}, &block)
        if block_given?
          options[:callback] = block
        end

        self._throttles ||= []
        self._throttles  << Throttle.new(limit, options)

        validate :validate_throttles, on: :create

        after_rollback :handle_throttles, on: :create
      end
    end

    def handle_throttles
      @_throttle_failures.each do |throttle|
        throttle.callback.call(self)
      end
      @_throttle_failures = []
    end
    private :handle_throttles

    def validate_throttles
      throttles = self.class._throttles
      throttles = throttles.reject { |throttle| throttle.valid?(self) }
      throttles.each do |throttle|
        errors.add(:base, throttle.message)
      end

      @_throttle_failures = throttles
    end
    private :validate_throttles
  end
end
