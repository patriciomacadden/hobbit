ENV['RACK_ENV'] ||= 'test'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require 'minitest/autorun'
require 'rack'
require 'rack/test'

require 'hobbit'

# hobbit test apps
require 'fixtures/test_base_app'
require 'fixtures/test_render_app'
require 'fixtures/test_session_app'