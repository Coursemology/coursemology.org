class CreatePreferableItems < ActiveRecord::Migration
  def change
    create_table :preferable_items do |t|
      t.string  :item
      t.string  :item_type
      t.string  :name
      t.string  :default_value
      t.boolean :default_display
      t.string  :description

      t.timestamps
    end
  end
end
