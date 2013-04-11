class AddIndexToAsmTag < ActiveRecord::Migration
  def change
    add_index :asm_tags, :asm_id
    add_index :asm_tags, :tag_id
  end
end
