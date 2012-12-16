class CreateAsmReqs < ActiveRecord::Migration
  def change
    create_table :asm_reqs do |t|
      t.integer :asm_id
      t.string :asm_type
      t.integer :min_grade

      t.timestamps
    end
  end
end
