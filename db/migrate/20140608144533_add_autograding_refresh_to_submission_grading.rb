class AddAutogradingRefreshToSubmissionGrading < ActiveRecord::Migration
  def change
    add_column :submission_gradings, :autograding_refresh, :boolean, default: false
  end
end
