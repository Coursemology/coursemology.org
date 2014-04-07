class CreateComics < ActiveRecord::Migration
  def change
    create_table :comics do |t|
      t.string :name
      t.integer :chapter
      t.integer :episode
      t.boolean :visible
      t.belongs_to :course
      t.belongs_to :dependent_mission
      t.belongs_to :next_mission

      t.timestamps
    end
  end
end
