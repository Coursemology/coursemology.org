class CreateMaterials < ActiveRecord::Migration
  def change
    create table :material_folders do |t|
    t.integer :parent_folder_id
    t.integer :course_id
    t.string  :name
    t.text    :description
  end
  create table :materials do |t
    t.string  :name
  end
end
