ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "spec/test.db")

class ExampleRecord < ActiveRecord::Base
end

RSpec.configure do |config|
  config.around do |example|
    ExampleRecord._throttles = []

    ActiveRecord::Base.transaction do
      ActiveRecord::Migration.verbose = false
      ActiveRecord::Migration.create_table(:example_records) do |table|
        table.integer :user_id
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
