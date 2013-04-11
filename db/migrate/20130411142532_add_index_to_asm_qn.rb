class AddIndexToAsmQn < ActiveRecord::Migration
  def change
    add_index :asm_qns, :asm_id
    add_index :asm_qns, :qn_id
  end
end
