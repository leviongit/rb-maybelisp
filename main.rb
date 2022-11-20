require "./lexer.rb"
require "./parser.rb"
require "./lisp.rb"
require "pp"

File.open(ARGV[0]) do |file|
  Lisp.eval(file.read)
end
