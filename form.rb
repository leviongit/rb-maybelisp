class List
  LIST_SEP = ->q {
    -> {
      q.breakable()
    }
  }

  def self.from_singular(*elems)
    new(elems)
  end

  def initialize(elems)
    @elems = elems
  end

  def car()
    @elems[0]
  end

  def cdr()
    List.new(@elems[1..])
  end

  @@car_ = List.instance_method(:car)
  @@cdr_ = List.instance_method(:cdr)
  @@car = ->x { @@car_.bind(x)[] }
  @@cdr = ->x { @@cdr_.bind(x)[] }

  def method_missing(name, *_)
    if (match = /c([ad]+)r/.match(name))
      cv = ->x { x }
      match.captures[0].each_char { |c|
        case c
        when ?a
          cv = @@car << cv
        when ?d
          cv = @@cdr << cv
        end
      }
      self.class.send(:define_method, name, &cv)
      return cv[self]
    else
      super
    end
  end

  def to_s()
    "(#{@elems.map(&:to_s).join(" ")})"
  end

  def pretty_print(q)
    q.group(1, "(", ")") {
      # @elems.each.with_index { |el, i|
      #   q.breakable() if i > 0
      #   q.text(el.to_s)
      # }
      q.seplist(@elems, LIST_SEP[q]) { |el|
        q.pp(el)
      }
    }
  end
end

class Form < List; end
