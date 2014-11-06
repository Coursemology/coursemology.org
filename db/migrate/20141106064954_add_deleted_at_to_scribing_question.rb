class AddDeletedAtToScribingQuestion < ActiveRecord::Migration
  def change
  	add_column :assessment_scribing_questions, :deleted_at, :timestamp
  end
end
