module Hobbit
  module Session
    def session
      env['rack.session']
    end
  end
end