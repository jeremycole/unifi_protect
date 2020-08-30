# frozen_string_literal: true

require 'bundler/setup'
require 'unifi_protect'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def data_file(relative_path)
  File.join(__dir__, relative_path)
end

def mock_unifi_protect_client
  api = UnifiProtect::API.new
  allow(api).to receive(:refresh_bearer_token) { 'xyz' }
  allow(api).to receive(:bootstrap) do
    JSON.parse(File.read(data_file('data/bootstrap.json')), object_class: OpenStruct)
  end

  UnifiProtect::Client.new(api: api)
end
