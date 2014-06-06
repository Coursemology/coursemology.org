class CreateNavbarLinkTypes < ActiveRecord::Migration
  def change
    create_table :navbar_link_types do |t|
      t.string :link_type

      t.timestamps
    end
  end
end
