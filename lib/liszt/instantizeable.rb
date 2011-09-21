module Liszt
  module Instantizeable
    def instantize(name)
      klass = self
      define_method(name) do |*args, &block|
        klass.send(name, self, *args, &block)
      end
    end
  end
end
