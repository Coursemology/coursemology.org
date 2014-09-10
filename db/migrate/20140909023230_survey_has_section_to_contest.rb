class SurveyHasSectionToContest < ActiveRecord::Migration
  def up
    rename_column :surveys, :has_section, :is_contest

    Survey.all.each do |s|
      s.is_contest= !s.is_contest
      s.save
    end
  end

  def down
    rename_column :surveys, :is_contest, :has_section
  end
end
