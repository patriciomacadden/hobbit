require 'minitest_helper'

describe Hobbit::Response do
  describe '#initialize' do
    it 'must initialize Content-Type as text/html' do
      Hobbit::Response.new.headers['Content-Type'].must_equal 'text/html'
    end
  end
end