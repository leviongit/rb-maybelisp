class List < Array
  LIST_SEP = ->q {
    -> {
      q.breakable()
    }
  }

  def self.from_singles(*elems)
    new(elems)
  end

  def initialize(elems)
    initialize_copy(elems)
  end

  def car()
    self[0]
  end

  def cdr()
    List.new(self[1..])
  end

  @@car_ = List.instance_method(:car)
  @@cdr_ = List.instance_method(:cdr)
  @@car = ->x { @@car_.bind(x)[] }
  @@cdr = ->x { @@cdr_.bind(x)[] }

  def method_missing(name, *_)
    if (match = /c([ad]+)r/.match(name))
      cv = ->x { x }
      # this is awfully inefficient... (especially since this now subclasses Array) but it does magic
      match.captures[0].each_char.reverse_each { |c|
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
    "(#{map(&:to_s).join(" ")})"
  end

  def pretty_print(q)
    q.group(1, "(", ")") {
      # @elems.each.with_index { |el, i|
      #   q.breakable() if i > 0
      #   q.text(el.to_s)
      # }
      q.seplist(self, LIST_SEP[q]) { |el|
        q.pp(el)
      }
    }
  end

  def map(...)
    List.new(super)
  end

  def to_lisp_value()
    LispValue.new(:list, self.map { _1.to_lisp_value() })
  end
end

# class Form < List
#   def eval(env)
#     env[@car.value][env, @car]
#   end

#   def to_lisp_value()
#     LispValue.new(:form, self)
#   end
# end
