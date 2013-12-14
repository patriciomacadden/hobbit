require 'forwardable'

module Hobbit
  class Response
    attr_accessor :body, :headers, :length, :status
    extend Forwardable
    def_delegators :headers, :[], :[]=

    def initialize(body = [], status = 200, headers = { 'Content-Type' => 'text/html; charset=utf-8' })
      @body, @headers, @status = body, headers, status
    end

    def finish
      headers['Content-Length'] = body.each.map(&:size).inject { |memo, current| memo += current }
      [status, headers, body]
    end

    def write(string)
      self.body << string
    end
  end
end
