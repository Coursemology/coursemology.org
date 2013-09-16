class CreateSurveyTypes < ActiveRecord::Migration
  def change
    create_table :survey_types do |t|
      t.string      :title
      t.string      :description

      t.timestamps
    end
  end
end
