require "./utils.rb"

class Lexer
  OTHER_NAMES = {
    "'" => :quote,
    "(" => :lparen,
    ")" => :rparen,
    "{" => :lcurly,
    "}" => :rcurly,
    "[" => :lsquare,
    "]" => :rsquare,
  }.freeze

  def initialize(str)
    @str = str
    @len = str.size
    @beg = { ln: 1, col: 1, idx: 0 }
    @pos = { ln: 1, col: 1, idx: 0 }
    @ttp = :none
  end

  def pdiff(a, b)
    {
      ln: a[:ln] - b[:ln],
      col: a[:col] - b[:col],
      idx: a[:idx] - b[:idx],
    }
  end

  def begin_tkn!()
    @beg = @pos.dup
  end

  def newline!()
    # @pos = { ln: @pos[:ln] + 1, col: 0 }
    @pos[:ln] += 1
    @pos[:col] = 0
    next_chr!()
  end

  def lex()
    raise StopIteration if @pos[:idx] >= @len

    begin_tkn!()
    return lex_number() if peek() =~ /[0-9]/ || peekl(2) =~ /-[0-9]/
    return lex_string() if peek() =~ /"/
    return lex_other() if peek() =~ /[\(\)\[\]\{\}']/
    return (newline!(); lex()) if peek() == ?\n
    return (next_chr!(); lex()) if peek() =~ /\s/
    return lex_name()
  end

  def peek()
    @str[@pos[:idx]]
  end

  def peekl(l)
    @str[@pos[:idx], l]
  end

  def peekn(n)
    @str[@pos[:idx] + n]
  end

  def peeknl(n, l = 1)
    @str[@pos[:idx] + n, l]
  end

  def next_chr!()
    @pos[:col] += 1
    c = @str[@pos[:idx] += 1]
    c
  end

  def lex_number()
    next_chr!() if peek() == ?-
    nt = case peekn(1)
      when ?x
        lex_hex_number()
      when ?o
        lex_oct_number()
      else
        lex_dec_number()
      end
    nt
  end

  def default_lit()
    @str[@beg[:idx], pdiff(@pos, @beg)[:idx]]
  end

  def create_token(value, type, literal = default_lit())
    { value: value,
      type: type,
      literal: literal,
      pos: @beg.dup,
      end: @pos.dup }
  end

  def lex_hex_number()
    next_chr!()
    next while next_chr!() =~ /[0-9a-f]/i
    literal = default_lit()
    create_token(literal.to_i(16).to_f, :number, literal)
  end

  def lex_oct_number()
    next_chr!()
    next while next_chr!() =~ /[0-8]/
    literal = default_lit()
    create_token(literal.to_i(8).to_f, :number, literal)
  end

  def lex_dec_number()
    # next_chr!() while peek() =~ /[0-9]/
    next while next_chr!() =~ /[0-9]/

    if peekl(2) =~ /\.[0-9]/
      next while next_chr!() =~ /[0-9]/
    end

    if (match = (/e(-)?[0-9]/i.match(peekl(3))))
      next_chr!() if match.captures[0]
      next while next_chr!() =~ /[0-9]/
    end

    literal = default_lit()
    t = create_token(literal.to_f, :number, literal)
  end

  def lex_string()
    sacc = ""
    bseg = @beg.dup
    bseg[:idx] += 1
    while next_chr!() != ?"
      if peek() == ?\\
        sacc << @str[bseg[:idx], pdiff(@pos, bseg)[:idx]]
        case next_chr!()
        when ?n
          sacc << ?\n
        when ?t
          sacc << ?\t
        when ?0
          sacc << ?\0
        when ?r
          sacc << ?\r
        else
          bseg = @pos.dup
          next
        end
        bseg = @pos.dup
        bseg[:idx] += 1
      end
    end
    sacc << @str[bseg[:idx], pdiff(@pos, bseg)[:idx]]
    next_chr!()
    create_token(sacc, :string)
  end

  def lex_other()
    c = peek()
    next_chr!()
    create_token(nil, OTHER_NAMES[c], c)
  end

  def lex_name()
    next until next_chr!() =~ /[\[\]\(\)\{\}\s]/
    val = default_lit()
    create_token(val, :name, val)
  end

  def lexall()
    Manipulate.take_from_while_lambda { lex() }
  end
end
