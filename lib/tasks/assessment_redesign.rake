namespace :db do
  desc 'Migrates assessments to the new schema in 20140527151234_assessment_redesign.rb'

  task migrate_assessments: :environment do

    # noops such as Assessment::Submission are used to tell ruby which model
    # we are referencing when the namespaced model has the same name as the
    # non-namespaced model.

    @missions_map = {}
    @trainings_map = {}
    @mcq_questions_map = {}
    @mcq_options_map = {}
    @text_questions_map = {}
    @text_answers_map = {}
    @mcq_answers_map = {}
    @mcq_all_answers_map = {}
    @coding_answers_map = {}
    @coding_questions_map = {}
    @languages_map = {}

    def migrate_mcq_question(qn_id, asm)
      mcq = Mcq.find qn_id
      mcq_attrs = mcq.attributes
      new_mcq = Assessment::McqQuestion.new({
        creator_id: mcq_attrs['creator_id'],
        description: mcq_attrs['description'],
        max_grade: mcq_attrs['max_grade'],

        last_commented_at: mcq_attrs['last_commented_at'],
        deleted_at: mcq_attrs['deleted_at'],
        created_at: mcq_attrs['created_at'],
        updated_at: mcq_attrs['updated_at'],

        select_all: mcq_attrs['select_all']
      }, :without_protection => true)
      qa = asm.question_assessments.new
      qa.question = new_mcq.question
      qa.position = asm.questions.count
      new_mcq.save! && qa.save!

      @mcq_questions_map[qn_id] = new_mcq.question.id

      McqAnswer.where(:mcq_id => mcq['id']).each do |opt|
        opt_attrs = opt.attributes
        new_opt = Assessment::McqOption.create!({
          creator_id: opt_attrs['creator_id'],
          question_id: new_mcq.id,
          text: opt_attrs['text'],
          explanation: opt_attrs['explanation'],
          correct: opt_attrs['is_correct'],

          created_at: opt_attrs['created_at'],
          updated_at: opt_attrs['updated_at'],
        }, :without_protection => true)

        @mcq_options_map[opt_attrs['id']] = new_opt.id
      end
    end

    def migrate_text_question(qn_id, asm)
      text_qns = Question.find qn_id
      text_qns_attrs = text_qns.attributes
      new_text_qns = Assessment::GeneralQuestion.new({
        creator_id: text_qns_attrs['creator_id'],
        title: text_qns_attrs['title'],
        description: text_qns_attrs['description'],
        max_grade: text_qns_attrs['max_grade'],

        last_commented_at: text_qns_attrs['last_commented_at'],
        deleted_at: text_qns_attrs['deleted_at'],
        created_at: text_qns_attrs['created_at'],
        updated_at: text_qns_attrs['updated_at'],
      }, :without_protection => true)
      qa = asm.question_assessments.new
      qa.question = new_text_qns.question
      qa.position = asm.questions.count
      new_text_qns.save! && qa.save!

      @text_questions_map[qn_id] = new_text_qns.question.id
    end

    def migrate_coding_question(qn_id, asm)
      return unless @coding_questions_map[qn_id] == nil

      # noop
      Assessment::CodingQuestion

      coding_qns = CodingQuestion.find qn_id
      coding_qns_attrs = coding_qns.attributes

      if coding_qns_attrs['include_sol_qn_id'] != nil && coding_qns_attrs['include_sol_qn_id'] != 0 then
        if @coding_questions_map[coding_qns_attrs['include_sol_qn_id']] == nil then
          puts "Coding Question #{coding_qns_attrs['id']} depends on #{coding_qns_attrs['include_sol_qn_id']} but it is not migrated yet."
          puts "Migrating #{coding_qns_attrs['include_sol_qn_id']}..."
          migrate_coding_question(coding_qns_attrs['include_sol_qn_id'], asm)
        end
      end

      data = JSON.parse!(coding_qns_attrs['data'])
      language = data['language']
      version = language == "python" ? "3" : nil
      memory_limit = data['memoryLimitInMB']
      time_limit = data['timeLimitInSec']
      test_limit = data['testLimit']
      data.delete('language')
      data.delete('memoryLimitInMB')
      data.delete('timeLimitInSec')
      data.delete('testLimit')

      new_coding_qns = Assessment::CodingQuestion.new({
        creator_id: coding_qns_attrs['creator_id'],
        title: coding_qns_attrs['title'],
        description: coding_qns_attrs['description'],
        max_grade: coding_qns_attrs['max_grade'],
        # TODO: test_limit is a coding question specific field, we should
        # move it out of the parent questions table into coding_questions
        test_limit: test_limit,

        dependent_id: coding_qns_attrs['include_sol_qn_id'] && coding_qns_attrs['include_sol_qn_id'] != 0 ? @coding_questions_map.fetch(coding_qns_attrs['include_sol_qn_id']) : nil,
        memory_limit: memory_limit,
        time_limit: time_limit,
        auto_graded: coding_qns_attrs['is_auto_grading'],
        last_commented_at: coding_qns_attrs['last_commented_at'],
        deleted_at: coding_qns_attrs['deleted_at'],
        created_at: coding_qns_attrs['created_at'],
        updated_at: coding_qns_attrs['updated_at']
      }, :without_protection => true)

      @languages_map[language] ||= {}
      if @languages_map[language][version] then
        lang = @languages_map[language][version]
      else
        lang = ProgrammingLanguage.create!({
          language: language,
          version: version
        }, :without_protection => true)
        @languages_map[language][version] = lang
      end
      new_coding_qns.language = lang

      qa = asm.question_assessments.new
      qa.question = new_coding_qns.question
      qa.position = asm.questions.count
      new_coding_qns.save! && qa.save!

      @coding_questions_map[qn_id] = new_coding_qns.question.id

      if coding_qns_attrs['staff_comments'] && coding_qns_attrs['staff_comments'] != '' then
        topic = CommentTopic.where(course_id: asm['course_id'], topic_id: qn_id, topic_type: 'CodingQuestion').first
        topic = CommentTopic.create({
          course_id: asm['course_id'],
          topic_id: new_coding_qns.id,
          topic_type: new_coding_qns.class.to_s
        }) if not topic
        Comment.create({
          text: coding_qns_attrs['staff_comments'],
          commentable_id: new_coding_qns.id,
          commentable_type: new_coding_qns.class.to_s,
          comment_topic_id: topic.id
        })
      end
    end

    def migrate_questions(old_asm_id, asm, asm_type)
      AsmQn.where(asm_type: asm_type, asm_id: old_asm_id).order(:pos).each do |q|
        qn_id = q['qn_id']
        case q['qn_type'].to_sym
        when :Mcq
          migrate_mcq_question(qn_id, asm)
        when :Question
          migrate_text_question(qn_id, asm)
        when :CodingQuestion
          migrate_coding_question(qn_id, asm)
        else
          raise StandardError, "Unknown qn_type: #{q['qn_type']}"
        end
      end
    end

    def migrate_missions
      Assessment::Mission

      Mission.all.each do |m|
        attrs = m.attributes

        new_mission = Assessment::Mission.create!({
          course_id: attrs['course_id'],
          creator_id: attrs['creator_id'],
          tab_id: attrs['tab_id'],

          title: attrs['title'],
          description: attrs['description'],
          position: attrs['pos'],
          exp: attrs['exp'],
          max_grade: attrs['max_grade'],
          published: attrs['publish'],

          open_at: attrs['open_at'],
          created_at: attrs['created_at'],
          updated_at: attrs['updated_at'],
          deleted_at: attrs['deleted_at'],
          close_at: attrs['close_at'],

          file_submission: attrs['is_file_submission'],
          file_submission_only: attrs['file_submission_only'],
          single_question: attrs['single_question'],
          comment_per_qn: attrs['comment_per_qn'],

          dependent_id: attrs['dependent_id'],
          display_mode_id: attrs['display_mode'],
        }, :without_protection => true)

        @missions_map[attrs['id']] = new_mission.assessment.id

        migrate_questions(attrs['id'], new_mission.assessment, :mission)
      end

    end

    def migrate_trainings
      Assessment::Training

      Training.all.each do |t|
        attrs = t.attributes

        # silence bonus_cutoff < open_at validation
        # That's because some rows in the db have the open_at value set
        # with a time in the future.
        bonus_cutoff = if !attrs['bonus_cutoff'] || attrs['open_at'] > attrs['bonus_cutoff'] then
          attrs['open_at']
        else
          attrs['bonus_cutoff']
        end

        new_training = Assessment::Training.create!({
          course_id: attrs['course_id'],
          creator_id: attrs['creator_id'],
          tab_id: attrs['tab_id'],

          title: attrs['title'],
          description: attrs['description'],
          position: attrs['pos'],
          exp: attrs['exp'],
          max_grade: attrs['max_grade'],
          published: attrs['publish'],

          open_at: attrs['open_at'],
          created_at: attrs['created_at'],
          updated_at: attrs['updated_at'],
          deleted_at: attrs['deleted_at'],
          bonus_cutoff_at: bonus_cutoff,

          bonus_exp: attrs['bonus_exp'],
          skippable: attrs['can_skip'],
        }, :without_protection => true)

        @trainings_map[attrs['id']] = new_training.assessment.id

        migrate_questions(attrs['id'], new_training.assessment, :training)
      end
    end

    def migrate_submissions(s, type)

      if type == :mission then
        assessment_id = s['mission_id']
        assessments_map = @missions_map
        submissions_map = @mission_submissions_map
      elsif type == :training then
        assessment_id = s['training_id']
        assessments_map = @trainings_map
        submissions_map = @training_submissions_map
      else
        raise StandardError
      end

      if not assessments_map.has_key?(assessment_id) then
        puts 'Cannot find corresponding assessment for ' + type.to_s + ' #' + assessment_id.to_s
      end

      s_attrs = s.attributes
      sbm = Assessment::Submission.create!({
        assessment_id: assessments_map[assessment_id],
        std_course_id: s_attrs['std_course_id'],
        status: s_attrs['status'],
        multiplier: s_attrs['multiplier'],

        opened_at: s_attrs['open_at'],
        submitted_at: s_attrs['submit_at'],
        deleted_at: s_attrs['deleted_at'],
        created_at: s_attrs['created_at'],
        updated_at: s_attrs['updated_at'],
      }, :without_protection => true)

      submissions_map[s_attrs['id']] = sbm.id

      SbmAnswer.where(:sbm_type => :mission ? :Submission : :TrainingSubmission, :sbm_id => s['id']).each do |sbm_answer|
        case sbm_answer['answer_type'].to_sym
        when :StdAnswer
          answer = StdAnswer.find sbm_answer['answer_id']
          answer_attrs = answer.attributes

          ans = Assessment::Answer.create!({
            assessment_id: assessments_map[assessment_id],
            submission_id: sbm.id,
            question_id: @text_questions_map.fetch(answer['question_id']),
            std_course_id: answer_attrs['std_course_id'],

            finalised: sbm_answer['is_final'],

            answer: answer_attrs['text'],
            created_at: answer_attrs['created_at'],
            updated_at: answer_attrs['updated_at']
          }, :without_protection => true)

          @text_answers_map[sbm_answer['answer_id']] = ans.id
        when :StdMcqAnswer
          answer = StdMcqAnswer.find sbm_answer['answer_id']
          answer_attrs = answer.attributes

          ans = Assessment::Answer.create!({
            assessment_id: assessments_map[assessment_id],
            submission_id: sbm.id,
            question_id: @mcq_questions_map.fetch(answer['mcq_id']),
            std_course_id: answer_attrs['std_course_id'],

            finalised: sbm_answer['is_final'],

            created_at: answer_attrs['created_at'],
            updated_at: answer_attrs['updated_at']
          }, :without_protection => true)

          @mcq_answers_map[sbm_answer['answer_id']] = ans.id

          Assessment::AnswerOption.create!({
            answer_id: ans.id,
            option_id: @mcq_options_map.fetch(answer_attrs['mcq_answer_id'])
          }, :without_protection => true)
        when :StdMcqAllAnswer
          answer = StdMcqAllAnswer.find sbm_answer['answer_id']

          if @mcq_questions_map[answer['mcq_id']] == nil then
            puts "Cannot find corresponding MCQ for MCQ All Answer #{answer['id']}"
          end

          ans = Assessment::Answer.create!({
            assessment_id: assessments_map[assessment_id],
            submission_id: sbm.id,
            question_id: @mcq_questions_map.fetch(answer['mcq_id']),
            std_course_id: answer_attrs['std_course_id'],

            finalised: sbm_answer['is_final'],

            created_at: answer_attrs['created_at'],
            updated_at: answer_attrs['updated_at']
          }, :without_protection => true)

          @mcq_all_answers_map[sbm_answer['answer_id']] = ans.id

          JSON.parse(answer['selected_choices']).each do |choice|
            Assessment::McqAnswerOption.create({
              answer_id: ans.id,
              option_id: @mcq_options_map[choice],
            }, :without_protection => true)
          end
        when :StdCodingAnswer
          answer = StdCodingAnswer.find sbm_answer['answer_id']

          ans = Assessment::Answer.create!({
            assessment_id: assessments_map[assessment_id],
            submission_id: sbm.id,
            question_id: @coding_questions_map.fetch(answer['qn_id']),
            std_course_id: answer_attrs['std_course_id'],

            answer: answer_attrs['code'],
            result: answer_attrs['result'],
            attempt_left: answer_attrs['test_left'],
            finalised: sbm_answer['is_final'],
            correct: answer_attrs['is_correct'],

            created_at: answer_attrs['created_at'],
            updated_at: answer_attrs['updated_at']
          }, :without_protection => true)

          @coding_answers_map[sbm_answer['answer_id']] = ans.id
        else
          raise StandardError, "Unknown answer_type: #{sbm_answer['answer_type']}"
        end
      end
    end

    def migrate_submission
      # no op
      Assessment::Submission

      Submission.all.each do |s|
        migrate_submission(s, :mission)
      end
      TrainingSubmission.all.each do |s|
        migrate_submission(s, :training)
      end
    end

    def migrate_gradings
      SubmissionGrading.all.each do |sbm_g|
        case sbm_g['sbm_type'].to_sym
        when :TrainingSubmission
          submission = @training_submissions_map[sbm_g['sbm_id']]
        when :Submission
          submission = @mission_submissions_map[sbm_g['sbm_id']]
        else
          puts "Cannot find corresponding sbm for grading ##{sbm_g['id']}"
          next
        end

        gradings = AnswerGrading.where(:submission_grading_id => sbm_g['id'])
        gradings.each do |answer_g|
          case answer_g['student_answer_type'].to_sym
          when :StdMcqAnswer
            answer_map = @mcq_answers_map
          when :StdMcqAllAnswer
            answer_map = @mcq_all_answers_map
          when :StdAnswer
            answer_map = @text_answers_map
          when :StdCodingAnswer
            answer_map = @coding_answers_map
          else
            raise StandardError
          end

          answer_g_attrs = answer_g.attributes
          Assessment::Grading.create!({
            submission_id: submission.id,
            grader_course_id: sbm_g['grader_id'],
            std_course_id: submission.std_course_id,

            grade: answer_g_attrs['grade'],
            exp: answer_g_attrs['exp'],
            exp_transaction_id: sbm_g['exp_transaction_id'],

            created_at: answer_g_attrs['created_at'],
            updated_at: answer_g_attrs['updated_at'],
          }, :without_protection => true)
        end

        if gradings.empty? then
          # No gradings for answers, create grading for every answer with
          # 0 grade and 0 exp
          if sbm_g['total_grade'].to_i != 0 then
            raise StandardError
          end

          answers = SbmAnswer.where(:sbm_type => sbm_g['sbm_type'], :sbm_id => sbm_g['id'])
          answers.each do |a|
            case a['answer_type'].to_sym
            when :StdMcqAnswer
              answer_map = @mcq_answers_map
            when :StdMcqAllAnswer
              answer_map = @mcq_all_answers_map
            when :StdAnswer
              answer_map = @text_answers_map
            when :StdCodingAnswer
              answer_map = @coding_answers_map
            else
              raise StandardError
            end

            sbm_g_attrs = sbm_g.attributes
            Assessment::Grading.create({
              answer_id: answer_map.fetch(a['answer_id']),
              grader_id: sbm_g_attrs['grader_id'],
              grader_course_id: sbm_g_attrs['grader_course_id'],
              grade: 0,
              exp_transaction_id: sbm_g_attrs['exp_transaction_id'],
              created_at: sbm_g_attrs['created_at'],
              updated_at: sbm_g_attrs['updated_at']
            }, :without_protection => true)
          end
        end
      end
    end

    def migrate_tags
      AsmTag.all.each do |tag|
        case tag['asm_type'].to_sym
        when :Training
          training = Assessment::Training.find_by_id(@trainings_map.fetch(tag['asm_id']))
          if training then
            training.tags << Tag.find_by_id(tag['tag_id']) if training
            training.save
          end

        when :Mission
          mission = Assessment::Mission.find_by_id(@missions_map.fetch(tag['asm_id']))
          if mission then
            mission.tags << Tag.find_by_id(tag['tag_id'])
            mission.save
          end

        else
          raise StandardError
        end
      end
    end

    def migrate_requirements
    end

    migrate_missions
    migrate_trainings
    migrate_submissions
    migrate_gradings
    migrate_tags
    migrate_requirements
  end
end
