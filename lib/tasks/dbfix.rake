namespace :dbfix do
  desc "TODO"

  def handle_question_relationship(assessment)
    qns_logs = assessment.questions.all_dest_logs
    question_above = Array.new
    assessment.questions.each do |qn|
      unless qn.dependent_on
        next
      end
      l = (qn.dependent_on.duplicate_logs_orig & qns_logs).first
      unless l
        next
      end

      if question_above.include?(l.dest_obj_id)
        qn.dependent_id = l.dest_obj_id
      else
        qn.dependent_id = nil
      end
      qn.save
      question_above << qn.id
    end
  end

  def handle_questions_position(assessment)
    pos = 0
    assessment.questions.each do |qn|
      dqa = qn.question_assessments.where(assessment_id: assessment.id).first
      dqa.position = pos
      dqa.save
      pos += 1
    end
  end

  task :pos_denpendency => :environment do
    Course.find(97).trainings.each do |training|
      assessment = training.assessment
      handle_question_relationship(assessment)
      handle_questions_position(assessment)
    end
  end

end
