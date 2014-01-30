class AddObjUrlToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :obj_url, :string
  end
end
