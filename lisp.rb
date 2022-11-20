require "./environment.rb"

class Lisp
  def eval_all(env, args)
    args.map { _1.eval(env) }
  end

  def initialize(forms)
    @forms = forms
    @env = Environment.new(
      nil,
      id: ->env, args { eval_all(env, args) },
      print: ->env, args { puts eval_all(env, args).join(" ") },
      quote: ->env, args { args },
    )
  end

  def execute()
    @forms.each { |form|
      form.eval(@env)
    }
  end
end
