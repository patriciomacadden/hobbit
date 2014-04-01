require 'rack/request'

module Hobbit
  class Request < Rack::Request
    def initialize(env)
      env['PATH_INFO'] = '/' if env['PATH_INFO'].empty?
      super
    end
  end
end
