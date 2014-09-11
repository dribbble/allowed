# allowed [![Build Status](https://travis-ci.org/dribbble/allowed.svg)](https://travis-ci.org/dribbble/allowed)

Throttle record creation in ActiveRecord.

## Example

```ruby
class Comment < ActiveRecord::Base
  belongs_to :screenshot
  belongs_to :user

  # Custom scopes beyond default created_at attribute.
  allow 10, per: 1.day, scope: :user_id
  allow 5,  per: 1.day, scope: [:screenshot_id, :user_id]

  # Custom error message.
  allow 100, per: 7.days, message: "Too many comments this week."

  # Custom conditions.
  allow 100, per: 7.days, unless: :whitelisted_user?
  allow 100, per: 7.days, unless: -> (comment) { comment.user.admin? }

  # Dynamic limit.
  allow :user_daily_limit, per: 1.day

  # Callbacks when limit is reached.
  allow 10, per: 2.minutes, callback: -> (comment) { comment.user.suspend! }
  allow 25, per: 5.minutes do |comment|
    comment.user.suspend!
  end

  def whitelisted_user?
    user.whitelisted? || screenshot.user == user
  end

  def user_daily_limit
    user.daily_limit
  end
end
```

## Credit

Based on code originally written by [Bruce
Spang](https://github.com/brucespang).

## License

allowed uses the MIT license. See LICENSE for more details.
