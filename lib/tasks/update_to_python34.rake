namespace :db do
  task update_to_python34: :environment do
    course = Course.find(97)
    lang = ProgrammingLanguage.find_by_cmd("python3.4")
    course.assessments.all.each do |asm|
      asm.questions.all.each do |qs|
        if qs.is_a?(Assessment::CodingQuestion)
          qs.specific.language = lang 
          qs.specific.save
        end
      end
    end
  end
end

