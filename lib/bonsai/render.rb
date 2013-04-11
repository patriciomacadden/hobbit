require 'tilt'

module Bonsai
  module Render
    def render(template, locals = {}, options = {}, &block)
      Tilt.new(template, options).render(self, locals, &block)
    end
  end
end
