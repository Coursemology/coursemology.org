namespace :db do
  desc "Fill database with sample data"

  task gen_fake_data: :environment do
    puts "Add fake lecturer & courses"

    std_role = Role.find_by_name("student")

    students = []
    5.times do |n|
      lec = gen_user(Role.find_by_name("lecturer"))
      10.times do |m|
        course = gen_course(lec)
      end
      students << lec
    end

    50.times do |n|
      norm = gen_user(Role.find_by_name("normal"))
      students << norm
    end

    admin = User.find(1)
    puts "Gen admin's fake data"
    10.times do
      course = gen_course(admin)
      20.times do
        gen_announcement(admin, course)
      end
      20.times do |i|
        asm = gen_assignment(admin, course, rand(-1..1), true)
        asm.order = i * 2
        10.times do |j|
          mcq = gen_mcq(admin, asm)
          mcq.order = j
          selected = false
          5.times do |k|
            is_correct = !selected && (rand(5 - k) == 0)
            if is_correct
              selected = true
            end
            gen_answer(admin, mcq, is_correct)
          end
        end
        asm.update_grade
      end
      20.times do |i|
        asm = gen_assignment(admin, course, rand(-1..1), false)
        asm.order = i * 2 + 1
        rand(1..5).times do |j|
          wq = gen_wq(admin, asm)
          wq.order = j
        end
        asm.update_grade
      end

      students.shuffle.first(rand(20..30)).each do |std|
        uc = UserCourse.create!(
          course_id: course.id,
          user_id: std.id,
          role_id: std_role.id
        )
      end
    end
  end

  def gen_user(role)
    name = Faker::Name.name
    email = Faker::Internet.safe_email
    password = "password"
    return User.create!(
      name: name,
      email: email,
      password: password,
      password_confirmation: password,
      system_role_id: role.id
    )
  end

  def gen_course(user)
    logos = [
      'http://jedi.ddns.comp.nus.edu.sg/public/images/jfdi_logo.png',
      'http://geovengers.mrluo.per.sg/public/images/jfdi_logo.png',
      'https://s3.amazonaws.com/coursera/topics/gamification/small-icon.hover.png',
      'https://s3.amazonaws.com/coursera/topics/design/small-icon.hover.png',
      'https://s3.amazonaws.com/coursera/topics/behavioralecon/small-icon.hover.png',
      'https://s3.amazonaws.com/coursera/topics/wh1300/small-icon.hover.png',
      'https://s3.amazonaws.com/coursera/topics/operations/small-icon.hover.png',
      'https://coursera-course-photos.s3.amazonaws.com/86/eff310c9f5ab16a770c3ca6c13bef3/green_courselogo.jpg'
    ]

    lec_role = Role.find_by_name("lecturer")

    course = Course.create!(
      title: Faker::Lorem.words(rand(3..4)).join(' ').capitalize + '.',
      description: Faker::Lorem.paragraphs(rand(1..3)).join('<br/>'),
      logo_url: logos.sample,
      creator_id: user.id
    )

    UserCourse.create!(
      course_id: course.id,
      user_id: user.id,
      role_id: lec_role.id
    )

    return course
  end

  def gen_announcement(user, course)
    return Announcement.create!(
      title: Faker::Lorem.words(rand(3..4)).join(' ').capitalize + '.',
      description: Faker::Lorem.paragraphs(rand(1..3)).join('<br/>'),
      creator_id: user.id,
      course_id: course.id
    )
  end

  def gen_assignment(user, course, open_state, is_mcq)
    if open_state == -1 # closed
      open_at = DateTime.now.prev_month
      close_at = DateTime.now.prev_day
    elsif
      open_at = DateTime.now.prev_day
      close_at = DateTime.now.next_month
    elsif
      open_at = DateTime.now.next_month
      close_at = DateTime.now.next_month(2)
    end

    return Assignment.create!(
      title: Faker::Lorem.words(rand(3..4)).join(' ').capitalize + '.',
      description: Faker::Lorem.paragraphs(rand(1..3)).join('<br/>'),
      creator_id: user.id,
      course_id: course.id,
      attempt_limit: rand(5),
      exp: rand(100) * 1000,
      open_at: open_at,
      close_at: close_at,
      auto_graded: is_mcq
    )
  end

  def gen_mcq(user, assignment)
    return Mcq.create!(
      description: Faker::Lorem.paragraph(rand(5..7)),
      creator_id: user.id,
      assignment_id: assignment.id,
      max_grade: 1
    )
  end

  def gen_wq(user, assignment)
    return Question.create!(
      description: Faker::Lorem.paragraph(rand(5..7)),
      creator_id: user.id,
      assignment_id: assignment.id,
      max_grade: 10
    )
  end

  def gen_answer(user, question, is_correct)
    return question.answers.build(
      creator_id: user.id,
      text: Faker::Lorem.sentence(),
      explanation: Faker::Lorem.paragraph(),
      is_correct: is_correct
    ).save
  end

end
