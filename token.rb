require "./lisp_value.rb"

class Position
  POSITION_SEP = ->q {
    -> {
      q.text ":"
      q.breakable("")
    }
  }

  def initialize(ln, col, idx)
    @ln = ln
    @col = col
    @idx = idx
  end

  def to_s()
    "[#{@ln}:#{@col}]"
  end

  def pretty_print(q)
    q.group(1, "[", "]") {
      # q.text("ln: #{@ln}")
      # q.breakable(", ")
      # q.text("col: #{@col}")
      # q.breakable(", ")
      # q.text("idx: #{@idx}")
      q.seplist([@ln, @col, @idx], POSITION_SEP[q]) { |el|
        q.pp(el)
      }
    }
  end

  def +(num)
    Position.new(
      @ln,
      @col + num,
      @idx + num
    )
  end

  def -(num)
    raise ArgumentError, "Number too large" if @col - num < 1
    Position.new(
      @ln,
      @col - num,
      @idx - num
    )
  end

  # attr_reader :ln, :col, :idx
  attr_accessor :ln, :col, :idx # "temporary" until i get myself together to rewrite
                                # some more logic to make this immutable
end

class Token
  def initialize(value, type, literal, pos, end_ = pos + 1)
    @value = value
    @type = type
    @literal = literal
    @pos = pos
    @end = end_
  end

  def to_s()
    @literal
  end

  def pretty_print(q)
    # q.group(1, "{", "}") {
    #   q.text("value: ")
    #   @value.pretty_print(q)
    #   q.breakable(", ")

    #   q.text("type: ")
    #   @type.pretty_print(q)
    #   q.breakable(", ")

    #   q.text("literal: ")
    #   @literal.pretty_print(q)
    #   q.breakable(", ")

    #   q.text("pos: ")
    #   @pos.pretty_print(q)
    #   q.breakable(", ")

    #   q.text("end: ")
    #   @end.pretty_print(q)
    #   q.breakable(", ")
    # }
    # q.pp(@value)
    case @type
    when :name
      q.text(@value)
    else
      q.pp(@value)
    end
  end

  def to_lisp_value()
    LispValue.new(type, value)
  end

  # def inspect()
  attr_reader :value, :type, :literal, :pos, :end
end
