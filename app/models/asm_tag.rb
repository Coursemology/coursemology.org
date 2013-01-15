class AsmTag < ActiveRecord::Base
  attr_accessible :asm_id, :asm_type, :max_exp, :tag_id

  belongs_to :asm, polymorphic: true
  belongs_to :tag
end
