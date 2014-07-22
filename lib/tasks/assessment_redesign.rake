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
    @training_submissions_map = {}
    @mission_submissions_map = {}

    def migrate_mcq_question(qn_id, asm)
      mcq = Mcq.find qn_id
      mcq_attrs = mcq.attributes
      new_mcq = Assessment::McqQuestion.new({
                                                creator_id: mcq_attrs['creator_id'],
                                                description: mcq_attrs['description'],
                                                max_grade: mcq_attrs['max_grade'],

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

      DataMap.create({data_type: 'mcq', old_data_id: qn_id, new_data_id: new_mcq.question.id },
                     :without_protection => true)

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
        DataMap.create({data_type: 'mcq_option', old_data_id: opt_attrs['id'], new_data_id: new_opt.id },
                       :without_protection => true)
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

                                                         deleted_at: text_qns_attrs['deleted_at'],
                                                         created_at: text_qns_attrs['created_at'],
                                                         updated_at: text_qns_attrs['updated_at'],
                                                     }, :without_protection => true)
      qa = asm.question_assessments.new
      qa.question = new_text_qns.question
      qa.position = asm.questions.count
      new_text_qns.save! && qa.save!

      @text_questions_map[qn_id] = new_text_qns.question.id
      DataMap.create({data_type: 'text', old_data_id: qn_id, new_data_id: new_text_qns.question.id },
                     :without_protection => true)

    end

    def migrate_coding_question(qn_id, asm)
      return unless @coding_questions_map[qn_id] == nil

      # noop
      Assessment::CodingQuestion

      coding_qns = CodingQuestion.find qn_id
      coding_qns_attrs = coding_qns.attributes

      if coding_qns_attrs['include_sol_qn_id'] != nil && coding_qns_attrs['include_sol_qn_id'] != 0
        if @coding_questions_map[coding_qns_attrs['include_sol_qn_id']] == nil
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
                                                          deleted_at: coding_qns_attrs['deleted_at'],
                                                          created_at: coding_qns_attrs['created_at'],
                                                          updated_at: coding_qns_attrs['updated_at']
                                                      }, :without_protection => true)

      @languages_map[language] ||= {}

      new_coding_qns.language = ProgrammingLanguage.first

      qa = asm.question_assessments.new
      qa.question = new_coding_qns.question
      qa.position = asm.questions.count
      new_coding_qns.save! && qa.save!

      @coding_questions_map[qn_id] = new_coding_qns.question.id
      DataMap.create({data_type: 'coding_question', old_data_id: qn_id, new_data_id: new_coding_qns.question.id },
                     :without_protection => true)

      if coding_qns_attrs['staff_comments'] && coding_qns_attrs['staff_comments'] != ''
        topic = CommentTopic.where(course_id: asm['course_id'], topic_id: qn_id, topic_type: 'CodingQuestion').first
        topic = CommentTopic.create({
                                        course_id: asm['course_id'],
                                        topic_id: new_coding_qns.id,
                                        topic_type: new_coding_qns.class.to_s
                                    }) unless topic
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
            if DataMap.find_by_data_type_and_new_data_id('mcq', qn_id)
              return
            end
            migrate_mcq_question(qn_id, asm)
          when :Question
            if DataMap.find_by_data_type_and_new_data_id('text', qn_id)
              return
            end
            migrate_text_question(qn_id, asm)
          when :CodingQuestion
            if DataMap.find_by_data_type_and_new_data_id('coding_question', qn_id)
              return
            end
            migrate_coding_question(qn_id, asm)
          else
            raise StandardError, "Unknown qn_type: #{q['qn_type']}"
        end
      end
    end

    def migrate_missions
      Assessment::Mission
      migrated = Mission.joins("INNER JOIN data_maps dm ON dm.old_data_id = missions.id and dm.data_type = 'mission'")
      (Mission.all - migrated).each do |m|
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
        DataMap.create({data_type: 'mission', old_data_id: attrs['id'], new_data_id: new_mission.assessment.id},
                       :without_protection => true)

        migrate_questions(attrs['id'], new_mission.assessment, :mission)
      end

    end

    def migrate_trainings
      Assessment::Training

      migrated = Training.joins("INNER JOIN data_maps dm ON dm.old_data_id = trainings.id and dm.data_type = 'training'")
      (Training.all - migrated).each do |t|
        attrs = t.attributes

        # silence bonus_cutoff < open_at validation
        # That's because some rows in the db have the open_at value set
        # with a time in the future.
        bonus_cutoff = if !attrs['bonus_cutoff'] || attrs['open_at'] > attrs['bonus_cutoff']
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
        DataMap.create({data_type: 'training', old_data_id: attrs['id'], new_data_id: new_training.assessment.id },
                       :without_protection => true)

        migrate_questions(attrs['id'], new_training.assessment, :training)
      end
    end

    def migrate_answers
      (Submission.all + TrainingSubmission.all).each do |s|
        if s.class == Submission
          assessment_id = s['mission_id']
          assessments_map = @missions_map
          submissions_map = @mission_submissions_map
          data_type = 'mission_submission'
        elsif s.class == TrainingSubmission
          assessment_id = s['training_id']
          assessments_map = @trainings_map
          submissions_map = @training_submissions_map
          data_type = 'training_submission'
        else
          raise StandardError
        end

        sbm = submissions_map[s.id]
        s.answers.each do |sbm_answer|
          if DataMap.find_by_data_type_and_new_data_id(data_type, sbm_answer.id)
            next
          end
          case sbm_answer['answer_type'].to_sym
            when :StdAnswer
              answer = sbm_answer.answer
              answer_attrs = answer.attributes

              unless @text_questions_map[answer_attrs['question_id']]
                puts "Cannot find corresponding question with id #{answer_attrs['question_id']} for std answer #{answer.id}"
                next
              end

              ans = Assessment::Answer.create!({
                                                   assessment_id: assessments_map[assessment_id],
                                                   submission_id: sbm,
                                                   question_id: @text_questions_map.fetch(answer_attrs['question_id']),
                                                   std_course_id: answer_attrs['std_course_id'],

                                                   finalised: sbm_answer['is_final'],

                                                   answer: answer_attrs['text'],
                                                   created_at: answer_attrs['created_at'],
                                                   updated_at: answer_attrs['updated_at']
                                               }, :without_protection => true)

              @text_answers_map[sbm_answer['answer_id']] = ans.id
              DataMap.create({data_type: 'text_answer', old_data_id: sbm_answer['answer_id'], new_data_id: ans.id},
                             :without_protection => true)
            when :StdMcqAnswer
              answer = StdMcqAnswer.find sbm_answer['answer_id']
              answer_attrs = answer.attributes

              unless @mcq_questions_map[answer['mcq_id']]
                puts "Cannot find corresponding mcq question with id #{answer['mcq_id']} for std answer #{answer.id}"
                next
              end

              ans = Assessment::Answer.create!({
                                                   assessment_id: assessments_map[assessment_id],
                                                   submission_id: sbm,
                                                   question_id: @mcq_questions_map.fetch(answer['mcq_id']),
                                                   std_course_id: answer_attrs['std_course_id'],

                                                   finalised: sbm_answer['is_final'],

                                                   created_at: answer_attrs['created_at'],
                                                   updated_at: answer_attrs['updated_at']
                                               }, :without_protection => true)

              @mcq_answers_map[sbm_answer['answer_id']] = ans.id

              DataMap.create({data_type: 'mcq_answer', old_data_id: sbm_answer['answer_id'], new_data_id: ans.id},
                             :without_protection => true)

              if @mcq_options_map[answer_attrs['mcq_answer_id']]
                Assessment::AnswerOption.create!({
                                                     answer_id: ans.id,
                                                     option_id: @mcq_options_map.fetch(answer_attrs['mcq_answer_id'])
                                                 }, :without_protection => true)
              end

            when :StdMcqAllAnswer
              answer = StdMcqAllAnswer.find sbm_answer['answer_id']
              answer_attrs = answer.attributes

              unless @mcq_questions_map[answer['mcq_id']]
                puts "Cannot find corresponding mcq question with id #{answer['mcq_id']} for std answer #{answer.id}"
                next
              end

              puts "Cannot find corresponding MCQ for MCQ All Answer #{answer_attrs['id']}" if @mcq_questions_map[answer_attrs['mcq_id']].nil?

              ans = Assessment::Answer.create!({
                                                   assessment_id: assessments_map[assessment_id],
                                                   submission_id: sbm,
                                                   question_id: @mcq_questions_map.fetch(answer['mcq_id']),
                                                   std_course_id: answer_attrs['std_course_id'],

                                                   finalised: sbm_answer['is_final'],

                                                   created_at: answer_attrs['created_at'],
                                                   updated_at: answer_attrs['updated_at']
                                               }, :without_protection => true)


              @mcq_all_answers_map[sbm_answer['answer_id']] = ans.id

              DataMap.create({data_type: 'mcq_all_answer', old_data_id: sbm_answer['answer_id'], new_data_id: ans.id},
                             :without_protection => true)

              JSON.parse(answer['selected_choices']).each do |choice|
                if @mcq_options_map[choice]
                  Assessment::AnswerOption.create({
                                                      answer_id: ans.id,
                                                      option_id: @mcq_options_map[choice],
                                                  }, :without_protection => true)
                end
              end
            when :StdCodingAnswer
              answer = StdCodingAnswer.find sbm_answer['answer_id']
              answer_attrs = answer.attributes

              unless @coding_questions_map[answer['qn_id']]
                puts "Cannot find corresponding coding question with id #{answer['qn_id']} for std answer #{answer.id}"
                next
              end

              ans = Assessment::Answer.create!({
                                                   assessment_id: assessments_map[assessment_id],
                                                   submission_id: sbm,
                                                   question_id: @coding_questions_map.fetch(answer['qn_id']),
                                                   std_course_id: answer_attrs['std_course_id'],

                                                   answer: answer_attrs['code'],
                                                   result: answer_attrs['result'],
                                                   attempt_left: answer_attrs['test_left'],
                                                   finalised: answer_attrs['is_correct'],
                                                   correct: answer_attrs['is_correct'],

                                                   created_at: answer_attrs['created_at'],
                                                   updated_at: answer_attrs['updated_at']
                                               }, :without_protection => true)

              @coding_answers_map[sbm_answer['answer_id']] = ans.id
              DataMap.create({data_type: 'coding_answer', old_data_id: sbm_answer['answer_id'], new_data_id: ans.id},
                             :without_protection => true)
            else
              raise StandardError, "Unknown answer_type: #{sbm_answer['answer_type']}"
          end
        end
      end
    end

    def migrate_submission(s, type)
      if type == :mission
        assessment_id = s['mission_id']
        assessments_map = @missions_map
        submissions_map = @mission_submissions_map
      elsif type == :training
        assessment_id = s['training_id']
        assessments_map = @trainings_map
        submissions_map = @training_submissions_map
      else
        raise StandardError
      end

      unless assessments_map.has_key?(assessment_id)
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
      DataMap.create({data_type: type.to_s + "_submission", old_data_id: s_attrs['id'], new_data_id: sbm.id },
                     :without_protection => true)
    end

    def migrate_submissions
      # no op
      Assessment::Submission
      m_migrated = Submission.joins("INNER JOIN data_maps dm ON dm.old_data_id = submissions.id and dm.data_type = 'mission_submission'")
      t_migrated = TrainingSubmission.joins("INNER JOIN data_maps dm ON dm.old_data_id = training_submissions.id and dm.data_type = 'training_submission'")
      (Submission.all - m_migrated).each do |s|
        migrate_submission(s, :mission)
      end
      (TrainingSubmission.all - t_migrated).each do |s|
        migrate_submission(s, :training)
      end
    end

    def migrate_gradings
      SubmissionGrading.all.each do |sbm_g|
        case sbm_g['sbm_type'].to_sym
          when :TrainingSubmission
            submission_id = @training_submissions_map[sbm_g['sbm_id']]
          when :Submission
            submission_id = @mission_submissions_map[sbm_g['sbm_id']]
          else
            puts "Cannot find corresponding sbm for grading ##{sbm_g['id']}"
            next
        end

        unless submission_id
          next
        end

        submission = Assessment::Submission.find submission_id

        grading_attrs = sbm_g.attributes

        course = submission.std_course.course
        gc =  UserCourse.find_by_course_id_and_user_id(course.id, grading_attrs['grader_id']) if grading_attrs['grader_id']
        gc_id = gc.id if gc
        g = Assessment::Grading.create!({
                                            submission_id: submission.id,
                                            grader_course_id: gc_id,
                                            std_course_id: submission.std_course_id,

                                            grade: grading_attrs['total_grade'],
                                            exp: grading_attrs['total_exp'],
                                            exp_transaction_id: sbm_g['exp_transaction_id'],

                                            created_at: grading_attrs['created_at'],
                                            updated_at: grading_attrs['updated_at']
                                        }, :without_protection => true)


        AnswerGrading.where(:submission_grading_id => sbm_g['id']).each do |answer_g|
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
          gc_id =  UserCourse.find_by_course_id_and_user_id(course.id, answer_g.grader_id) if answer_g.grader_id
          unless answer_map[answer_g.student_answer_id]
            next
          end
          Assessment::AnswerGrading.create!({
                                                answer_id: answer_map.fetch(answer_g.student_answer_id),
                                                grading_id: g.id,
                                                grader_course_id: gc_id,
                                                grade: answer_g.grade,

                                                created_at: answer_g_attrs['created_at'],
                                                updated_at: answer_g_attrs['updated_at']
                                            },  :without_protection => true)
        end
      end
    end

    def migrate_tags
      AsmTag.all.each do |tag|
        asm_map = tag['asm_type'].to_sym == :Training ? @trainings_map : @missions_map
        asm = Assessment.find_by_id(asm_map.fetch(tag['asm_id']))
        asm.questions.each do |qn|
          qn.tags << Tag.find_by_id(tag['tag_id'])
          qn.save
        end
      end
    end

    def migrate_requirements
      AsmReq.all.each do |asm_req|
        unless asm_req['asm_type']
          next
        end
        case asm_req['asm_type'].to_sym
          when :Training
            asm_map = @trainings_map
          when :Mission
            asm_map = @missions_map
          else
            next
        end
        asm = Assessment.find_by_id(asm_map.fetch(asm_req['asm_id']))
        asm_req.asm = asm
        asm_req.save
      end
    end

    def retrieve_map_from_db
      DataMap.all.each do |dm|
        case dm.data_type.to_sym
          when :mission
            map = @missions_map
          when :training
            map = @trainings_map
          when :text
            map = @text_questions_map
          when :text_answer
            map = @text_answers_map
          when :mcq
            map = @mcq_questions_map
          when :mcq_option
            map = @mcq_options_map
          when :mcq_answer
            map = @mcq_answers_map
          when :mcq_all_answer
            map = @mcq_all_answers_map
          when :coding_question
            map = @coding_questions_map
          when :coding_answer
            map = @coding_answers_map
          when :training_submission
            map = @mission_submissions_map
          when :mission_submission
            map = @mission_submissions_map
          else
            raise "retrieve data from db error on #{dm.data_type}"
        end
        map[dm.old_data_id] = dm.new_data_id
      end
    end

    retrieve_map_from_db
    migrate_missions
    migrate_trainings
    migrate_submissions
    migrate_answers
    migrate_gradings
    migrate_tags
    migrate_requirements
  end
end