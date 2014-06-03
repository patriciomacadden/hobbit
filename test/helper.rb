require 'bundler/setup'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'oktobertest'
require 'rack'
require 'rack/test'

require 'hobbit'

module Oktobertest
  class Test
    include Rack::Test::Methods

    def mock_app(&block)
      @app = Class.new(Hobbit::Base, &block).new
    end

    def app
      @app
    end
  end
end
