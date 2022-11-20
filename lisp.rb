require "./environment.rb"

module Lisp
  DEFAULT_ENV = Environment.new(
    nil,
    id: ->env, args { eval_all(env, args) },
    print: ->env, args { puts eval_all(env, args).join(" ") },
    quote: ->env, args { args },
    loop: ->env, args {
      args.each { ensure_value_type(_1, :list) }
      loop {
        begin
          eval_all_(env, args)
        rescue StopIteration
          return LispValue.nil()
        end
      }
    },
    break: ->env, args { raise StopIteration, args.car },
    read: ->env, args { LispValue.string($stdin.gets) },
    eval: ->env, args {
      eval!(env, eval_all(env, args))
    },
  ).freeze

  class EvalError < StandardError; end

  class << self
    def eval!(env, *strings)
      strings = strings.flatten.join("\n")
      tokens = Lexer.new(strings).lexall()
      forms = Parser.new(tokens).parse_to_forms()
      eval_all_(env, forms)
    end

    def eval_all_(env, args)
      val = nil
      forall(args) { val = _1.eval(env) }
      val
    end

    def eval_all(env, args)
      args.map { _1.eval(env) }
    end

    def forall(vals, &action)
      vals.each(&action)
    end

    def ensure_value_type(value, *types)
      unless types.include?(value.type)
        emsg = types.length < 3 ?
          "#{types.join(" or ")}" :
          "#{types[...-1].join(", ")}, or #{types[-1]}"
        raise EvalError, "Expected a #{emsg}, got #{value.type}"
      end
    end

    def ensure_arity(args, arity, name: :anonymous)
      unless arity === args.length
        raise EvalError, "#{name} expected #{arity} arguments, got #{args.length}"
      end
    end

    def eval(*strings)
      env = DEFAULT_ENV.dup
      eval!(env, strings)
    rescue Interrupt
      exit(0)
    end
  end
end
