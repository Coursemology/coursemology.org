class AsmReq < ActiveRecord::Base
  attr_accessible :asm_id, :asm_type, :min_grade

  belongs_to :asm, polymorphic: true
end
