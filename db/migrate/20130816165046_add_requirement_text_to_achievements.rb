class AddRequirementTextToAchievements < ActiveRecord::Migration
  def change
    add_column :achievements, :auto_assign, :boolean
    add_column :achievements, :requirement_text, :text

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
