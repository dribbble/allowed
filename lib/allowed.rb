require "active_record"
require "active_support"

require "allowed/limit"
require "allowed/throttle"

ActiveSupport.on_load(:active_record) do
  include Allowed::Limit
end
