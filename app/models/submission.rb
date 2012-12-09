class Submission < ActiveRecord::Base
  attr_accessible :assignment_id, :attempt, :open_at, :student_id, :submit_at

  belongs_to :assignment
  belongs_to :student, class_name: "User"

  has_many :student_answers

  def self.all_course(course)
    puts 'all ', course.to_json
    subs = Submission.all
    # TODO: filter by course
    return subs
  end

  def self.all_student(course, student)
    subs = Submission.all
    # TODO: filter by student and course
    return subs
  end
end
