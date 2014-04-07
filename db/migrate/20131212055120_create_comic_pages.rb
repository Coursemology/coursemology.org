class CreateComicPages < ActiveRecord::Migration
  def change
    create_table :comic_pages do |t|
      t.belongs_to :comic
      t.integer :page

      t.timestamps
    end
  end
end
