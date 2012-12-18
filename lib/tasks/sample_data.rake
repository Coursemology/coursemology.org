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

      10.times do
        gen_announcement(admin, course)
      end

      15.times do |i|
        asm = gen_mission(admin, course, rand(-1..1), false)
        asm.order = i * 2 + 1
        rand(1..5).times do |j|
          wq = gen_wq(admin)
          wq.save
          link_asm_qn(asm, wq, j)
        end
        asm.update_grade
      end

      10.times do |i|
        training = gen_training(admin, course, rand(0..1))
        training.order = i
        rand(5..7).times do |j|
          mcq = gen_mcq(admin)
          link_asm_qn(training, mcq, j)
        end
      end

      10.times do |i|
        quiz = gen_quiz(admin, course, rand(0..1))
        quiz.order = i
        rand(5..7).times do |j|
          mcq = gen_mcq(admin)
          link_asm_qn(quiz, mcq, j)
        end
      end

      20.times do |i|
        lvl = i + 1
        level = gen_level(course, lvl, lvl * lvl * 1000)
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

  def gen_mission(user, course, open_state, is_mcq)
    if open_state == -1 # closed
      open_at = DateTime.now.prev_month
      close_at = DateTime.now.prev_day
    elsif open_state == 0
      open_at = DateTime.now.prev_day
      close_at = DateTime.now.next_month
    elsif
      open_at = DateTime.now.next_month
      close_at = DateTime.now.next_month(2)
    end

    return Mission.create!(
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

  def gen_quiz(user, course, open_state)
    if open_state == -1 # closed
      open_at = DateTime.now.prev_month
      close_at = DateTime.now.prev_day
    elsif open_state == 0
      open_at = DateTime.now.prev_day
      close_at = DateTime.now.next_month
    elsif
      open_at = DateTime.now.next_month
      close_at = DateTime.now.next_month(2)
    end

    return Quiz.create!(
      title: Faker::Lorem.words(rand(3..4)).join(' ').capitalize + '.',
      description: Faker::Lorem.paragraphs(rand(1..3)).join('<br/>'),
      creator_id: user.id,
      course_id: course.id,
      attempt_limit: rand(5),
      exp: rand(100) * 1000,
      open_at: open_at,
      close_at: close_at,
    )
  end

  def gen_training(user, course, open_state)
    if open_state == 0 # opened
      open_at = DateTime.now.prev_day
    elsif
      open_at = DateTime.now.next_month
    end

    return Training.create!(
      title: Faker::Lorem.words(rand(3..4)).join(' ').capitalize + '.',
      description: Faker::Lorem.paragraphs(rand(1..3)).join('<br/>'),
      creator_id: user.id,
      course_id: course.id,
      exp: rand(100) * 1000,
      open_at: open_at,
    )
  end

  def gen_mcq(user)
    mcq = Mcq.create!(
      description: Faker::Lorem.paragraph(rand(5..7)),
      creator_id: user.id,
      max_grade: 1
    )

    selected = false
    5.times do |k|
      is_correct = !selected && (rand(5 - k) == 0)
      if is_correct
        selected = true
      end
      gen_mcq_answer(user, mcq, is_correct)
    end

    return mcq
  end

  def gen_wq(user)
    return Question.create!(
      description: Faker::Lorem.paragraph(rand(5..7)),
      creator_id: user.id,
      max_grade: 10
    )
  end

  def gen_mcq_answer(user, mcq, is_correct)
    return mcq.mcq_answers.build(
      creator_id: user.id,
      text: Faker::Lorem.sentence(),
      explanation: Faker::Lorem.paragraph(),
      is_correct: is_correct
    ).save
  end

  def link_asm_qn(asm, qn, order)
    asm_qn = AsmQn.new
    asm_qn.asm = asm
    asm_qn.qn = qn
    asm_qn.order = order
    return asm_qn.save!
  end

  def gen_level(course, num, exp)
    return Level.create!({
      level: num,
      exp_threshold: exp,
      course_id: course.id
    })
  end
end
