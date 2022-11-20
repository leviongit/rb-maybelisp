class LispValue
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
