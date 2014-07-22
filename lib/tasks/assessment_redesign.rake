namespace :db do
  desc 'Migrates assessments to the new schema in 20140527151234_assessment_redesign.rb'

  task migrate_assessments: :environment do

    # noops such as Assessment::Submission are used to tell ruby which model
    # we are referencing when the namespaced model has the same name as the
    # non-namespaced model.

    @ans_type_to_qn = {"StdAnswer" => 'Question',
                       "StdMcqAnswer" => 'Mcq',
                       "StdMcqAllAnswer"=> 'Mcq',
                       "StdCodingAnswer"=> 'CodingQuestion'}

    @sbm_asm_type = { "TrainingSubmission" => 'Training', "Submission" => 'Mission'}

    # (qn, new_asm_id)
    def migrate_mcq_question(qn, new_asm_id, pos)
      new_qn = Assessment::McqQuestion.create!({ creator_id: qn.creator_id,
                                                 description: qn.description,
                                                 max_grade: qn.max_grade,

                                                 created_at: qn.created_at,
                                                 updated_at: qn.updated_at,

                                                 select_all: qn.select_all,
                                               }, :without_protection => true)

      QuestionAssessment.create!({ assessment_id: new_asm_id,
                                   question_id: new_qn.question.id,
                                   position: pos
                                 }, :without_protection => true)


      DataMap.create({data_type: qn.class.to_s, old_data_id: qn.id, new_data_id: new_qn.question.id },
                     :without_protection => true)

      qn.mcq_answers.each do |opt|
        new_opt = Assessment::McqOption.create!({
                                                    creator_id: opt.creator_id,
                                                    question_id: new_qn.question.id,
                                                    text: opt.text,
                                                    explanation: opt.explanation,
                                                    correct: opt.is_correct,
                                                    created_at: opt.created_at,
                                                    updated_at: opt.updated_at
                                                }, :without_protection => true)
        DataMap.create({data_type: 'mcq_option', old_data_id: opt.id, new_data_id: new_opt.id },
                       :without_protection => true)
      end
    end

    def migrate_text_question(qn, new_asm_id, pos)
      new_qn = Assessment::GeneralQuestion.create!({ creator_id: qn.creator_id,
                                                     title: qn.title,
                                                     description: qn.description,
                                                     max_grade: qn.max_grade,

                                                     created_at: qn.created_at,
                                                     updated_at: qn.updated_at
                                                   }, :without_protection => true)

      QuestionAssessment.create!({ assessment_id: new_asm_id,
                                   question_id: new_qn.question.id,
                                   position: pos
                                 }, :without_protection => true)


      DataMap.create({data_type: qn.class.to_s, old_data_id: qn.id, new_data_id: new_qn.question.id },
                     :without_protection => true)

    end

    def migrate_coding_question(qn, new_asm_id, pos)
      # noop
      require '/Users/Raymond/Documents/NUS_Study/FYP/coursemology/app/models/assessment/coding_question'
      coding_qns_attrs = qn.attributes
      dependent_id = 0

      if coding_qns_attrs['include_sol_qn_id'] != nil && coding_qns_attrs['include_sol_qn_id'] != 0
        dm = DataMap.find_by_data_type_and_old_data_id(qn.class.to_s, coding_qns_attrs['include_sol_qn_id'])
        unless dm
          puts "Coding Question #{coding_qns_attrs['id']} depends on #{coding_qns_attrs['include_sol_qn_id']} but it is not migrated yet."
          puts "Migrating #{coding_qns_attrs['include_sol_qn_id']}..."
          asm_qn = AsmQn.where(qn_type: qn.class.to_s, qn_id: coding_qns_attrs['include_sol_qn_id']).first
          migrate_coding_question(asm_qn.qn, new_asm_id, asm_qn.pos)
          dm = DataMap.find_by_data_type_and_old_data_id(qn.class.to_s, coding_qns_attrs['include_sol_qn_id'])
        end
        dependent_id = dm.new_data_id
      end

      data = JSON.parse!(coding_qns_attrs['data'])
      memory_limit = data['memoryLimitInMB']
      time_limit = data['timeLimitInSec']
      test_limit = data['testLimit']
      data.delete('language')
      data.delete('memoryLimitInMB')
      data.delete('timeLimitInSec')
      data.delete('testLimit')

      new_qn = Assessment::CodingQuestion.create!({
                                                      creator_id: coding_qns_attrs['creator_id'],
                                                      title: coding_qns_attrs['title'],
                                                      description: coding_qns_attrs['description'],
                                                      max_grade: coding_qns_attrs['max_grade'],
                                                      dependent_id:dependent_id,
                                                      language_id: ProgrammingLanguage.first.id,
                                                      test_limit: test_limit,
                                                      memory_limit: memory_limit,
                                                      time_limit: time_limit,
                                                      auto_graded: coding_qns_attrs['is_auto_grading'],
                                                      created_at: coding_qns_attrs['created_at'],
                                                      updated_at: coding_qns_attrs['updated_at']
                                                  }, :without_protection => true)


      qa = QuestionAssessment.create!({ assessment_id: new_asm_id,
                                        question_id: new_qn.question.id,
                                        position: pos
                                      }, :without_protection => true)


      DataMap.create({data_type: qn.class.to_s, old_data_id: qn.id, new_data_id: new_qn.question.id },
                     :without_protection => true)

      if coding_qns_attrs['staff_comments'] && coding_qns_attrs['staff_comments'] != ''
        topic = CommentTopic.create!({
                                         course_id: qa.assessment.course_id,
                                         topic_id: new_qn.question.id,
                                         topic_type: new_qn.question.class.to_s
                                     }, :without_protection => true)
        Comment.create({
                           text: coding_qns_attrs['staff_comments'],
                           commentable_id: new_qn.question.id,
                           commentable_type: new_qn.question.class.to_s,
                           comment_topic_id: topic.id
                       })
      end
    end

    def migrate_questions
      AsmQn.includes(:qn).all.each do |asm_qn|
        qn = asm_qn.qn
        #check if question is migrated
        if DataMap.find_by_data_type_and_old_data_id(asm_qn.qn_type, asm_qn.qn_id)
          next
        end
        new_asm = DataMap.find_by_data_type_and_old_data_id(asm_qn.asm_type, asm_qn.asm_id)
        unless new_asm
          next
        end
        new_asm_id = new_asm.new_data_id
        case asm_qn['qn_type'].to_sym
          when :Mcq
            migrate_mcq_question(qn, new_asm_id, asm_qn.pos)
          when :Question
            migrate_text_question(qn, new_asm_id, asm_qn.pos)
          when :CodingQuestion
            migrate_coding_question(qn, new_asm_id, asm_qn.pos)
          else
            raise StandardError, "Unknown qn_type: #{q['qn_type']}"
        end
      end
    end

    def migrate_missions
      Assessment::Mission
      migrated = Mission.joins("INNER JOIN data_maps dm ON dm.old_data_id = missions.id and dm.data_type = 'Mission'")
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

        DataMap.create({data_type: 'Mission', old_data_id: attrs['id'], new_data_id: new_mission.assessment.id},
                       :without_protection => true)
      end

    end

    def migrate_trainings
      Assessment::Training

      migrated = Training.joins("INNER JOIN data_maps dm ON dm.old_data_id = trainings.id and dm.data_type = 'Training'")
      (Training.all - migrated).each do |t|
        attrs = t.attributes

        # silence bonus_cutoff < open_at validation
        # That'sbm because some rows in the db have the open_at value set
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

        DataMap.create({data_type: 'Training', old_data_id: attrs['id'], new_data_id: new_training.assessment.id },
                       :without_protection => true)
      end
    end

    def migrate_answers
      (Submission.all + TrainingSubmission.all).each do |s|
        class_s = s.class.to_s
        new_sbm_id = DataMap.find_by_data_type_and_old_data_id(class_s, s.id).new_data_id
        new_asm_id = DataMap.find_by_data_type_and_old_data_id(@sbm_asm_type[class_s], s.asm_id).new_data_id

        s.sbm_answers.includes(:answer).each do |sbm_answer|
          a_type = sbm_answer['answer_type']
          ans = sbm_answer.answer
          #if answer is already migrated
          if DataMap.find_by_data_type_and_old_data_id(a_type, ans.id)
            next
          end
          qn_dm = DataMap.find_by_data_type_and_old_data_id(@ans_type_to_qn[a_type], ans.qn_id)

          unless qn_dm
            puts "Cannot find corresponding question with id #{ans.qn_id} for std answer #{ans.id}"
            next
          end
          new_qn_id = qn_dm.new_data_id
          answer_value = ans.respond_to?(:text) ? ans.text : nil
          answer_value = ans.respond_to?(:code) ? ans.code : answer_value

          new_ans = Assessment::Answer.create!({ assessment_id: new_asm_id,
                                                 submission_id: new_sbm_id,
                                                 question_id: new_qn_id,
                                                 std_course_id: ans.std_course_id,
                                                 answer: answer_value,
                                                 result: ans.respond_to?(:result) ? ans.result : nil,
                                                 attempt_left: ans.respond_to?(:test_left) ? ans.test_left : 0,
                                                 finalised: sbm_answer.is_final,
                                                 correct: ans.respond_to?(:is_correct) ? ans.is_correct : false,
                                                 created_at: ans.created_at,
                                                 updated_at: ans.updated_at},
                                               :without_protection => true)

          DataMap.create({data_type: a_type,
                          old_data_id: ans.id,
                          new_data_id: new_ans.id},
                         :without_protection => true)

          options = []

          if a_type == "StdMcqAnswer"
            options << ans.mcq_answer_id
          elsif a_type == "StdMcqAllAnswer"
            options = JSON.parse(ans.selected_choices)
          end

          options.each do |opt|
            dm = DataMap.find_by_data_type_and_old_data_id('mcq_option', opt)
            if dm
              Assessment::AnswerOption.create!({
                                                   answer_id: new_ans.id,
                                                   option_id: dm.new_data_id,
                                               }, :without_protection => true)
            end
          end
        end
      end
    end

    def migrate_submission(sbm, new_asm_id)
      s_attrs = sbm.attributes
      new_sbm = Assessment::Submission.create!({
                                                   assessment_id: new_asm_id,
                                                   std_course_id: s_attrs['std_course_id'],
                                                   status: s_attrs['status'],
                                                   multiplier: s_attrs['multiplier'],

                                                   opened_at: s_attrs['open_at'],
                                                   submitted_at: s_attrs['submit_at'],
                                                   deleted_at: s_attrs['deleted_at'],
                                                   created_at: s_attrs['created_at'],
                                                   updated_at: s_attrs['updated_at'],
                                               }, :without_protection => true)

      DataMap.create!({data_type: sbm.class.to_s, old_data_id: sbm.id, new_data_id: new_sbm.id },
                      :without_protection => true)
    end

    def migrate_submissions
      Assessment::Submission

      mission_sbm_left = Submission.all -
          Submission.joins("INNER JOIN data_maps dm ON dm.old_data_id = submissions.id and dm.data_type = 'Submission'")
      training_sbm_left = TrainingSubmission.all -
          TrainingSubmission.joins("INNER JOIN data_maps dm ON dm.old_data_id = training_submissions.id and dm.data_type = 'TrainingSubmission'")

      (mission_sbm_left + training_sbm_left).each do |s|
        dm = DataMap.find_by_data_type_and_old_data_id(@sbm_asm_type[s.class.to_s], s.asm_id)
        unless dm
          next
        end
        migrate_submission(s, dm.new_data_id)
      end
    end

    def migrate_gradings
      SubmissionGrading.all.each do |sbm_g|
        sbm_type = sbm_g.sbm_type
        sbm_dm = DataMap.find_by_data_type_and_old_data_id(sbm_type, sbm_g.sbm_id)
        unless sbm_dm
          next
        end

        submission = Assessment::Submission.find(sbm_dm.new_data_id)
        grading_attrs = sbm_g.attributes
        grader_id = grading_attrs['grader_id']
        grader_course_id = grading_attrs['grader_course_id']

        g = Assessment::Grading.create!({
                                            submission_id: submission.id,
                                            grader_id: grader_id,
                                            grader_course_id: grader_course_id,
                                            std_course_id: submission.std_course_id,
                                            grade: grading_attrs['total_grade'],
                                            exp: grading_attrs['total_exp'],
                                            exp_transaction_id: sbm_g['exp_transaction_id'],
                                            autograding_refresh: grading_attrs['autograding_refresh'],
                                            created_at: grading_attrs['created_at'],
                                            updated_at: grading_attrs['updated_at']
                                        }, :without_protection => true)


        AnswerGrading.where(:submission_grading_id => sbm_g['id']).each do |answer_g|
          dm = DataMap.find_by_data_type_and_old_data_id(answer_g.student_answer_type, answer_g.student_answer_id)

          unless dm
            next
          end

          answer_g_attrs = answer_g.attributes

          Assessment::AnswerGrading.create!({
                                                answer_id: dm.new_data_id,
                                                grading_id: g.id,
                                                grader_id: grader_id,
                                                grader_course_id: grader_course_id,
                                                grade: answer_g.grade,

                                                created_at: answer_g_attrs['created_at'],
                                                updated_at: answer_g_attrs['updated_at']
                                            },  :without_protection => true)
        end
      end
    end

    def migrate_tags
      AsmTag.all.each do |tag|
        dm = DataMap.find_by_data_type_and_old_data_id(tag['asm_type'], tag['asm_id'])
        unless dm
          next
        end
        asm = Assessment.find_by_id(dm.new_data_id)
        asm.questions.each do |qn|
          qn.tags << Tag.find_by_id(tag['tag_id'])
          qn.save
        end
      end
    end

    def migrate_requirements
      AsmReq.all.each do |asm_req|
        dm = DataMap.find_by_data_type_and_old_data_id(asm_req['asm_type'], asm_req['asm_id'])

        unless dm
          next
        end

        asm = Assessment.find_by_id(dm.new_data_id)
        asm_req.asm = asm
        asm_req.save
      end
    end

    m = Thread.new { migrate_missions }
    t = Thread.new { migrate_trainings }
    [m, t].each(&:join)
    q = Thread.new { migrate_questions }
    s = Thread.new { migrate_submissions }
    [q, s].each(&:join)

    migrate_answers
    migrate_gradings
    migrate_tags
    migrate_requirements
  end
end