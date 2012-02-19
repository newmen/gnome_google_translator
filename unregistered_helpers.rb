module Translator
  class UnregisteredString
    attr_reader :str
    def initialize(str); @str = str end

    def <=>(other)
      @str.downcase <=> other.str.downcase
    end

    def ==(other); self.<=>(other) == 0 end
    def eql?(other); self.==(other) end
    def hash; @str.downcase.hash end
    def to_s; @str end
  end

  class UnregisteredHash < Hash
    def [](key)
      key.is_a?(String) ? super(UnregisteredString.new(key)) : super
    end

    def []=(key, value)
      key.is_a?(String) ? super(UnregisteredString.new(key), value) : super
    end
  end
end