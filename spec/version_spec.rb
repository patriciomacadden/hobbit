require 'minitest_helper'

describe Hobbit::VERSION do
  it 'wont be nil' do
    Hobbit::VERSION.wont_be_nil
  end
end
