require 'minitest_helper'

describe Bonsai::VERSION do
  it 'is wont be nil' do
    Bonsai::VERSION.wont_be_nil
  end
end
