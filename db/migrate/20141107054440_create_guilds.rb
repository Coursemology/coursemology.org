class CreateGuilds < ActiveRecord::Migration
  def change
    create_table :guilds do |t|
      t.string :name
      t.text :description
      t.references :course, index: true

      t.timestamps
    end
  end
end
