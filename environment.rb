class Environment < Hash
  class NameLookupError < StandardError; end

  def initialize(parent, values)
    @parent = parent
    merge!(values)
  end

  def [](key)
    return super if key?(key)
    return @parent[key] if @parent
    raise NameLookupError, "name #{key} not found"
  end
end
