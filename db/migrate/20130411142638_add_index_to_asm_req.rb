class AddIndexToAsmReq < ActiveRecord::Migration
  def change
    add_index :asm_reqs, :asm_id
  end
end
