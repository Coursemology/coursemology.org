require 'factory_girl'

FactoryGirl.define do
  factory :user do
    name "user"
    sequence(:email) { |n| "user#{n}@test.com" }
    password "foobar"
    password_confirmation "foobar"
    time_zone "Singapore"
    after(:build) do |user|
      user.confirmed_at = Time.now.to_s[0..-7]
    end
  end

  factory :admin, parent: :user do
    name "admin"
    sequence(:email) { |n| "admin#{n}@example.org" }
    after(:build) do |user|
      user.system_role_id = 1
      #user.confirmed_at = Time.now.to_s[0..-7]
    end
  end

  factory :student, parent: :user do
    name "student"
    sequence(:email) { |n| "student#{n}@example.org" }
    after(:build) do |user|
      user.system_role_id = 5
    end
  end

  factory :lecturer, parent: :user do
    name "lecturer"
    sequence(:email) { |n| "lecturer#{n}@example.org" }
    after(:build) do |user|
      user.system_role_id = 3
    end
  end

  factory :course do
    title "Programming"
    description "It's a programming course"
    start_at Time.now
    end_at 1.day.from_now
    after(:create) do |course, evaluator|
      if evaluator.creator
        course.creator = evaluator.creator
        user_course = course.user_courses.build()
        user_course.course = course
        user_course.user = evaluator.creator
        user_course.role = Role.find_by_name(:lecturer)
        user_course.save
      end
      course.levels.create(level: 0, exp_threshold: 0)
    end

    trait :with_student do
      ignore do
        student { create(:student) }
      end
      after(:create) do |course, evaluator|
        course.enrol_user(evaluator.student, Role.find_by_name(:student))
      end
    end
  end

  factory :training, class: Assessment::Training do
    title "Danger Room"
    description "Fight sentinels."
    exp 200
    bonus_exp 0
    open_at Time.now
    bonus_cutoff_at Time.now
    published true
    after(:build) do |training, evaluator|
      training.course_id = evaluator.course.try(:id)
    end

    trait :with_mcq_questions do
      ignore do
        creator { create(:lecturer) }
        mcq_question_count 2
      end
      after(:build) do |training, evaluator|
        evaluator.mcq_question_count.times do
          training.questions << create(:mcq_question, creator: evaluator.creator).question
        end
      end
    end

    trait :completed do
      ignore do
        user_course { create(:user_course) }
      end
      after(:create) do |training, evaluator|
        submission = create(:submission_with_answers, assessment: training.assessment, std_course: evaluator.user_course)
        submission.set_graded
        submission.save
      end
    end
  end

  factory :announcement do
    title "sample announcement"
    description "sample content"
    publish_at Time.now
    expiry_at 3.day.from_now
    after(:build) do |announcement, evaluator|
      announcement.course_id = evaluator.course.try(:id)
      announcement.creator_id = evaluator.creator.try(:id)
      announcement.expiry_at = evaluator.expiry_at if evaluator.expiry_at
    end
  end

  factory :lesson_plan_entry do
    entry_type 0
    title 'My Lecture'
    location 'LT26'
    description 'Teaching an awesome class. How cool is that?'
    start_at 1.day.from_now
    end_at 3.days.from_now
  end

  factory :mission, class: Assessment::Mission do
    title 'Factory mission'
    description 'Description for factory-generated Mission'
    open_at Time.now
    close_at 1.day.from_now
    exp 10
    published true
    after(:build) do |mission, evaluator|
      mission.title = evaluator.title
      mission.course_id = evaluator.course.try(:id)
    end

    trait :with_general_questions do
      ignore do
        creator { create(:lecturer) }
        general_question_count 2
      end
      after(:build) do |mission, evaluator|
        evaluator.general_question_count.times do
          mission.questions << create(:general_question, creator: evaluator.creator).question
        end
      end
    end

    trait :with_auto_graded_exact_general_questions do
      ignore do
        creator { create(:lecturer) }
        general_question_count 2
      end
      after(:build) do |mission, evaluator|
        evaluator.general_question_count.times do
          mission.questions << create(:general_question,
                                      :auto_grading_exact,
                                      creator: evaluator.creator).question
        end
      end
    end

    trait :with_auto_graded_keyword_general_questions do
      ignore do
        creator { create(:lecturer) }
        general_question_count 2
      end
      after(:build) do |mission, evaluator|
        evaluator.general_question_count.times do
          mission.questions << create(:general_question,
                                      :auto_grading_keyword,
                                      creator: evaluator.creator).question
        end
      end
    end

    trait :with_coding_questions do
      ignore do
        creator { create(:lecturer) }
        coding_question_count 2
      end
      after(:build) do |mission, evaluator|
        evaluator.coding_question_count.times do
          mission.questions << create(:coding_question, creator: evaluator.creator).question
        end
      end
    end

    trait :completed do
      ignore do
        grader { create(:lecturer) }
        user_course { create(:user_course) }
      end
      after(:create) do |mission, evaluator|
        submission = create(:submission_with_answers, assessment: mission.assessment, std_course: evaluator.user_course)
        grading = create(:grading, submission: submission, grader: evaluator.grader, student: evaluator.user_course)
        submission.set_graded
        submission.save
      end
    end
  end

  factory :achievement do
    title "I won!"
    description "Yahoo"
    after(:build) do |achievement, evaluator|
      achievement.course_id = evaluator.course.try(:id)
      achievement.creator_id = evaluator.creator.try(:id)
    end
  end

  factory :user_course do
    # belongs_to associations
    role Role.find_by_name(:student)
    association :user, factory: :student
    course
    level { course.levels.first }
  end

  factory :submission, class: Assessment::Submission do
    # belongs_to associations
    assessment { create(:training).assessment }
    association :std_course, factory: :user_course

    factory :submission_with_answers do
      after(:create) do |submission, evaluator|
        # has_many associations
        # Placed in after(:create) callback as build_initial_answers needs submission.id
        submission.build_initial_answers
        submission.answers.each do |a|
          # Add comments
          a.comment_topic = build(:comment_topic, :with_comments, topic: a,
              course: submission.std_course.course, user_course: submission.std_course)
          # Perform additional initialization
          answer = a.specific
          case answer
          when Assessment::McqAnswer
            answer.options << answer.question.specific.options.first
          when Assessment::CodingAnswer
            answer.content = "# Answer for a factory-generated Coding question."
            answer.annotations << create(:annotation, user_course: submission.std_course, annotable: answer)
          end
          answer.save
        end
      end
    end
  end

  factory :answer_grading, class: Assessment::AnswerGrading do
    # belongs_to associations
    association :grader, factory: :lecturer
    grader_course { grading.grader_course }
    answer { grading.submission.answers.first }
    grading

    # attributes
    grade 1
  end

  factory :grading, class: Assessment::Grading do
    # belongs_to associations
    association :grader, factory: :lecturer
    grader_course { grader.user_courses.find_by_course_id(student.course.id) }
    association :student, factory: :user_course
    # TODO: exp_transaction
    submission

    # attributes
    grade 1
    exp 0

    after(:build) do |grading, evaluator|
      # has_many associations
      grading.submission.answers.each do |a|
        grading.answer_gradings << build(:answer_grading, grader: grading.grader, answer: a, grading: grading)
      end
    end
  end

  factory :mcq_option, class: Assessment::McqOption do
    # belongs_to associations
    question { create(:mcq_question).question }

    # attributes
    text "Text for MCQ Option"
    explanation "Explanation for MCQ Option"
    correct true
  end

  factory :mcq_question, class: Assessment::McqQuestion do
    # belongs_to associations
    association :creator, factory: :lecturer

    # attributes
    title "Factory-Generated MCQ Question"
    description "Description for factory-generated MCQ question."
    max_grade 1
    staff_comments "Staff comment for factory-generated MCQ question."

    after(:build) do |mcq_question, evaluator|
      # has_many associations
      mcq_question.options << build(:mcq_option, question: mcq_question, correct: false)
      mcq_question.options << build(:mcq_option, question: mcq_question)
    end
  end

  factory :general_question, class: Assessment::GeneralQuestion do
    # belongs_to associations
    association :creator, factory: :lecturer

    # attributes
    title "Factory-Generated General Question"
    description "Description for factory-generated General question."
    max_grade 1
    staff_comments "Staff comment for factory-generated General question."

    trait :auto_grading_exact do
      auto_graded true
      auto_grading_type :exact
      ignore do
        option_count 2
      end
      after(:build) do |question, evaluator|
        evaluator.option_count.times do
          question.auto_grading_exact_options << build(:auto_grading_exact_option)
        end
      end
    end

    trait :auto_grading_keyword do
      auto_graded true
      auto_grading_type :keyword
      ignore do
        option_count 2
      end
      after(:build) do |question, evaluator|
        evaluator.option_count.times do
          question.auto_grading_keyword_options << build(:auto_grading_keyword_option)
        end
      end
    end
  end

  factory :auto_grading_exact_option, class: Assessment::AutoGradingExactOption do
    correct true
    answer 'Some answer'
    explanation 'Some explanation'
  end

  factory :auto_grading_keyword_option, class: Assessment::AutoGradingKeywordOption do
    keyword 'keyword1'
    score 2
  end

  factory :coding_question, class: Assessment::CodingQuestion do
    # belongs_to associations
    association :creator, factory: :lecturer
    language ProgrammingLanguage.first

    # attributes
    title "Factory-Generated Coding Question"
    description "Description for factory-generated Coding question."
    max_grade 1
    staff_comments "Staff comment for factory-generated Coding question."
    auto_graded false
    tests '{"private":[],"public":[{"expression":"1","expected":"1"}],"eval":[]}'
    template ""
    pre_include ""
    append_code ""
  end

  factory :comment_topic do
    # belongs_to associations
    association :topic, factory: :submission
    course

    trait :with_comments do
      ignore do
        user_course { create(:user_course) }
        comment_count 2
      end
      after(:build) do |comment_topic, evaluator|
        # has_many associations
        comment_topic.user_courses << evaluator.user_course
        evaluator.comment_count.times do
          comment_topic.comments << build(:comment, user_course: evaluator.user_course,
            commentable: comment_topic.topic, comment_topic: comment_topic)
        end
      end
    end
  end

  factory :comment do
    # belongs_to associations
    user_course
    association :commentable, factory: :submission
    comment_topic

    # attributes
    text "Text for a comment."
  end

  factory :annotation do
    # belongs_to associations
    user_course
    annotable { Assessment::CodingAnswer.create }

    # attributes
    text "Text for an annotation."
    line_start 1
    line_end 1
  end

end
