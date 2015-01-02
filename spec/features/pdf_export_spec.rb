require 'rails_helper'

include Warden::Test::Helpers
Warden.test_mode!

describe "PDFExport", :type => :feature do
  
  let!(:lecturer)           { FactoryGirl.create(:lecturer) }
  let!(:student)            { FactoryGirl.create(:student) }
  let!(:course)             { FactoryGirl.create(:course, :with_student, creator: lecturer, student: student) }
  let!(:user_course)        { student.get_user_course(course) }

  let(:completed_mission)   { FactoryGirl.create(:mission, :with_general_questions, :with_coding_questions, :completed, course: course, title: "Completed Mission", creator: lecturer, grader: lecturer, user_course: user_course) }
  let(:new_mission)         { FactoryGirl.create(:mission, :with_general_questions, :with_coding_questions, course: course, title: "New Mission", creator: lecturer) }
  let(:completed_training)  { FactoryGirl.create(:training, :with_mcq_questions, :completed, course: course, title: "Completed Training", creator: lecturer, user_course: user_course) }
  let(:new_training)        { FactoryGirl.create(:training, :with_mcq_questions, course: course, title: "New Training", creator: lecturer) }

  let(:review_completed_mission_path) do
    submission = completed_mission.last_submission(user_course)
    course_assessment_submission_grading_path(course, completed_mission.assessment, submission, submission.get_final_grading)
  end

  let(:review_completed_training_path) do
    course_assessment_submission_path(course, completed_training.assessment, completed_training.last_submission(user_course))
  end

  def set_pdf_export(type, setting)
    pdf_export = course.pdf_export(type)
    pdf_export.display = setting
    pdf_export.save
  end

  before do
    allow(UserMailer).to receive_messages(delay: double("UserMailer.delay").as_null_object)
    login_as(student, :scope => :user)
  end
  after { Warden.test_reset! }

  describe "configuration" do

    let(:new_course) { FactoryGirl.create(:course, creator: lecturer) }

    it "has PDF export disabled by default" do
      expect(new_course.pdf_export_enabled?('mission')).to be_falsy
      expect(new_course.pdf_export_enabled?('training')).to be_falsy
    end

    shared_examples "for testing configuration using type" do |type|

      context "when PDF export for #{type.pluralize.titlecase} is disabled" do

        before { set_pdf_export(type, false) }

        it "hides PDF export form on list of #{type.pluralize.titlecase}" do
          visit send("course_assessment_#{type.pluralize}_path", course)
          expect(page).not_to have_selector(".#{type}-export-options")
        end

        it "hides PDF export form on review of completed #{type.titlecase}" do
          visit send("review_completed_#{type}_path")
          expect(page).not_to have_selector(".#{type}-export-options")
        end

        it "prevents PDFs export for #{type.pluralize.titlecase} when invoked manually" do
          visit send("review_completed_#{type}_path") + ".pdf"
          expect(page.status_code).not_to equal(200)
          visit File.join(send("course_assessment_#{type.pluralize}_path", course), "dump_pdfs")
          expect(page.current_path).to eq(access_denied_path)
        end

      end

      context "when PDF export for #{type.pluralize.titlecase} is enabled" do

        before { set_pdf_export(type, true) }

        it "shows PDF export form on list of #{type.pluralize.titlecase}" do
          visit send("course_assessment_#{type.pluralize}_path", course)
          expect(page).to have_selector(".#{type}-export-options")
        end

        it "shows PDF export form on review of completed #{type.titlecase}" do
          visit send("review_completed_#{type}_path")
          expect(page).to have_selector(".#{type}-export-options")
        end

      end

    end

    include_examples "for testing configuration using type", "mission"
    include_examples "for testing configuration using type", "training"

  end

  context "when PDF export is enabled" do

    before do
      set_pdf_export('training', true)
      set_pdf_export('mission', true)
    end

    # The shared examples in this block require these variables to be set in the surrounding context:
    #
    # assessment    the assessment being exported (i.e. completed_training or completed_mission)
    # pdf_path      path to generate PDF file
    # review_path   path to web page containing form for PDF export
    # 
    shared_examples "for testing controllers" do

      context "when HTML output for WickedPDF is turned off" do

        before { WickedPdf.config[:show_as_html] = false }

        it "responds with a PDF of MIME type application/pdf" do
          visit pdf_path
          expect(page.response_headers['Content-Type']).to include("application/pdf")
        end

        it "respects requested disposition type" do
          visit review_path
          click_on("Save as PDF")
          expect(page.response_headers['Content-Disposition']).to include("attachment")

          visit review_path
          click_on("View as PDF")
          expect(page.response_headers['Content-Disposition']).to include("inline")
        end

      end

      context "when HTML output for WickedPDF is turned on" do

        before { WickedPdf.config[:show_as_html] = true }

        it "respects the option to show questions on separate pages" do
          visit review_path
          uncheck("add_page_breaks")
          click_on("Save as PDF")
          expect(page).not_to have_selector(".page")

          visit review_path
          check("add_page_breaks")
          click_on("Save as PDF")
          # Only test minimum as Missions have an extra summary page.
          expect(page).to have_selector(".page", minimum: assessment.questions.size)
          pages = page.all(".page")
          expect(pages[0]).to have_text(assessment.questions[0].description, count: 1)
          expect(pages[1]).to have_text(assessment.questions[1].description, count: 1)
        end

        it "exports pictures (if any) using complete URLs" do
          visit pdf_path
          page.all("img").each do |image|
            expect(image['src']).to start_with("http").or start_with("file")
          end
        end

      end

    end

    describe "TrainingSubmissionsController#show" do

      let(:assessment)  { completed_training }
      let(:pdf_path)    { review_completed_training_path + ".pdf" }
      let(:review_path) { review_completed_training_path }

      include_examples "for testing controllers"

      context "when HTML output for WickedPDF is turned on" do

        before { WickedPdf.config[:show_as_html] = true }

        it "respects the option to hide Submitted At timestamps" do
          visit review_path
          uncheck("hide_timestamps")
          click_on("Save as PDF")
          expect(page).to have_text("Submitted at")

          visit review_path
          check("hide_timestamps")
          click_on("Save as PDF")
          expect(page).not_to have_text("Submitted at")
        end

        it "respects the option to hide wrong attempts" do
          answer = assessment.last_submission(user_course).answers.first
          answer.correct = false
          answer.save

          visit review_path
          uncheck("hide_wrong_attempts")
          click_on("Save as PDF")
          expect(page).to have_selector(".mcq-ans-incorrect")

          visit review_path
          check("hide_wrong_attempts")
          click_on("Save as PDF")
          expect(page).not_to have_selector(".mcq-ans-incorrect")
        end

      end

    end

    describe "GradingsController#show" do

      let(:assessment)  { completed_mission }
      let(:pdf_path)    { review_completed_mission_path + ".pdf" }
      let(:review_path) { review_completed_mission_path }

      include_examples "for testing controllers"

      context "when HTML output for WickedPDF is turned on" do

        before { WickedPdf.config[:show_as_html] = true }

        it "respects the option to hide comments" do
          comment = assessment.last_submission(user_course).answers.first.comment_topic.comments.first
          comment.text = "Comment for PDFExport feature test suite."
          comment.save

          visit review_path
          uncheck("hide_comments")
          click_on("Save as PDF")
          expect(page).to have_text(comment.text)

          visit review_path
          check("hide_comments")
          click_on("Save as PDF")
          expect(page).not_to have_text(comment.text)
        end

        it "respects the option to hide code annotations" do
          annotation = assessment.last_submission(user_course).answers.where(as_answer_type: "Assessment::CodingAnswer").first.annotations.first
          annotation.text = "Annotation for PDFExport feature test suite."
          annotation.save

          visit review_path
          uncheck("hide_annotations")
          click_on("Save as PDF")
          expect(page).to have_text(annotation.text)

          visit review_path
          check("hide_annotations")
          click_on("Save as PDF")
          expect(page).not_to have_text(annotation.text)
        end

      end

    end

    describe "AssessmentsController#dump_pdfs" do

      let(:second_completed_mission)  { FactoryGirl.create(:mission, :with_general_questions, :with_coding_questions, :completed, course: course, title: "Second Completed Mission", creator: lecturer, grader: lecturer, user_course: user_course) }
      let(:second_completed_training) { FactoryGirl.create(:training, :with_mcq_questions, :completed, course: course, title: "Second Completed Training", creator: lecturer, user_course: user_course) }
      let(:missions_dump_pdfs_path)   { File.join(course_assessment_missions_path(course), "dump_pdfs") }
      let(:trainings_dump_pdfs_path)  { File.join(course_assessment_trainings_path(course), "dump_pdfs") }

      shared_examples "for testing dump_pdfs using type" do |type|

        it "responds with a ZIP of MIME type application/zip for #{type.pluralize.titlecase}" do
          visit send("#{type.pluralize}_dump_pdfs_path")
          expect(page.response_headers['Content-Type']).to include("application/zip")
        end

        it "responds with a ZIP containing the correct number of PDFs for #{type.pluralize.titlecase}" do
          # Set up at least two completed assessments.
          send("completed_#{type}")
          send("second_completed_#{type}")

          correct_count = course.assessments.published.send(type).count do |assessment|
            submission = assessment.last_submission(user_course)
            submission && submission.graded?
          end

          visit send("#{type.pluralize}_dump_pdfs_path")
          temp_file = Tempfile.new("zip")
          begin
            temp_file << page.source
            temp_file.close
            Zip::ZipFile.open(temp_file.path) do |zip|
              zip_count = zip.count { |entry| entry.file? }
              expect(zip_count).to equal(correct_count)
            end
          ensure
            temp_file.close
            temp_file.unlink
          end
        end

      end

      include_examples "for testing dump_pdfs using type", "mission"
      include_examples "for testing dump_pdfs using type", "training"

    end

  end

end

