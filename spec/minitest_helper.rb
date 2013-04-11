ENV['RACK_ENV'] ||= 'test'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require 'minitest/autorun'
require 'rack'
require 'rack/test'

require 'bonsai'

# bonsai test apps
require 'fixtures/test_base_app'
require 'fixtures/test_render_app'

