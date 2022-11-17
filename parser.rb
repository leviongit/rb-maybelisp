require "./utils.rb"
require "./lexer.rb"

class Parser
  class ParseError < StandardError; end

  def initialize(tkns)
    @tkns = tkns
    @len = tkns.size
    @idx = 0
  end

  def at_end?()
    @idx >= @len
  end

  def raise_at_end!(ttype)
    tok = peek()
    raise ParseError, "Unterminated form at [#{tok[:pos][:ln]}:#{tok[:pos][:col]}]-[#{tok[:end][:ln]}:#{tok[:end][:col]}]" if at_end?()
  end

  def peek()
    @tkns[@idx]
  end

  def peekl(l)
    @tkns[@idx, l]
  end

  def peekn(n)
    @tkns[@idx + n]
  end

  def peeknl(n, l = 1)
    @tkns[@idx + n, l]
  end

  def advance()
    tkn = @tkns[@idx]
    @idx += 1
    tkn
  end

  def next_tkn!()
    @tkns[@idx += 1]
  end

  def expect(*types)
    raise ParseError, "Expected #{types.join(", or ")}, got #{Lexer.token_type(peek())}" unless Lexer.token_type?(peek(), *types)
    next_tkn!()
  end

  def parseall()
    Manipulate.take_from_while_lambda { parse() }
  end

  def parse()
    raise StopIteration if at_end?()

    return parse_form() if Lexer.token_type?(peek(), :lparen)
    return advance()
  end

  def parse_form()
    expect(:lparen)
    form = []

    until Lexer.token_type?(peek(), :rparen)
      form << parse()
    end

    expect(:rparen)

    form
  end
end
