require "./lexer.rb"
require "pp"

File.open(ARGV[0]) do |file|
  pp Lexer.new(file.read).lexall()
end
