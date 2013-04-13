require 'minitest_helper'

describe Banzai::VERSION do
  it 'is wont be nil' do
    Banzai::VERSION.wont_be_nil
  end
end