class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :profile_photo_url
      t.string :display_name

      t.timestamps
    end
  end
end
