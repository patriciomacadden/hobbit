ENV['RACK_ENV'] ||= 'test'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require 'coveralls'
Coveralls.wear!

require 'minitest/autorun'
require 'rack'
require 'rack/test'

require 'hobbit'

module Hobbit
  module Mock
    def mock_app(&block)
      app = Class.new Hobbit::Base, &block
      @app = app.new
    end
  end
end
