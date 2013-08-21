class AddAsmTypeIndexToAsmQns < ActiveRecord::Migration
  def change
    add_index :asm_qns, :asm_type
  end
end
