class UsingTabsMigration < ActiveRecord::Migration
  def up
    Course.all.each do |course|
      if course.trainings.count == 0
        next
      end

      type = course.trainings.first.t_type
      multiple_tabs = false

      course.trainings.each do |training|
        if training.t_type != type
          multiple_tabs = true
          break
        end
      end

      if multiple_tabs
        main = course.tabs.build({title:"Main", owner_type:Training.to_s})
        main.save
        extra = course.tabs.build({title:"Extra (Optional)", owner_type:Training.to_s})
        extra.save

        course.trainings.each do |training|
          if training.t_type == 1
            training.tab = main
          else
            training.tab = extra
          end
          training.save
        end
      end
    end
  end

  def down
  end
end
