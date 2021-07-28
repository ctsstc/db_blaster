# frozen_string_literal: true

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../dummy/config/environment', __FILE__)
require 'db_blaster'
require 'factory_bot'
require 'db_blaster/rspec'
require 'rspec/rails'
require 'rspec/its'
require 'shoulda-matchers'
require 'pry-nav'

Rails.backtrace_cleaner.remove_silencers!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Controller tests live under spec/controllers, etc.
  config.infer_spec_type_from_file_location!
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

def mountains_insert_sql(name, height, updated_at)
  <<-SQL
      INSERT INTO MOUNTAINS (name, height, updated_at, created_at) 
      VALUES ('#{name}', #{height}, '#{updated_at.to_s(:db)}', '#{DateTime.now.to_s(:db)}')
  SQL
end

DbBlaster.configure do |config|
  config.sns_topic = 'my topic'
  config.aws_access_key = 'aws key'
  config.aws_access_secret = 'shhhh'
  config.aws_region = 'us-west-1'
  config.source_tables = [{name: 'mountains', batch_size: 10, ignored_columns: []}]
end

def create_mountain(name: 'Sandia', height: 12000, updated_at: 1.day.ago)
  ActiveRecord::Base.connection.execute(mountains_insert_sql(name, height, updated_at))
end