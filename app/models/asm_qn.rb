class AsmQn < ActiveRecord::Base
  attr_accessible :asm_id, :asm_type, :qn_id, :qn_type, :pos

  belongs_to :asm, polymorphic: true
  belongs_to :qn, polymorphic: true, dependent: :destroy
end
