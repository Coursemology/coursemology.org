namespace :db do
  desc 'Migrates assessments to the new schema in 20140527151234_assessment_redesign.rb'

  task migrate_assessments: :environment do

    def migrate_mcq_options
      sql = "SELECT ma.id as old_id, creator_id, dm.new_data_id as question_id, text,
              explanation, is_correct as correct, created_at, updated_at
              FROM mcq_answers ma
              INNER JOIN data_maps dm ON dm.data_type = 'McqQuestion' and dm.old_data_id = ma.mcq_id"

      result = ActiveRecord::Base.connection.exec_query(sql)

      result.each do |r|
        old_id = r.delete("old_id")
        new_opt = Assessment::McqOption.create!(r, :without_protection => true)
        DataMap.create({data_type: 'mcq_option', old_data_id: old_id, new_data_id: new_opt.id },
                       :without_protection => true)
      end

    end
    # (qn, new_asm_id)
    def migrate_mcq_question
      sql = "SELECT mcqs.id as old_qn_id, dm.new_data_id as new_asm_id, mcqs.creator_id,
              description, max_grade, mcqs.created_at,
              mcqs.updated_at, select_all, pos FROM asm_qns aq
            INNER JOIN data_maps dm ON aq.asm_id = dm.old_data_id and dm.data_type = aq.asm_type
            INNER JOIN mcqs ON aq.qn_id = mcqs.id and aq.qn_type = 'Mcq'"

      result = ActiveRecord::Base.connection.exec_query(sql)
      result.each do |r|
        old_qn_id = r.delete("old_qn_id")
        pos = r.delete("pos")
        new_asm_id = r.delete("new_asm_id")

        new_qn = Assessment::McqQuestion.create!(r, :without_protection => true)

        QuestionAssessment.create!({ assessment_id: new_asm_id,
                                     question_id: new_qn.question.id,
                                     position: pos
                                   }, :without_protection => true)


        DataMap.create({data_type: 'Mcq', old_data_id: old_qn_id, new_data_id: new_qn.question.id },
                       :without_protection => true)
        #save child id for option
        DataMap.create({data_type: 'McqQuestion', old_data_id: old_qn_id, new_data_id: new_qn.id },
                       :without_protection => true)

      end
    end

    def migrate_text_question
      sql = "SELECT q.id as old_qn_id, title, dm.new_data_id as new_asm_id,
              q.creator_id, description, max_grade, q.created_at,
              q.updated_at, pos FROM asm_qns aq
              INNER JOIN data_maps dm ON aq.asm_id = dm.old_data_id and dm.data_type = aq.asm_type
              INNER JOIN questions q ON aq.qn_id = q.id and aq.qn_type = 'Question'"

      result = ActiveRecord::Base.connection.exec_query(sql)
      result.each do |r|
        old_qn_id = r.delete("old_qn_id")
        pos = r.delete("pos")
        new_asm_id = r.delete("new_asm_id")

        new_qn = Assessment::GeneralQuestion.create!(r, :without_protection => true)

        QuestionAssessment.create!({ assessment_id: new_asm_id,
                                     question_id: new_qn.question.id,
                                     position: pos
                                   }, :without_protection => true)


        DataMap.create({data_type: 'Question', old_data_id: old_qn_id, new_data_id: new_qn.question.id },
                       :without_protection => true)

      end
    end

    def migrate_coding_question
      # noop
      require '/Users/Raymond/Documents/NUS_Study/FYP/coursemology/app/models/assessment/coding_question'

      sql = "SELECT q.id as old_qn_id, dm.new_data_id as new_asm_id,
              q.creator_id, title, data, include_sol_qn_id as dependent_id, description, max_grade,
              q.created_at, q.updated_at, pos, is_auto_grading as auto_graded, staff_comments
            FROM asm_qns aq
            INNER JOIN data_maps dm ON aq.asm_id = dm.old_data_id and dm.data_type = aq.asm_type
            INNER JOIN coding_questions q ON aq.qn_id = q.id and aq.qn_type = 'CodingQuestion'"

      result = ActiveRecord::Base.connection.exec_query(sql)
      result.each do |r|
        old_qn_id = r.delete("old_qn_id")
        pos = r.delete("pos")
        new_asm_id = r.delete("new_asm_id")
        data = JSON.parse!(r["data"])
        r["memory_limit"] = data.delete("memoryLimitInMB")
        r["time_limit"] = data.delete("timeLimitInSec")
        r["attempt_limit"] = data.delete("testLimit")
        r["template"] = data.delete("prefill")
        r["append_code"] = data.delete("included")
        data.delete("type")
        data.delete("language")
        data["private"] = data.delete("privateTests") || []
        data["public"] = data.delete("publicTests") || []
        data["eval"] = data.delete("evalTests") || []
        r["language_id"] = ProgrammingLanguage.first.id
        r["tests"] = JSON.generate(data)
        r.delete("data")


        new_qn = Assessment::CodingQuestion.create!(r, :without_protection => true)
        QuestionAssessment.create!({ assessment_id: new_asm_id,
                                     question_id: new_qn.question.id,
                                     position: pos
                                   }, :without_protection => true)


        DataMap.create({data_type: "CodingQuestion", old_data_id: old_qn_id, new_data_id: new_qn.question.id },
                       :without_protection => true)
      end

      #fix dependency
      sql = "UPDATE assessment_questions AS aq
              INNER JOIN data_maps dm ON aq.dependent_id = dm.old_data_id and dm.data_type = 'CodingQuestion'
              SET aq.dependent_id = dm.new_data_id"
      ActiveRecord::Base.connection.execute(sql)
      #update training coding questions to be auto graded
      sql = "UPDATE assessment_coding_questions acq
            INNER JOIN assessment_questions aq
            ON acq.id = aq.as_question_id and aq.as_question_type = 'Assessment::CodingQuestion'
            INNER JOIN question_assessments qa ON qa.question_id = aq.id
            INNER JOIN assessments a ON a.id = qa.assessment_id and a.as_assessment_type = 'Assessment::Training'
            SET acq.auto_graded = 1"
      ActiveRecord::Base.connection.execute(sql)
    end

    def migrate_questions
      migrate_mcq_question
      migrate_mcq_options
      migrate_text_question
      migrate_coding_question
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
                                                      comment_per_qn: attrs['comment_per_qn'],

                                                      dependent_id: attrs['dependent_id'],
                                                      display_mode_id: attrs['display_mode'],
                                                  }, :without_protection => true)

        DataMap.create({data_type: 'Mission', old_data_id: attrs['id'], new_data_id: new_mission.assessment.id},
                       :without_protection => true)
        # dir = "#{Rails.root}/Mission/#{attrs['id']}/files/"
        # if Dir.exist?(dir)
        #   Dir.foreach(dir) do |item|
        #     next if item == '.' or item == '..'
        #
        #
        #   end
        # end
      end

      # def self.get_asm_file_path(assign)
      #   "#{Rails.root}/#{assign.class.to_s}/#{assign.id}/files/"
      # end
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

      #fix dependency
      sql = "UPDATE assessments AS aq
              INNER JOIN data_maps dm ON aq.dependent_id = dm.old_data_id and dm.data_type = 'Mission'
              SET aq.dependent_id = dm.new_data_id"
      ActiveRecord::Base.connection.execute(sql)

      #fix tabs
      sql = "UPDATE tabs set owner_type = 'Assessment::Training' where owner_type = 'Training'"
      ActiveRecord::Base.connection.execute(sql)
    end

    def migrate_mission_sbms
      Assessment::Submission
      sql = "SELECT s.id as old_sbm_id,
              dm.new_data_id as assessment_id, std_course_id,
              status, open_at as opened_at, submit_at as submitted_at, deleted_at,
              created_at, updated_at  FROM submissions s INNER JOIN data_maps dm ON
              s.mission_id = dm.old_data_id and dm.data_type = 'Mission'"

      result = ActiveRecord::Base.connection.execute(sql).to_a
      columns = "(assessment_id, std_course_id, status, opened_at, submitted_at, deleted_at, created_at, updated_at)"
      t = (result.count / 1000.0).ceil
      t.times do |i|
        e = (i + 1) * 1000 - 1
        old_ids = []
        values = []
        result[i*1000..e].each do |r|
          old_ids << r.first
          values << "(#{r[1..-1].map{|x| x.is_a?(Time) ? x.strftime("%Y-%m-%d %H:%M:%S") : x }.map(&:inspect).map{|x| x == "nil" ? 'NULL' : x }.join(",")})"
        end
        sql = "INSERT INTO assessment_submissions #{columns} VALUES #{values.join(", ")}"
        first_id = ActiveRecord::Base.connection.insert(sql)
        dm_values = []
        old_ids.each_with_index do |o, no|
          dm_values << "('Submission', #{o}, #{no + first_id})"
        end
        dm_sql = "INSERT INTO data_maps (data_type, old_data_id, new_data_id) VALUES #{dm_values.join(", ")}"
        ActiveRecord::Base.connection.insert(dm_sql)
      end
    end

    def migrate_training_sbms
      sql = "SELECT s.id as old_sbm_id, dm.new_data_id as assessment_id,
              std_course_id, status, multiplier, open_at as opened_at,
              submit_at as submitted_at, deleted_at, created_at, updated_at
            FROM training_submissions s INNER JOIN data_maps dm
            ON s.training_id = dm.old_data_id and dm.data_type = 'Training'"


      result = ActiveRecord::Base.connection.execute(sql).to_a
      columns = "(assessment_id, std_course_id, status, multiplier, opened_at, submitted_at, deleted_at, created_at, updated_at)"
      t = (result.count / 1000.0).ceil
      t.times do |i|
        e = (i + 1) * 1000 - 1
        old_ids = []
        values = []
        result[i*1000..e].each do |r|
          old_ids << r.first
          values << "(#{r[1..-1].map{|x| x.is_a?(Time) ? x.strftime("%Y-%m-%d %H:%M:%S") : x }.map(&:inspect).map{|x| x == "nil" ? 'NULL' : x }.join(",")})"
        end
        sql = "INSERT INTO assessment_submissions #{columns} VALUES #{values.join(", ")}"
        first_id = ActiveRecord::Base.connection.insert(sql)
        dm_values = []
        old_ids.each_with_index do |o, no|
          dm_values << "('TrainingSubmission', #{o}, #{no + first_id})"
        end
        dm_sql = "INSERT INTO data_maps (data_type, old_data_id, new_data_id) VALUES #{dm_values.join(", ")}"
        ActiveRecord::Base.connection.insert(dm_sql)
      end
    end

    def migrate_submissions
      Assessment::Submission
      migrate_mission_sbms
      migrate_training_sbms
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

    def prepare_values_for_db(a)
      a.map{|x| x.is_a?(Time) ? x.strftime("%Y-%m-%d %H:%M:%S") : x }.map(&:inspect).map{|x| x == "nil" ? 'NULL' : x }
    end

    def migrate_text_answers
      mysql = "SELECT sqa.id as old_answer_id, new_sbm_id as submission_id, new_qn_id as question_id,
                sqa.std_course_id as std_course_id, sqa.text as content,
                is_final as finalised, sqa.created_at as created_at, sqa.updated_at as updated_at
              FROM sbm_answers sba
                INNER JOIN (SELECT sa.*, dm.new_data_id as new_qn_id FROM std_answers sa
                  INNER JOIN data_maps dm ON dm.old_data_id = sa.question_id and dm.data_type = 'Question') sqa
                ON sba.answer_id = sqa.id and sba.answer_type = 'StdAnswer'
                INNER JOIN(SELECT s.*, dms.new_data_id as new_sbm_id from submissions s
                  INNER JOIN data_maps dms ON dms.old_data_id = s.id and dms.data_type = 'Submission') ss
                ON ss.id = sba.sbm_id and sba.sbm_type = 'Submission'"
      result = ActiveRecord::Base.connection.execute(mysql).to_a
      ga_columns = "(created_at, updated_at)"
      a_columns = "(submission_id, question_id, std_course_id, content, finalised, created_at, updated_at, as_answer_id, as_answer_type)"
      t = (result.count / 1000.0).ceil
      t.times do |i|
        e = (i + 1) * 1000 - 1
        old_ids = []
        values = []
        #child table
        result[i*1000..e].each do |r|
          old_ids << r.first
          values << "(#{prepare_values_for_db(r[-2..-1]).join(",")})"
        end
        sql = "INSERT INTO assessment_general_answers #{ga_columns} VALUES #{values.join(", ")}"
        first_id = ActiveRecord::Base.connection.insert(sql)
        parent_values = []

        result[i*1000..e].each_with_index do |r, pind|
          parent_values << "(#{prepare_values_for_db(r[1..-1]).join(",")},#{first_id + pind}, 'Assessment::GeneralAnswer')"
        end

        sql = "INSERT INTO assessment_answers #{a_columns} VALUES #{parent_values.join(", ")}"
        first_id = ActiveRecord::Base.connection.insert(sql)

        dm_values = []
        old_ids.each_with_index do |o, no|
          dm_values << "('StdAnswer', #{o}, #{no + first_id})"
        end


        dm_sql = "INSERT INTO data_maps (data_type, old_data_id, new_data_id) VALUES #{dm_values.join(", ")}"
        ActiveRecord::Base.connection.insert(dm_sql)
      end
    end

    def migrate_mcq_answers
      sql = "SELECT sqa.id as old_answer_id, ddm.new_data_id as new_opt_id, new_sbm_id as submission_id, new_qn_id as question_id,
             sqa.std_course_id as std_course_id, is_final as finalised, amo.correct, sqa.created_at as created_at, sqa.updated_at as updated_at
            FROM sbm_answers sba
            INNER JOIN
            (SELECT sa.*, dm.new_data_id as new_qn_id FROM std_mcq_answers sa
              INNER JOIN data_maps dm
              ON dm.old_data_id = sa.mcq_id and dm.data_type = 'Mcq') sqa
            ON sba.answer_id = sqa.id and sba.answer_type = 'StdMcqAnswer'
            INNER JOIN
            (SELECT s.*, dms.new_data_id as new_sbm_id from training_submissions s INNER JOIN data_maps dms ON dms.old_data_id = s.id and dms.data_type = 'TrainingSubmission') ss
            ON ss.id = sba.sbm_id and sba.sbm_type = 'TrainingSubmission'
            INNER JOIN data_maps ddm ON ddm.old_data_id = sqa.mcq_answer_id and ddm.data_type = 'mcq_option'
            INNER JOIN assessment_mcq_options amo ON amo.id = ddm.new_data_id"

      result = ActiveRecord::Base.connection.execute(sql).to_a
      ma_columns = "(created_at, updated_at)"
      a_columns = "(submission_id, question_id, std_course_id, finalised, correct, created_at, updated_at, as_answer_id, as_answer_type)"
      ao_columns = "(answer_id, option_id, created_at, updated_at)"
      t = (result.count / 1000.0).ceil
      t.times do |i|
        e = (i + 1) * 1000 - 1
        old_ids = []
        opt_ids = []
        values = []
        dates = []

        result[i*1000..e].each do |r|
          old_ids << r.first
          opt_ids << r.second
          dates << prepare_values_for_db(r[-2..-1])
          values << "(#{dates.last.join(",")})"
        end

        sql = "INSERT INTO assessment_mcq_answers #{ma_columns} VALUES #{values.join(", ")}"
        first_id = ActiveRecord::Base.connection.insert(sql)
        ao_values = []
        opt_ids.each_with_index do |o, ind|
          ao_values << "(#{first_id + ind}, #{o}, #{dates[ind].join(",")})"
        end

        sql = "INSERT INTO assessment_answer_options #{ao_columns} VALUES #{ao_values.join(", ")}"
        ActiveRecord::Base.connection.insert(sql)

        parent_values = []

        result[i*1000..e].each_with_index do |r, ind|
          parent_values << "(#{prepare_values_for_db(r[2..-1]).join(",")},#{first_id + ind}, 'Assessment::McqAnswer')"
        end

        sql = "INSERT INTO assessment_answers #{a_columns} VALUES #{parent_values.join(", ")}"
        first_id = ActiveRecord::Base.connection.insert(sql)

        dm_values = []
        old_ids.each_with_index do |o, no|
          dm_values << "('StdMcqAnswer', #{o}, #{no + first_id})"
        end


        dm_sql = "INSERT INTO data_maps (data_type, old_data_id, new_data_id) VALUES #{dm_values.join(", ")}"
        ActiveRecord::Base.connection.insert(dm_sql)
      end
    end

    def migrate_mcq_all_answers
      sql = "SELECT sqa.id as old_answer_id, selected_choices, new_sbm_id as submission_id, new_qn_id as question_id,
             sqa.std_course_id as std_course_id, is_final as finalised, sqa.created_at as created_at, sqa.updated_at as updated_at
            FROM sbm_answers sba
            INNER JOIN
            (SELECT sa.*, dm.new_data_id as new_qn_id FROM std_mcq_all_answers sa
              INNER JOIN data_maps dm
              ON dm.old_data_id = sa.mcq_id and dm.data_type = 'Mcq') sqa
            ON sba.answer_id = sqa.id and sba.answer_type = 'StdMcqAllAnswer'
            INNER JOIN
            (SELECT s.*, dms.new_data_id as new_sbm_id from training_submissions s INNER JOIN data_maps dms ON dms.old_data_id = s.id and dms.data_type = 'TrainingSubmission') ss
            ON ss.id = sba.sbm_id and sba.sbm_type = 'TrainingSubmission'"

      result = ActiveRecord::Base.connection.execute(sql).to_a
      ma_columns = "(created_at, updated_at)"
      a_columns = "(submission_id, question_id, std_course_id, finalised, created_at, updated_at, as_answer_id, as_answer_type)"
      ao_columns = "(answer_id, option_id, created_at, updated_at)"
      t = (result.count / 1000.0).ceil
      t.times do |i|
        e = (i + 1) * 1000 - 1
        old_ids = []
        opt_ids = []
        values = []
        dates = []

        result[i*1000..e].each do |r|
          old_ids << r.first
          opt_ids << eval(r.second)
          dates << prepare_values_for_db(r[-2..-1])
          values << "(#{dates.last.join(",")})"
        end

        sql = "INSERT INTO assessment_mcq_answers #{ma_columns} VALUES #{values.join(", ")}"
        first_id = ActiveRecord::Base.connection.insert(sql)
        ao_values = []
        opt_ids.each_with_index do |o, ind|
          o.each do |opt|
            ao_values << "(#{first_id + ind}, #{opt}, #{dates[ind].join(",")})"
          end
        end

        sql = "INSERT INTO assessment_answer_options #{ao_columns} VALUES #{ao_values.join(", ")}"
        ActiveRecord::Base.connection.insert(sql)

        parent_values = []

        result[i*1000..e].each_with_index do |r, ind|
          parent_values << "(#{prepare_values_for_db(r[2..-1]).join(",")},#{first_id + ind}, 'Assessment::McqAnswer')"
        end

        sql = "INSERT INTO assessment_answers #{a_columns} VALUES #{parent_values.join(", ")}"
        first_id = ActiveRecord::Base.connection.insert(sql)

        dm_values = []
        old_ids.each_with_index do |o, no|
          dm_values << "('StdMcqAllAnswer', #{o}, #{no + first_id})"
        end


        dm_sql = "INSERT INTO data_maps (data_type, old_data_id, new_data_id) VALUES #{dm_values.join(", ")}"
        ActiveRecord::Base.connection.insert(dm_sql)
      end

      sql = "UPDATE assessment_answer_options AS aao
              INNER JOIN data_maps dm ON aao.option_id = dm.old_data_id and dm.data_type = 'mcq_option'
              SET aao.option_id = dm.new_data_id"
      ActiveRecord::Base.connection.execute(sql)

    end

    def migrate_coding_answers
      mysql = "SELECT sqa.id as old_answer_id, dmm.new_data_id as submission_id, new_qn_id as question_id,
              sqa.std_course_id as std_course_id, sqa.code as content, is_final as finalised,
              is_correct as correct, test_left as attempt_left,
              sqa.created_at as created_at, sqa.updated_at as updated_at, result
              FROM sbm_answers sba
              INNER JOIN (SELECT sa.*, dm.new_data_id as new_qn_id FROM std_coding_answers sa
                INNER JOIN data_maps dm ON dm.old_data_id = sa.qn_id and dm.data_type = 'CodingQuestion') sqa
              ON sba.answer_id = sqa.id and sba.answer_type = 'StdCodingAnswer'
              INNER JOIN data_maps dmm ON dmm.old_data_id = sba.sbm_id and sba.sbm_type = dmm.data_type"
      result = ActiveRecord::Base.connection.execute(mysql).to_a
      ga_columns = "(created_at, updated_at, result)"
      a_columns = "(submission_id, question_id, std_course_id, content, finalised, correct, attempt_left, created_at, updated_at, as_answer_id, as_answer_type)"
      bulk_size = 100.0
      t = (result.count / bulk_size).ceil
      t.times do |i|
        e = (i + 1) * bulk_size - 1
        old_ids = []
        values = []
        #child table
        result[i*bulk_size..e].each do |r|
          old_ids << r.first
          values << "(#{prepare_values_for_db(r[-3..-1]).join(",")})"
        end
        sql = "INSERT INTO assessment_coding_answers #{ga_columns} VALUES #{values.join(", ")}"
        first_id = ActiveRecord::Base.connection.insert(sql)
        parent_values = []

        result[i*bulk_size..e].each_with_index do |r, pind|
          parent_values << "(#{prepare_values_for_db(r[1..-2]).join(",")},#{first_id + pind}, 'Assessment::CodingAnswer')"
        end

        sql = "INSERT INTO assessment_answers #{a_columns} VALUES #{parent_values.join(", ")}"
        first_id = ActiveRecord::Base.connection.insert(sql)

        dm_values = []
        old_ids.each_with_index do |o, no|
          dm_values << "('StdCodingAnswer', #{o}, #{no + first_id})"
        end


        dm_sql = "INSERT INTO data_maps (data_type, old_data_id, new_data_id) VALUES #{dm_values.join(", ")}"
        ActiveRecord::Base.connection.insert(dm_sql)
      end
    end

    def migrate_answers
      migrate_text_answers
      migrate_mcq_all_answers
      migrate_mcq_answers
      migrate_coding_answers
    end

    def migrate_sbm_gradings
      sql = "SELECT sg.id as old_grade_id, dm.new_data_id as submission_id, grader_id,
                grader_course_id, ass.std_course_id, total_grade as grade, total_exp as exp,
                exp_transaction_id, autograding_refresh, sg.created_at, sg.updated_at
              FROM submission_gradings sg
              INNER JOIN data_maps dm ON dm.data_type = sg.sbm_type and dm.old_data_id = sg.sbm_id
              INNER JOIN assessment_submissions ass ON ass.id = dm.new_data_id"

      result = ActiveRecord::Base.connection.execute(sql).to_a
      columns = "(submission_id, grader_id, grader_course_id, std_course_id, grade, exp, exp_transaction_id, autograding_refresh, created_at, updated_at)"
      t = (result.count / 1000.0).ceil
      t.times do |i|
        e = (i + 1) * 1000 - 1
        old_ids = []
        values = []
        result[i*1000..e].each do |r|
          old_ids << r.first
          values << "(#{prepare_values_for_db(r[1..-1]).join(",")})"
        end
        sql = "INSERT INTO assessment_gradings #{columns} VALUES #{values.join(", ")}"
        first_id = ActiveRecord::Base.connection.insert(sql)
        dm_values = []
        old_ids.each_with_index do |o, no|
          dm_values << "('Grading', #{o}, #{no + first_id})"
        end
        dm_sql = "INSERT INTO data_maps (data_type, old_data_id, new_data_id) VALUES #{dm_values.join(", ")}"
        ActiveRecord::Base.connection.insert(dm_sql)
      end
    end

    def migrate_answer_gradings
      sql = "SELECT dm.new_data_id as answer_id, dmm.new_data_id as grading_id, agg.grader_id, agg.grader_course_id, ag.grade, ag.created_at, ag.updated_at
            FROM answer_gradings ag
            INNER JOIN data_maps dm ON ag.student_answer_id = dm.old_data_id AND ag.student_answer_type = dm.data_type
            INNER JOIN data_maps dmm ON dmm.old_data_id = ag.submission_grading_id AND dmm.data_type = 'Grading'
            INNER JOIN assessment_gradings agg ON agg.id = dmm.new_data_id"

      result = ActiveRecord::Base.connection.execute(sql).to_a
      columns = "(answer_id, grading_id, grader_id, grader_course_id, grade, created_at, updated_at)"
      t = (result.count / 1000.0).ceil
      t.times do |i|
        e = (i + 1) * 1000 - 1
        values = []
        result[i*1000..e].each do |r|
          values << "(#{prepare_values_for_db(r[0..-1]).join(",")})"
        end
        sql = "INSERT INTO assessment_answer_gradings #{columns} VALUES #{values.join(", ")}"
        ActiveRecord::Base.connection.insert(sql)
      end
    end

    def migrate_missing_ag
      sql = "SELECT assessment_answers.id as answer_id, grading_id, grader_id, grader_course_id, grade, created_at, updated_at
              FROM assessment_answers
              INNER JOIN
              (SELECT ag.id as grading_id, ag.grade as grade, grader_id, grader_course_id, ag.submission_id FROM assessments a
                INNER JOIN assessment_submissions aas ON a.id = aas.assessment_id
                INNER JOIN assessment_gradings ag ON aas.id = ag.submission_id
                WHERE a.as_assessment_type = 'Assessment::Mission') asf
              ON asf.submission_id = assessment_answers.submission_id
              WHERE assessment_answers.id NOT IN (
              SELECT aax.id
              FROM assessment_answer_gradings aag
              INNER JOIN assessment_answers aax ON aag.answer_id = aax.id)"

      result = ActiveRecord::Base.connection.execute(sql).to_a
      columns = "(answer_id, grading_id, grader_id, grader_course_id, grade, created_at, updated_at)"
      t = (result.count / 1000.0).ceil
      t.times do |i|
        e = (i + 1) * 1000 - 1
        values = []
        result[i*1000..e].each do |r|
          values << "(#{prepare_values_for_db(r[0..-1]).join(",")})"
        end
        sql = "INSERT INTO assessment_answer_gradings #{columns} VALUES #{values.join(", ")}"
        ActiveRecord::Base.connection.insert(sql)
      end
    end

    def fix_mcq_all_answer
      sql = "SELECT answer_id, c, correct_count, select_count FROM
              (SELECT amq.id as mcq_id, SUM(amo.correct) as c FROM assessment_mcq_questions amq
              INNER JOIN assessment_questions aq ON amq.id = aq.as_question_id AND aq.as_question_type = 'Assessment::McqQuestion'
              INNER JOIN assessment_mcq_options amo ON amo.question_id = amq.id
              WHERE select_all = 1
              GROUP BY amo.question_id) xxx INNER JOIN
              (SELECT amaa.id as answer_id, mcq_a_id, amaa.question_id, SUM(amo.correct) as correct_count, COUNT(aao.option_id) as select_count
              FROM (SELECT aa.*, ama.id as mcq_a_id FROM assessment_mcq_answers ama INNER JOIN assessment_answers aa ON aa.as_answer_id = ama.id AND aa.as_answer_type = 'Assessment::McqAnswer') amaa
              INNER JOIN assessment_answer_options aao ON amaa.mcq_a_id = aao.answer_id
              INNER JOIN assessment_mcq_options amo ON aao.option_id = amo.id
              GROUP BY aao.answer_id) yyy
              ON xxx.mcq_id = yyy.question_id"
      result = ActiveRecord::Base.connection.execute(sql).to_a
      result.each do |r|
        sql = "UPDATE assessment_answers SET correct = #{(r[1] == r[2] and r[2] == r[3]) ? 1 : 0} WHERE id = #{r[0]}"
        ActiveRecord::Base.connection.execute(sql)
      end
    end

    def migrate_gradings
      migrate_sbm_gradings
      migrate_answer_gradings
      migrate_missing_ag
    end

    def migrate_seen_by_user
      #assessments
      sql = "UPDATE seen_by_users AS sbu INNER JOIN data_maps dm ON
              dm.old_data_id = sbu.obj_id AND dm.data_type = sbu.obj_type
              SET sbu.obj_id = dm.new_data_id, sbu.obj_type = 'Assessment'
              WHERE dm.data_type = 'Mission' OR dm.data_type = 'Training'"
      ActiveRecord::Base.connection.execute(sql)

      #submissions
      sql = "UPDATE seen_by_users AS sbu INNER JOIN data_maps dm ON
              dm.old_data_id = sbu.obj_id AND dm.data_type = sbu.obj_type
              SET sbu.obj_id = dm.new_data_id, sbu.obj_type = 'Assessment::Submission'
              WHERE dm.data_type = 'Submission' OR dm.data_type = 'TrainingSubmission'"
      ActiveRecord::Base.connection.execute(sql)

    end

    def migrate_files_ownership
      sql ="UPDATE file_uploads as fu INNER JOIN data_maps dm ON
            dm.old_data_id = fu.owner_id AND dm.data_type = fu.owner_type
            SET owner_id = new_data_id, owner_type = 'Assessment'
            WHERE owner_type IN ('Mission', 'Training')"
      ActiveRecord::Base.connection.execute(sql)

      sql = "UPDATE file_uploads as fu INNER JOIN data_maps dm ON
            dm.old_data_id = fu.owner_id AND dm.data_type = fu.owner_type
            SET owner_id = new_data_id, owner_type = 'Assessment::Submission'
            WHERE data_type = 'Submission'"
      ActiveRecord::Base.connection.execute(sql)
    end

    def migrate_other_affected_components
      #questions
      sql = comment_query('comment_topics',{id: "topic_id", type: "topic_type"} ,'Assessment::Question', ['CodingQuestion', 'Mcq'])
      ActiveRecord::Base.connection.execute(sql)
      sql = comment_query('comment_subscriptions',{id: "topic_id", type: "topic_type"}, 'Assessment::Question', ['CodingQuestion', 'Mcq'])
      ActiveRecord::Base.connection.execute(sql)
      sql = comment_query('comments',{id: "commentable_id", type: "commentable_type"}, 'Assessment::Question', ['CodingQuestion', 'Mcq'])
      ActiveRecord::Base.connection.execute(sql)
      sql = comment_query('pending_comments',{id: "answer_id", type: "answer_type"}, 'Assessment::Question', ['CodingQuestion', 'Mcq'])
      ActiveRecord::Base.connection.execute(sql)
      #answers

      old_types = ['StdAnswer', 'StdCodingAnswer']
      new_type = 'Assessment::Answer'
      sql = comment_query('comment_topics',{id: "topic_id", type: "topic_type"} ,new_type, old_types)
      ActiveRecord::Base.connection.execute(sql)
      sql = comment_query('comment_subscriptions',{id: "topic_id", type: "topic_type"} ,new_type, old_types)
      ActiveRecord::Base.connection.execute(sql)
      sql = comment_query('comments',{id: "commentable_id", type: "commentable_type"}, new_type, old_types)
      ActiveRecord::Base.connection.execute(sql)
      sql = comment_query('annotations',{id: "annotable_id", type: "annotable_type	"}, new_type, old_types)
      ActiveRecord::Base.connection.execute(sql)
      sql = comment_query('pending_comments',{id: "answer_id", type: "answer_type"}, new_type, old_types)
      ActiveRecord::Base.connection.execute(sql)

      #assessments
      sql = comment_query('comment_topics', {id: "topic_id", type: "topic_type"},'Assessment::Submission', ['Submission'])
      ActiveRecord::Base.connection.execute(sql)
      sql = comment_query('comment_subscriptions', {id: "topic_id", type: "topic_type"},'Assessment::Submission', ['Submission'])
      ActiveRecord::Base.connection.execute(sql)
      sql = comment_query('comments', {id: "commentable_id", type: "commentable_type"},'Assessment::Submission', ['Submission'])
      ActiveRecord::Base.connection.execute(sql)
      sql = comment_query('pending_actions', {id: "item_id", type: "item_type"},'Assessment', ['Training', 'Mission'])
      ActiveRecord::Base.connection.execute(sql)
      sql = comment_query('activities', {id: "obj_id", type: "obj_type"},'Assessment', ['Training', 'Mission'])
      ActiveRecord::Base.connection.execute(sql)
    end

    def comment_query(table, key, new_type, old_types)
      "UPDATE #{table} as ct INNER JOIN data_maps dm ON
              dm.old_data_id = ct.#{key[:id]} AND dm.data_type = ct.#{key[:type]}
              SET #{key[:id]} = new_data_id, #{key[:type]} = '#{new_type}'
              WHERE #{key[:type]} IN (#{old_types.map(&:inspect).join(",")})"
    end

    def update_activity_link
      Activity.all.each do |a|
        if a.obj_type == 'Assessment'
          a.obj_url = a.obj.get_path
          a.save
        end
      end
    end

    t_1 = Time.now
    t = Time.now
    migrate_missions
    puts "Finished Mission, took: ", (Time.now - t)
    t = Time.now
    migrate_trainings
    puts "Finished Training, took: ", (Time.now - t)
    t = Time.now
    migrate_questions
    puts "Finished Questions, took: ", (Time.now - t)
    t = Time.now
    migrate_submissions
    puts "Finished Submissions, took: ", (Time.now - t)
    t = Time.now
    migrate_answers
    puts "Finished Answers, took: ", (Time.now - t)
    t = Time.now
    migrate_gradings
    puts "Finished gradings, took: ", (Time.now - t)
    t = Time.now
    fix_mcq_all_answer
    puts "Finished fix mcq answer, took: ", (Time.now - t)
    migrate_tags
    migrate_requirements
    migrate_seen_by_user
    migrate_files_ownership
    migrate_other_affected_components
    update_activity_link
    puts "Total Time: ", (Time.now - t_1)
  end
end