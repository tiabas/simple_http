unless ENV['CI']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'spec'
  end
end

require 'rspec'
require 'rspec/autorun'
require 'webmock/rspec'
require 'ostruct'
require 'simple_http'

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def stub_delete(path='')
  stub_request(:delete, "https://example.com:443#{path}")
end

def stub_get(path='')
  stub_request(:get, "https://example.com:443#{path}")
end

def stub_post(path='')
  stub_request(:post, "https://example.com:443#{path}")
end

def stub_put(path='')
  stub_request(:put, "https://example.com:443#{path}")
end