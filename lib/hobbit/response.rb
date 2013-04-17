require 'rack'

module Hobbit
  class Response < Rack::Response
    def initialize(body = [], status = 200, header = {})
      header['Content-Type'] = 'text/html'
      super
    end
  end
end