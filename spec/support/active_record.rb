ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "spec/test.db")

class Alert < ActiveRecord::Base
end

class ExampleRecord < ActiveRecord::Base
  attr_accessor :max_count
  attr_accessor :callback_triggered

  def max_count
    @max_count || Float::INFINITY
  end
end

class Account < ActiveRecord::Base
  has_many :widgets
end

class Widget < ActiveRecord::Base
  belongs_to :account
end

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.direct_descendants.each do |klass|
      klass._throttles = []
    end

    ActiveRecord::Base.transaction do
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Migration.create_table(:example_records) do |table|
        table.integer :user_id
        table.timestamps
      end

      ActiveRecord::Migration.create_table(:alerts) do |table|
        table.text :message
        table.timestamps
      end

      ActiveRecord::Migration.create_table(:accounts) do |table|
        table.timestamp :flagged_at
        table.timestamps
      end

      ActiveRecord::Migration.create_table(:widgets) do |table|
        table.references :account
        table.timestamps
      end

      example.run

      raise ActiveRecord::Rollback
    end
  end

  config.after(:suite) do
    ActiveRecord::Base.connection.instance_variable_get("@config").tap do |configuration|
      File.delete(configuration[:database])
    end
  end
end
