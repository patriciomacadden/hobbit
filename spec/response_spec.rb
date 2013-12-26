require 'minitest_helper'

describe Hobbit::Response do
  describe '#initialize' do
    it 'must set the body, status and headers with no arguments given' do
      default_headers = { 'Content-Type' => 'text/html; charset=utf-8' }
      response = Hobbit::Response.new
      response.status.must_equal 200
      response.headers.must_equal default_headers
      response.body.must_equal []
    end

    it 'must set the body, status and headers with arguments given' do
      status, headers, body = 200, { 'Content-Type' => 'application/json' }, ['{"name":"Hobbit"}']
      response = Hobbit::Response.new body, status, headers
      response.status.must_equal status
      response.headers.must_equal headers
      response.body.must_equal body
    end
  end

  describe '#[]' do
    let(:response) { Hobbit::Response.new }

    it 'must respond to #[]' do
      response.must_respond_to :[]
    end

    it 'must return a header' do
      response['Content-Type'].must_equal 'text/html; charset=utf-8'
    end
  end

  describe '#[]=' do
    let(:response) { Hobbit::Response.new }

    it 'must respond to #[]=' do
      response.must_respond_to :[]=
    end

    it 'must set a header' do
      content_type = 'text/html; charset=utf-8'
      response['Content-Type'] = content_type
      response['Content-Type'].must_equal content_type
    end
  end

  describe '#finish' do
    let(:status) { 200 }
    let(:headers) { { 'Content-Type' => 'application/json' } }
    let(:body) { ['{"name":"Hobbit"}'] }

    it 'must return a 3 elements array with status, headers and body' do
      response = Hobbit::Response.new body, status, headers
      response.finish.must_equal [status, headers, body]
    end

    it 'must calculate the Content-Length of the body' do
      response = Hobbit::Response.new body, status, headers
      s, h, b = response.finish
      h.must_include 'Content-Length'
      h['Content-Length'].must_equal '17'
    end
  end

  describe '#write' do
    let(:response) { Hobbit::Response.new }

    it 'must append the argument to the body of the response' do
      response.write 'hello world'
      response.body.must_equal ['hello world']
    end
  end
end
