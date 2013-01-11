class CreateThemeAttributes < ActiveRecord::Migration
  def change
    create_table :theme_attributes do |t|
      t.string :name
      t.string :description
      t.string :value_type

      t.timestamps
    end
  end
end
