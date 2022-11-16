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
  end
end
