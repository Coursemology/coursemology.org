module Qn
  include Duplicatable

  def duplicate
    # record the duplication
    return self.dup
  end
end
