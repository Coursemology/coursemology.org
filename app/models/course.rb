class Course < ActiveRecord::Base
  acts_as_paranoid

  attr_accessible :creator_id, :description, :logo_url, :title

  belongs_to :creator, class_name: "User"

  has_many :missions, dependent: :destroy
  has_many :announcements, dependent: :destroy
  has_many :user_courses, dependent: :destroy
  has_many :trainings, dependent: :destroy

  has_many :users, through: :user_courses

  has_many :std_answers, through: :user_courses
  has_many :std_coding_answers, through: :user_courses

  has_many :submissions, through: :user_courses
  has_many :training_submissions, through: :user_courses

  has_many :activities, dependent: :destroy

  has_many :levels, dependent: :destroy
  has_many :achievements, dependent: :destroy

  has_many :enroll_requests, dependent: :destroy

  has_many :tags, dependent: :destroy
  has_many :tag_groups, dependent: :destroy

  has_many :course_themes, dependent: :destroy  # currently only has one though

  has_many :tutorial_groups, dependent: :destroy
  has_many :file_uploads, as: :owner

  def asms
    missions + trainings
  end

  def lect_courses
    user_courses.joins(:role).where('roles.name' => 'lecturer')
  end

  def student_courses
    std = Role.find_by_name("student")
    self.user_courses.where(role_id: std.id)
  end

  def get_pending_gradings(curr_user_course)
    if curr_user_course.is_lecturer?
      @pending_gradings = submissions.where(status:"submitted").order(:submit_at)
    else
      @pending_gradings = submissions.where(status:"submitted",std_course_id:curr_user_course.get_my_stds).order(:submit_at)
    end
  end

  def get_all_answers
    std_answers + std_coding_answers
  end

  def get_pending_comments
     self.get_all_answers.select { |ans| ans.pending? }
  end

  def get_all_comments
    self.get_all_answers.select { |ans| ans.last_commented_at }
  end

end
