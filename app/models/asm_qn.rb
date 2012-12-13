class AsmQn < ActiveRecord::Base
  attr_accessible :asm_id, :asm_type, :qn_id, :qn_type

  belongs_to :asm, polymorphic: true
  belongs_to :qn, polymorphic: true
end
