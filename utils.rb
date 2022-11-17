module Manipulate
  class << self
    def take_from_while_lambda(&blk)
      vals = []
      while true
        begin
          vals << blk.call()
        rescue StopIteration
          break
        end
      end
      vals
    end

    def do_until_stopiter(&blk)
      # blk.call() while true rescue StopIteration
      while true
        begin
          blk.call()
        rescue StopIteration
          break
        end
      end
    end
  end
end
