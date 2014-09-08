class AddRequirementTextToAchievements < ActiveRecord::Migration
  class Achievement < ActiveRecord::Base
  end
  def change
    add_column :achievements, :auto_assign, :boolean
    add_column :achievements, :requirement_text, :text

    Achievement.reset_column_information
    Achievement.all.each do |ach|
      if ach.requirements.count > 0
        ach.auto_assign = true
      else
        ach.auto_assign = false
      end
      ach.save
    end
  end
end
