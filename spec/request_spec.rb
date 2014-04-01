require 'minitest_helper'

describe Hobbit::Request do
  describe '#initialize' do
    it "must set the path info to / if it's empty" do
      env = { 'PATH_INFO' => '', 'REQUEST_METHOD' => 'GET' }
      request = Hobbit::Request.new env
      request.path_info.must_equal '/'
    end

    it "wont change the path info if it's not empty" do
      env = { 'PATH_INFO' => '/hello_world', 'REQUEST_METHOD' => 'GET' }
      request = Hobbit::Request.new env
      request.path_info.must_equal '/hello_world'
    end
  end
end
