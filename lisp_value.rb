class LispValue
  class << self
    def string(value)
      new(:string, value.to_s)
    end

    def name(value)
      new(:name, value.to_s)
    end

    def list(value)
      new(:list, List.new(value.to_a))
    end

    def number(value)
      new(:number, value.to_f)
    end

    def nil()
      new(:nil, nil)
    end
  end

  def initialize(type, value)
    @type = type
    @value = value
  end

  def list?()
    @type == :list
  end

  def name?()
    @type == :name
  end

  def nil?()
    @value.nil?
  end

  def eval(env)
    return env[@value.car.value][env, @value.cdr] if list?()
    return env[@value.value] if name?()
    @value
  end

  def to_s()
    @value.to_s
  end

  attr_accessor :type, :value
end
