class AddAsmTypeIndexToAsmReqs < ActiveRecord::Migration
  def change
    add_index :asm_reqs, :asm_type
  end
end
