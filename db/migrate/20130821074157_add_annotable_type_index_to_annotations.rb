class AddAnnotableTypeIndexToAnnotations < ActiveRecord::Migration
  def change
    add_index :annotations, :annotable_type
  end
end
