class AddGraderCourseIdToSubmissionGradings < ActiveRecord::Migration
  def change
    add_column :submission_gradings, :grader_course_id, :integer
    add_index :submission_gradings, :grader_course_id

    SubmissionGrading.all.each do |grading|
      course_id = grading.sbm.std_course.course_id
      user_id = grading.grader_id
      user_course = UserCourse.where(course_id: course_id, user_id:  user_id).first
      if user_course
        grading.grader_course_id = user_course.id
        grading.save
      end
    end
  end
end
