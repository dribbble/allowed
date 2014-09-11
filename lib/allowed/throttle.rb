module Allowed
  class Throttle
    attr_reader :limit, :options

    def initialize(limit, options = {})
      @limit   = limit
      @options = options
    end

    def callback
      options.fetch(:callback, -> (record) { })
    end

    def message
      options.fetch(:message, "Limit reached.")
    end

    def valid?(record)
      return true if skip?(record)

      scope_for(record).count < allowed_count(record)
    end

    private

    def scope_for(record)
      scope      = record.class.where("created_at >= ?", timeframe)
      attributes = Array(options.fetch(:scope, []))
      attributes.inject(scope) do |scope, attribute|
        scope.where(attribute => record.__send__(attribute))
      end
    end

    def skip?(record)
      return unless method = options[:unless]

      if method.is_a?(Symbol)
        method = record.method(method).call
      else
        method.call(record)
      end
    end

    def timeframe
      options.fetch(:per, 1.day).ago
    end

    def allowed_count(record)
      case limit
      when Integer
        limit
      when Symbol
        record.__send__(limit)
      end
    end
  end
end
