require 'forwardable'

module Hobbit
  class Response
    attr_accessor :body, :headers, :status
    extend Forwardable
    def_delegators :headers, :[], :[]=

    def initialize(body = [], status = 200, headers = { 'Content-Type' => 'text/html; charset=utf-8' })
      @body, @headers, @status = body, headers, status
    end

    def finish
      headers['Content-Length'] = body.each.map(&:size).inject(0, &:+).to_s
      [status, headers, body]
    end

    def redirect(target, status = 302)
      self.status = status
      headers['Location'] = target
    end

    def write(string)
      body << string
    end
  end
end
