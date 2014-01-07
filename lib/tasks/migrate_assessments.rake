namespace :db do
  desc 'Migrates assessments from the old format to the new structure'

  task migrate_assessments: :environment do
    connection = Assessment::Assessment.connection
    @missions_map = {}
    @trainings_map = {}
    @coding_questions_map = {}
    @coding_answers_map = {}
    @mcq_questions_map = {}
    @mcq_options_map = {}
    @mcq_answers_map = {}
    @text_questions_map = {}
    @text_answers_map = {}
    @mission_submissions_map = {}
    @training_submissions_map = {}

    def migrate_assessment(assessment, type, connection)
      def sanitize(statement, args)
        r = ActiveRecord::Base.send(:sanitize_sql_array, args.empty? ? statement : ([statement] + args))
        puts r
        r
      end

      connection.select_all(sanitize('SELECT * FROM ' + type.to_s + 's WHERE id = ?', [assessment['id']])).each do |item|
        if type == :mission then
          parent = Assessment::Mission.create({
            course_id: item['course_id'],
            creator_id: item['creator_id'],
            title: item['title'],
            description: item['description'],
            file_submission: item['is_file_submission'],
            publish: item['publish'],
            exp: item['exp'],
            max_grade: item['max_grade'],
            open_at: item['open_at'],
            created_at: item['created_at'],
            updated_at: item['updated_at'],
            deleted_at: item['deleted_at'],
            pos: item['pos'],
            dependent_id: item['dependent_id'],
            close_at: item['close_at']
          }, :without_protection => true)

          @missions_map[assessment['id']] = parent.assessment.id
        elsif type == :training then
          parent = Assessment::Training.create({
            course_id: item['course_id'],
            creator_id: item['creator_id'],
            title: item['title'],
            description: item['description'],
            file_submission: item['is_file_submission'],
            publish: item['publish'],
            exp: item['exp'],
            max_grade: item['max_grade'],
            open_at: item['open_at'],
            created_at: item['created_at'],
            updated_at: item['updated_at'],
            deleted_at: item['deleted_at'],
            pos: item['pos'],
            bonus_exp: item['bonus_exp'],
            bonus_cutoff: item['bonus_cutoff']
          }, :without_protection => true)

          @trainings_map[assessment['id']] = parent.assessment.id
        else
          raise StandardError
        end

        # Migrate the questions
        connection.select_all(sanitize('SELECT * from asm_qns WHERE asm_id= ? AND asm_type = ?', [assessment['id'], type])).each do |q|
          case q['qn_type'].to_sym
            when :Mcq
              mcq = connection.select_all(sanitize('SELECT * from mcqs WHERE id = ?', [q['qn_id']])).first
              parent_q = Assessment::McqQuestion.create({
                                                          assessment_id: parent['id'],
                                                          creator_id: mcq['creator_id'],
                                                          description: mcq['description'],
                                                          max_grade: mcq['max_grade'],
                                                          must_select_all: mcq['select_all'],
                                                          created_at: mcq['created_at'],
                                                          updated_at: mcq['updated_at']
                                                       }, :without_protection => true)
              @mcq_questions_map[q['qn_id']] = parent_q.question.id

              connection.select_all(sanitize('SELECT * from mcq_answers WHERE mcq_id = ?', [mcq['id']])).each do |opt|
                opt = Assessment::McqOption.create({
                                               creator_id: opt['creator_id'],
                                               question_id: parent_q.id,
                                               text: opt['text'],
                                               explanation: opt['explanation'],
                                               correct: opt['is_correct'],
                                               created_at: opt['created_at'],
                                               updated_at: opt['updated_at']
                                             }, :without_protection => true)
                @mcq_options_map[opt['id']] = opt.id
              end
            when :Question
              text = connection.select_all(sanitize('SELECT * FROM questions WHERE id = ?', [q['qn_id']])).first
              parent_q = Assessment::TextQuestion.create({
                                                          assessment_id: parent['id'],
                                                          creator_id: text['creator_id'],
                                                          description: text['description'],
                                                          max_grade: text['max_grade'],
                                                          created_at: text['created_at'],
                                                          updated_at: text['updated_at']
                                                         }, :without_protection => true)

              @text_questions_map[q['qn_id']] = parent_q.question.id
            when :CodingQuestion
              code = connection.select_all(sanitize('SELECT * FROM coding_questions WHERE id = ?', [q['qn_id']])).first
              if code['include_sol_qn_id'] != nil && code['include_sol_qn_id'] != 0 then
                if @coding_questions_map[code['include_sol_qn_id']] == nil then
                  raise StandardError
                end
              end
              parent_q = Assessment::CodingQuestion.create({
                                                          assessment_id: parent['id'],
                                                          creator_id: code['creator_id'],
                                                          title: code['step_name'],
                                                          description: code['description'],
                                                          max_grade: code['max_grade'],
                                                          depends_on: code['include_sol_qn_id'] && code['include_sol_qn_id'] != 0 ? coding_questions_map.fetch(code['include_sol_qn_id']) : nil,
                                                          created_at: code['created_at'],
                                                          updated_at: code['updated_at']
                                                         }, :without_protection => true)
              @coding_questions_map[q['qn_id']] = parent_q.question.id
            else
              raise StandardError
          end
        end
      end
    end

    def migrate_submission(s, type, connection)
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

      sbm = Assessment::Submission.create({
                                              assessment_id: assessments_map.fetch(assessment_id),
                                              std_course_id: s['std_course_id'],
                                              status: s['status'],
                                              multiplier: s['multiplier'],
                                              opened_at: s['open_at'],
                                              submitted_at: s['submit_at'],
                                              created_at: s['created_at'],
                                              updated_at: s['updated_at'],
                                              deleted_at: s['deleted_at']
                                          }, :without_protection => true)
      submissions_map[s['id']] = sbm.id

      migrate_answer = lambda do |sbm_answer|
        case sbm_answer['answer_type'].to_sym
          when :StdAnswer
            connection.select_all(sanitize('SELECT * FROM std_answers WHERE id = ?', [sbm_answer['answer_id']])).each do |answer|
              ans = Assessment::TextSubmission.create({
                                                    submission_id: sbm.id,
                                                    question_id: @text_questions_map.fetch(answer['question_id']),
                                                    finalised: sbm_answer['is_final'],

                                                    text: answer['text'],
                                                    created_at: answer['created_at'],
                                                    updated_at: answer['updated_at']
                                                }, :without_protection => true)
              @text_answers_map[sbm_answer['answer_id']] = ans.question_submission.id
            end
          when :StdMcqAnswer
            connection.select_all(sanitize('SELECT * FROM std_mcq_answers WHERE id = ?', [sbm_answer['answer_id']])).each do |answer|
              ans = Assessment::McqSubmission.create({
                                                   submission_id: sbm.id,
                                                   question_id: @mcq_questions_map.fetch(answer['mcq_id']),
                                                   finalised: sbm_answer['is_final'],

                                                   option_id: @mcq_options_map.fetch(answer['mcq_answer_id']),
                                                   created_at: answer['created_at'],
                                                   updated_at: answer['updated_at']
                                               }, :without_protection => true)
              @mcq_answers_map[sbm_answer['answer_id']] = ans.question_submission.id
            end
          when :StdCodingAnswer
            connection.select_all(sanitize('SELECT * FROM std_coding_answers WHERE id = ?', [sbm_answer['answer_id']])).each do |answer|
              ans = Assessment::CodingSubmission.create({
                                                      submission_id: sbm.id,
                                                      question_id: @coding_questions_map.fetch(answer['qn_id']),
                                                      finalised: sbm_answer['is_final'],

                                                      code: answer['code'],
                                                      created_at: answer['created_at'],
                                                      updated_at: answer['updated_at']
                                                  }, :without_protection => true)
              @coding_answers_map[sbm_answer['answer_id']] = ans.question_submission.id
            end
        end
      end

      connection.select_all(sanitize('SELECT * FROM sbm_answers WHERE sbm_type = ? AND sbm_id = ?',
                                     [type == :mission ? :Submission : :TrainingSubmission, s['id']])).each &migrate_answer
    end

    # We directly query the database here because the ActiveRecord models
    # might already be deleted from source control.
    connection.execute('TRUNCATE TABLE assessment_assessments')
    connection.execute('TRUNCATE TABLE assessment_missions')
    connection.execute('TRUNCATE TABLE assessment_trainings')

    connection.execute('TRUNCATE TABLE assessment_questions')
    connection.execute('TRUNCATE TABLE assessment_mcq_questions')
    connection.execute('TRUNCATE TABLE assessment_mcq_options')
    connection.execute('TRUNCATE TABLE assessment_coding_questions')
    connection.execute('TRUNCATE TABLE assessment_text_questions')

    connection.select_all('SELECT * FROM missions').each do |m|
      migrate_assessment(m, :mission, connection)
    end

    connection.select_all('SELECT * FROM trainings').each do |t|
      migrate_assessment(t, :training, connection)
    end

    connection.execute('TRUNCATE TABLE assessment_submissions')
    connection.execute('TRUNCATE TABLE assessment_question_submissions')
    connection.execute('TRUNCATE TABLE assessment_coding_submissions')
    connection.execute('TRUNCATE TABLE assessment_mcq_submissions')
    connection.execute('TRUNCATE TABLE assessment_text_submissions')

    connection.select_all('SELECT * FROM submissions').each do |s|
      migrate_submission(s, :mission, connection)
    end

    connection.select_all('SELECT * FROM training_submissions').each do |s|
      migrate_submission(s, :training, connection)
    end

    connection.execute('TRUNCATE TABLE assessment_gradings')
    connection.select_all('SELECT * FROM submission_gradings').each do |sbm_g|
      case sbm_g['sbm_type'].to_sym
        when :TrainingSubmission
          submission = @training_submissions_map[sbm_g['sbm_id']]
        when :Submission
          submission = @mission_submissions_map[sbm_g['sbm_id']]
        else
          raise StandardError
      end

      connection.select_all(sanitize('SELECT * FROM answer_gradings WHERE submission_grading_id = ?', [sbm_g['id']])).each do |answer_g|
        case answer_g['student_answer_type'].to_sym
          when :StdMcqAnswer
            answer_map = @mcq_answers_map
          when :StdAnswer
            answer_map = @text_answers_map
          when :StdCodingAnswer
            answer_map = @coding_answers_map
          else
            raise StandardError
        end
        Assessment::Grading.create({
                                       question_submission_id: answer_map.fetch(answer_g['student_answer_id']),
                                       grader_id: answer_g['grader_id'] || sbm_g['grader_id'],
                                       grader_course_id: sbm_g['grader_course_id'],
                                       grade: answer_g['grade'],
                                       exp_transaction_id: sbm_g['exp_transaction_id'],
                                       created_at: answer_g['created_at'],
                                       updated_at: answer_g['updated_at']
                                   }, :without_protection => true)
      end
    end

    connection.execute('TRUNCATE TABLE assessment_assessments_tags')
    connection.select_all('SELECT * FROM asm_tags').each do |tag|
      case tag['asm_type'].to_sym
        when :Training
          training = Assessment::Training.find_by_id(@trainings_map[tag['asm_id']])
          training.tags << Tag.find_by_id(tag['tag_id'])

        when :Mission
          mission = Assessment::Mission.find_by_id(@missions_map[tag['asm_id']])
          mission.tags << Tag.find_by_id(tag['tag_id'])
      end
    end

    connection.execute('TRUNCATE TABLE assessment_assessments_requirements')
    connection.select_all('SELECT * FROM asm_reqs').each do |req|
      case req['asm_type'].to_sym
        when :Training
          assessment_id = @trainings_map[req['asm_id']]
        when :Mission
          assessment_id = @missions_map[req['asm_id']]
        else
          raise StandardError
      end

      Assessment::AssessmentRequirement.create({
                                       id: req['id'],
                                       assessment_id: assessment_id,
                                       min_grade: req['min_grade'],
                                       created_at: req['created_at'],
                                       updated_at: req['updated_at']
                                     }, :without_protection => true);
    end
=begin

    @coding_questions_map.each_pair do |key, value|
      connection.exec(sanitize('UPDATE comments SET commentable_type = ?, commentable_id = ? WHERE commentable_type = ? AND commentable_id = ?',
                               ['Assessment::CodingQuestion', value, 'CodingQuestion', key]))

      connection.exec(sanitize('UPDATE comment_topics SET topic_type = ?, topic_id = ? WHERE topic_type = ? AND topic_id = ?',
                               ['Assessment::CodingQuestion', value, 'CodingQuestion', key]))

      connection.exec(sanitize('UPDATE comment_subscriptions SET topic_type = ?, topic_id = ? WHERE topic_type = ? AND topic_id = ?',
                               ['Assessment::CodingQuestion', value, 'CodingQuestion', key]))

      connection.exec(sanitize('UPDATE pending_comments SET answer_type = ?, answer_id = ? WHERE answer_type = ? AND answer_id = ?',
                               ['Assessment::CodingQuestion', value, 'CodingQuestion', key]))
    end

    @text_answers_map.each_pair do |key, value|
      connection.exec(sanitize('UPDATE comments SET commentable_type = ?, commentable_id = ? WHERE commentable_type = ? AND commentable_id = ?',
                               ['Assessment::TextSubmission', value, 'StdAnswer', key]))

      connection.exec(sanitize('UPDATE comment_topics SET topic_type = ?, topic_id = ? WHERE topic_type = ? AND topic_id = ?',
                               ['Assessment::TextSubmission', value, 'StdAnswer', key]))

      connection.exec(sanitize('UPDATE comment_subscriptions SET topic_type = ?, topic_id = ? WHERE topic_type = ? AND topic_id = ?',
                               ['Assessment::TextSubmission', value, 'StdAnswer', key]))

      connection.exec(sanitize('UPDATE pending_comments SET answer_type = ?, answer_id = ? WHERE answer_type = ? AND answer_id = ?',
                               ['Assessment::TextSubmission', value, 'StdAnswer', key]))
    end

    @mcq_questions_map.each_pair do |key, value|
      connection.exec(sanitize('UPDATE comments SET commentable_type = ?, commentable_id = ? WHERE commentable_type = ? AND commentable_id = ?',
                               ['Assessment::McqQuestion', value, 'Mcq', key]))

      connection.exec(sanitize('UPDATE comment_topics SET topic_type = ?, topic_id = ? WHERE topic_type = ? AND topic_id = ?',
                               ['Assessment::McqQuestion', value, 'Mcq', key]))

      connection.exec(sanitize('UPDATE comment_subscriptions SET topic_type = ?, topic_id = ? WHERE topic_type = ? AND topic_id = ?',
                               ['Assessment::McqQuestion', value, 'Mcq', key]))

      connection.exec(sanitize('UPDATE pending_comments SET answer_type = ?, answer_id = ? WHERE answer_type = ? AND answer_id = ?',
                               ['Assessment::McqQuestion', value, 'Mcq', key]))
    end

    @coding_answers_map.each_pair do |key, value|
      connection.exec(sanitize('UPDATE annotations SET annotable_type = ?, annotable_id = ? WHERE annotable_type = ? AND annotable_id = ?',
                      ['Assessment::CodingSubmission', value, 'StdCodingAnswer', key]))

      connection.exec(sanitize('UPDATE comments SET commentable_type = ?, commentable_id = ? WHERE commentable_type = ? AND commentable_id = ?',
                               ['Assessment::CodingSubmission', value, 'StdCodingAnswer', key]))

      connection.exec(sanitize('UPDATE comment_topics SET topic_type = ?, topic_id = ? WHERE topic_type = ? AND topic_id = ?',
                               ['Assessment::CodingSubmission', value, 'StdCodingAnswer', key]))

      connection.exec(sanitize('UPDATE comment_subscriptions SET topic_type = ?, topic_id = ? WHERE topic_type = ? AND topic_id = ?',
                               ['Assessment::CodingSubmission', value, 'StdCodingAnswer', key]))

      connection.exec(sanitize('UPDATE pending_comments SET answer_type = ?, answer_id = ? WHERE answer_type = ? AND answer_id = ?',
                               ['Assessment::CodingSubmission', value, 'StdCodingAnswer', key]))
    end

    @missions_map.each_pair do |key, value|
      connection.exec(sanitize('UPDATE file_uploads SET owner_type = ?, owner_id = ? WHERE owner_type = ? AND owner_id = ?',
                               ['Assessment::Mission', value, 'Mission', key]))
    end

    @mission_submissions_map.each_pair do |key, value|
      connection.exec(sanitize('UPDATE file_uploads SET owner_type = ?, owner_id = ? WHERE owner_type = ? AND owner_id = ?',
                               ['Assessment::Submission', value, 'Submission', key]))
    end

    @trainings_map.each_pair do |key, value|
      @missions_map.each do |key, value|
        connection.exec(sanitize('UPDATE file_uploads SET owner_type = ?, owner_id = ? WHERE owner_type = ? AND owner_id = ?',
                                 ['Assessment::Training', value, 'Training', key]))
      end
    end
=end
  end
end
