require "./lexer.rb"
require "./parser.rb"
require "./lisp.rb"
require "pp"

File.open(ARGV[0]) do |file|
  tokens = Lexer.new(file.read).lexall()
  # pp tokens
  forms = Parser.new(tokens).parse_to_forms()
  lisp = Lisp.new(forms)
  lisp.execute()
end
