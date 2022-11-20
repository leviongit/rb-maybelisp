require "./utils.rb"
require "./lexer.rb"
require "./form.rb"

class Parser
  class ParseError < StandardError; end

  EXPRESSION_TKNS = %i[string name number]

  def initialize(tkns)
    @tkns = tkns
    @len = tkns.size
    @idx = 0
    @form_pos_stack = []
  end

  def at_end?()
    @idx >= @len || peek() == nil
  end

  def raise_at_end!()
    tok = peekn(-1)
    raise ParseError, "Unterminated form at #{@form_pos_stack[0]}-#{tok.end}]" if at_end?()
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
    unless Lexer.token_type?(peek(), *types)
      emsg = types.length < 3 ?
        "#{types.join(" or ")}" :
        "#{types[...-1].join(", ")}, or #{types[-1]}"
      raise ParseError, "Expected a #{emsg}, got #{peek() ? Lexer.token_type(peek()) : "EOF"}"
    end
    next_tkn!()
  end

  def parseall()
    Manipulate.take_from_while_lambda { parse_form() }
  end

  def parse()
    raise StopIteration if at_end?()

    return parse_form() if Lexer.token_type?(peek(), :lparen)
    tkn = peek()
    expect(*EXPRESSION_TKNS)
    tkn
  end

  def parse_form()
    raise StopIteration if at_end?()

    expect(:lparen)
    form = []
    @form_pos_stack.push(peek().pos.dup)
    until Lexer.token_type?((peek() || raise_at_end!()), :rparen)
      form << parse()
    end

    expect(:rparen)
    @form_pos_stack.pop()

    Form.new(form)
  end
end
