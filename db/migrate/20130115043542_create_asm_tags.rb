class CreateAsmTags < ActiveRecord::Migration
  def change
    create_table :asm_tags do |t|
      t.integer :asm_id
      t.string :asm_type
      t.integer :tag_id
      t.integer :max_exp

      t.timestamps
    end
  end
end
