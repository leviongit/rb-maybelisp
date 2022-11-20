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
        eval_all(env, args)
      }
    },
  )

  class EvalError < StandardError; end

  class << self
    def eval_all(env, args)
      args.map { _1.eval(env) }
    end

    def ensure_value_type(value, *types)
      unless types.include?(value.type)
        emsg = types.length < 3 ?
          "#{types.join(" or ")}" :
          "#{types[...-1].join(", ")}, or #{types[-1]}"
        raise EvalError, "Expected a #{emsg}, got #{value.type}"
      end
    end

    def execute(forms)
      env = DEFAULT_ENV
      forms.each { |form|
        form.eval(env)
      }
    end
  end
end
