class CreateAsmQns < ActiveRecord::Migration
  def change
    create_table :asm_qns do |t|
      t.integer :asm_id
      t.string :asm_type
      t.integer :qn_id
      t.string :qn_type

      t.timestamps
    end
  end
end
