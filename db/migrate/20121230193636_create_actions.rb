class CreateActions < ActiveRecord::Migration
  def change
    create_table :actions do |t|
      t.string :text
      t.string :description

      t.timestamps
    end
  end
end
