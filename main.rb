require "./lexer.rb"
require "./parser.rb"
require "pp"

File.open(ARGV[0]) do |file|
  tokens = Lexer.new(file.read).lexall()
  # pp tokens
  pp Parser.new(tokens).parseall()
end
