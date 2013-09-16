class AddCurrentQnToSurveySubmissions < ActiveRecord::Migration
  def change
    add_column :survey_submissions, :current_qn, :integer
  end
end
