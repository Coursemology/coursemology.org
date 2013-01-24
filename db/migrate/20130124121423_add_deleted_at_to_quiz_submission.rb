class AddDeletedAtToQuizSubmission < ActiveRecord::Migration
  def change
    add_column :quiz_submissions, :deleted_at, :time
  end
end
