class CreateNavbarPreferableItems < ActiveRecord::Migration
  create_table :navbar_preferable_items do |t|
    t.string  :item
    t.references  :navbar_link_type
    t.string  :name
    t.boolean  :is_displayed
    t.boolean :is_enabled
    t.string  :description
    t.string  :link_to
    t.integer :pos

    t.timestamps
  end
end
