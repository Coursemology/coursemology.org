namespace :db do
  desc 'Migrates assessments from the old format to the new structure'

  task migrate_assessments: :environment do
    connection = Assessment::Assessment.connection
    @coding_questions_map = {}

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
                                                          depends_on: code['include_sol_qn_id'] && code['include_sol_qn_id'] != 0 ? coding_questions_map[code['include_sol_qn_id']] : nil,
                                                          created_at: code['created_at'],
                                                          updated_at: code['updated_at']
                                                         }, :without_protection => true)
              @coding_questions_map[q['qn_id']] = parent_q.id
            else
              raise StandardError
          end
        end
      end

      connection.select_all('SELECT * FROM answer_gradings').each do |g|
        Assessment::Grading.create({
                                       id: g.id,
                                       question_submission_id: g.student_answer_id,
                                       grader_id: g.grader_id,
                                       grader_course_id: g.grader_course_id,
                                       grade: g.grade,
                                       comment: g.comment,
                                       created_at: g.created_at,
                                       updated_at: g.updated_at
                                   }).save
      end
    end

    # We directly query the database here because the ActiveRecord models
    # might already be deleted from source control.
    connection.execute('TRUNCATE TABLE assessment_assessments')
    connection.execute('TRUNCATE TABLE assessment_missions')
    connection.execute('TRUNCATE TABLE assessment_trainings')

    connection.execute('TRUNCATE TABLE assessment_gradings')
    connection.execute('TRUNCATE TABLE assessment_questions')
    connection.execute('TRUNCATE TABLE assessment_mcq_questions')
    connection.execute('TRUNCATE TABLE assessment_coding_questions')

    connection.select_all('SELECT * FROM missions').each do |m|
      migrate_assessment(m, :mission, connection)
    end

    connection.select_all('SELECT * FROM trainings').each do |t|
      migrate_assessment(t, :training, connection)
    end
  end
end
