# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

if Role.count == 0
  super_role = Role.create! name: "superuser", title: "Super User"
  Role.create! name: "normal", title: "User"
  Role.create! name: "lecturer", title: "Lecturer"
  Role.create! name: "ta", title: "Teaching Assistant"
  Role.create! name: "student", title: "Student"
end

if Role.count == 5
  Role.create! name: "shared", title: "Previewer"
end

if User.count == 0
  admin = User.create!(name: "Admin", email: "jfdi@academy.com",
                       password: "supersecretpass",
                       password_confirmation: "supersecretpass")
  admin.system_role_id = super_role.id
  admin.skip_confirmation!
  admin.save!
end

if Action.count == 0
  Action.create! text: "attempted", description: "actor attempted obj (assignment)"
  Action.create! text: "commented on", description: "actor commented on object"
  Action.create! text: "created", description: "actor created object (achievement, level)"
  Action.create! text: "earned", description: "actor earned object (achievement, title, level)"
  Action.create! text: "published", description: "actor published object"
  Action.create! text: "replied to", description: "actor replied object"
  Action.create! text: "started", description: "actor started obj (assignment, training)"
end

if ThemeAttribute.count == 0
  ThemeAttribute.create! name: "Background Color",
                         description: "Background color of the page",
                         value_type: "color"
  ThemeAttribute.create! name: "Background Image",
                         description: "Background image. It will be added to the bottom of the page",
                         value_type: "image"
  ThemeAttribute.create! name: "Sidebar Link Color",
                         description: "Color of the navigation links",
                         value_type: "color"
  ThemeAttribute.create! name: "Announcements Icon",
                         description: "Icon for the Announcements navigation link on the sidebar",
                         value_type: "image"
  ThemeAttribute.create! name: "Missions Icon",
                         description: "Icon for the Mission navigation link on the sidebar",
                         value_type: "image"
  ThemeAttribute.create! name: "Trainings Icon",
                         description: "Icon for the Trainings navigation link on the sidebar",
                         value_type: "image"
  ThemeAttribute.create! name: "Submissions Icon",
                         description: "Icon for the Submissions navigation link on the sidebar",
                         value_type: "image"
  ThemeAttribute.create! name: "Leaderboards Icon",
                         description: "Icon for the Leaderboard navigation link on the sidebar",
                         value_type: "image"
end

if ThemeAttribute.count == 8
  ThemeAttribute.create! name: "Custom CSS",
                         description: "Custom style sheet rules",
                         value_type: "text"
end

if PreferableItem.count == 0

  #Missions
  PreferableItem.create! item:          "Mission",
                         item_type:     "Column",
                         name:          "title",
                         default_value: "Mission",
                         description:   "Mission title",
                         default_display: true

  PreferableItem.create! item:          "Mission",
                         item_type:     "Column",
                         name:          "tag",
                         default_value: "Tag",
                         description:   "Mission tags" ,
                         default_display: true

  PreferableItem.create! item:          "Mission",
                         item_type:     "Column",
                         name:          "exp",
                         default_value: "Max Exp",
                         description:   "Mission exp gainable",
                         default_display: true

  PreferableItem.create! item:          "Mission",
                         item_type:     "Column",
                         name:          "award",
                         default_value: "Requirement for",
                         description:   "Requirement for achievement",
                         default_display: true

  PreferableItem.create! item:          "Mission",
                         item_type:     "Column",
                         name:          "start",
                         default_value: "Start Time",
                         description:   "Mission start time",
                         default_display: true

  PreferableItem.create! item:          "Mission",
                         item_type:     "Column",
                         name:          "end",
                         default_value: "End Time",
                         description:   "Mission end time",
                         default_display: true

  #Training
  PreferableItem.create! item:          "Training",
                         item_type:     "Column",
                         name:          "title",
                         default_value: "Training",
                         description:   "Training title",
                         default_display: true

  PreferableItem.create! item:          "Training",
                         item_type:     "Column",
                         name:          "tag",
                         default_value: "Tag",
                         description:   "Training tags",
                         default_display: true

  PreferableItem.create! item:          "Training",
                         item_type:     "Column",
                         name:          "exp",
                         default_value: "Max Exp",
                         description:   "Training exp gainable",
                         default_display: true

  PreferableItem.create! item:          "Training",
                         item_type:     "Column",
                         name:          "award",
                         default_value: "Requirement for",
                         description:   "Requirement for achievement",
                         default_display: true

  PreferableItem.create! item:          "Training",
                         item_type:     "Column",
                         name:          "start",
                         default_value: "Start Time",
                         description:   "Training start time",
                         default_display: true

  PreferableItem.create! item:          "Training",
                         item_type:     "Column",
                         name:          "end",
                         default_value: "End Time",
                         description:   "Training end time",
                         default_display: false

  #SideBar  - students
  PreferableItem.create! item:          "Sidebar",
                         item_type:     "Student",
                         name:          "announcements",
                         default_value: "Announcements",
                         description:   "Course announcements",
                         default_display: true

  PreferableItem.create! item:          "Sidebar",
                         item_type:     "Student",
                         name:          "missions",
                         default_value: "Missions",
                         description:   "Course missions",
                         default_display: true

  PreferableItem.create! item:          "Sidebar",
                         item_type:     "Student",
                         name:          "trainings",
                         default_value: "Trainings",
                         description:   "Course trainings",
                         default_display: true

  PreferableItem.create! item:          "Sidebar",
                         item_type:     "Student",
                         name:          "submissions",
                         default_value: "Submissions",
                         description:   "All submissions",
                         default_display: true

  PreferableItem.create! item:          "Sidebar",
                         item_type:     "Student",
                         name:          "achievements",
                         default_value: "Achievements",
                         description:   "Show all achievements",
                         default_display: true

  PreferableItem.create! item:          "Sidebar",
                         item_type:     "Student",
                         name:          "leaderboard",
                         default_value: "Leaderboard",
                         description:   "Show leaderboard",
                         default_display: true

  PreferableItem.create! item:          "Sidebar",
                         item_type:     "Student",
                         name:          "students",
                         default_value: "Students",
                         description:   "Show all students",
                         default_display: true
end

if PreferableItem.count == 19

  PreferableItem.create! item:          "Training",
                         item_type:     "Time",
                         name:          "time_format",
                         default_value: "%d-%m-%Y",
                         description:   "Training time display format",
                         default_display: true

  PreferableItem.create! item:          "Mission",
                         item_type:     "Time",
                         name:          "time_format",
                         default_value: "%d-%m-%Y",
                         description:   "Mission time display format",
                         default_display: true

end

if PreferableItem.count == 21
  #notification email preference

  PreferableItem.create! item:          "Email",
                         item_type:     "Course",
                         name:          "new_comment",
                         default_value: "New Comment",
                         description:   "Notify user when someone commented on his/her thread",
                         default_display: true

  PreferableItem.create! item:          "Email",
                         item_type:     "Course",
                         name:          "new_grading",
                         default_value: "New Grading",
                         description:   "Notify student for new available mission grading",
                         default_display: true

  PreferableItem.create! item:          "Email",
                         item_type:     "Course",
                         name:          "new_submission",
                         default_value: "New Submission",
                         description:   "Notify student's tutor for new mission submission",
                         default_display: true

  PreferableItem.create! item:          "Email",
                         item_type:     "Course",
                         name:          "new_student",
                         default_value: "New Student",
                         description:   "Notify students when their enrollment request is approved",
                         default_display: true

  PreferableItem.create! item:          "Email",
                         item_type:     "Course",
                         name:          "new_enroll_request",
                         default_value: "New Enroll Request",
                         description:   "Notify lecturer(s) for new enrollment request",
                         default_display: true

  PreferableItem.create! item:          "Email",
                         item_type:     "Course",
                         name:          "new_announcement",
                         default_value: "New Announcement",
                         description:   "Notify all staff and students for new announcement",
                         default_display: true

  PreferableItem.create! item:          "Email",
                         item_type:     "Course",
                         name:          "new_mission",
                         default_value: "New Mission",
                         description:   "Notify all staff and students for new mission available",
                         default_display: true

  PreferableItem.create! item:          "Email",
                         item_type:     "Course",
                         name:          "new_training",
                         default_value: "New Training",
                         description:   "Notify all staff and students for new training available",
                         default_display: true

  PreferableItem.create! item:          "Email",
                         item_type:     "Course",
                         name:          "mission_due",
                         default_value: "Mission Reminder",
                         description:   "Mission due reminder for students who didn't submit yet",
                         default_display: true

end

if PreferableItem.count == 30
  PreferableItem.create! item:          "Sidebar",
                         item_type:     "Student",
                         name:          "comments",
                         default_value: "Comments",
                         description:   "Show comments summary",
                         default_display: true
end

if PreferableItem.count == 31
  PreferableItem.create! item:          "Mcq",
                         item_type:     "AutoGrader",
                         name:          "title",
                         default_value: "default",
                         description:   "The Auto Grader used to grade MCQ Question",
                         default_display: true

end

if Action.count == 7
  Action.create! text: "reached",
                 description: "actor reached obj (lvl)"
end

if PreferableItem.count == 32
  PreferableItem.create! item:          "Training",
                         item_type:     "Re-attempt",
                         name:          "title",
                         default_value: "20",
                         description:   "Enable Re-attempt allows students to do training again to get a fraction of the full EXP.",
                         default_display: true
end

if PreferableItem.count == 33
  PreferableItem.create! item:          "Training",
                         item_type:     "Column",
                         name:          "bonus-exp",
                         default_value: "Bonus EXP",
                         description:   "Bonus exp for finishing early",
                         default_display: true

  PreferableItem.create! item:          "Training",
                         item_type:     "Column",
                         name:          "bonus-cutoff",
                         default_value: "Bonus Cutoff",
                         description:   "Bonus cutoff time",
                         default_display: true
end

if PreferableItem.count == 35

  PreferableItem.create!  item:          "Leaderboard",
                          item_type:     "Display",
                          name:          "leaders",
                          default_value: "10",
                          description:   "Number of students to show in leaderboard",
                          default_display: true

  PreferableItem.create! item:            "CourseHome",
                         item_type:       "Section",
                         name:            "announcements",
                         default_value:   "Announcements",
                         description:     "Show recent announcements in course home page",
                         default_display: true

  PreferableItem.create! item:            "CourseHome",
                         item_type:       "Section",
                         name:            "activities",
                         default_value:   "Notable Happenings",
                         description:     "Show recent student activities",
                         default_display: true

  PreferableItem.create! item:          "Training",
                         item_type:     "Table",
                         name:          "paging",
                         default_value: "10",
                         description:   "Number of rows to display in training table",
                         default_display: true

  PreferableItem.create! item:          "Mission",
                         item_type:     "Table",
                         name:          "paging",
                         default_value: "10",
                         description:   "Number of rows to display in mission table",
                         default_display: true

end

if PreferableItem.count == 40

  PreferableItem.create! item:            "CourseHome",
                         item_type:       "SectionShow",
                         name:            "announcements_no",
                         default_value:   "3",
                         description:     "No of recent announcements to show in course home page",
                         default_display: true

  PreferableItem.create! item:            "CourseHome",
                         item_type:       "SectionShow",
                         name:            "activities_no",
                         default_value:   "50",
                         description:     "No of recent activities to show in course home page",
                         default_display: true
end

if PreferableItem.count == 42

  PreferableItem.create! item:            "Announcements",
                         item_type:       "List",
                         name:            "paging",
                         default_value:   "10",
                         description:     "Number of announcements to display per page",
                         default_display: true

end

if PreferableItem.count == 43

  PreferableItem.create! item:            "Achievements",
                         item_type:       "Icon",
                         name:            "locked",
                         default_value:   "",
                         description:     "Locked achievements icon display type",
                         default_display: true

  PreferableItem.create! item:            "Paging",
                         item_type:       "Announcements",
                         name:            "Announcements",
                         default_value:   "50",
                         description:     "Number of announcements to display per page",
                         default_display: true

  PreferableItem.create! item:            "Paging",
                         item_type:       "Missions",
                         name:            "Missions",
                         default_value:   "50",
                         description:     "Number of missions to display per page",
                         default_display: true

  PreferableItem.create! item:            "Paging",
                         item_type:       "MissionStats",
                         name:            "Mission Statistics",
                         default_value:   "50",
                         description:     "Number of students to display per page",
                         default_display: true

  PreferableItem.create! item:            "Paging",
                         item_type:       "Trainings",
                         name:            "Trainings",
                         default_value:   "50",
                         description:     "Number of trainings to display per page",
                         default_display: true

  PreferableItem.create! item:            "Paging",
                         item_type:       "TrainingStats",
                         name:            "Training Statistics",
                         default_value:   "50",
                         description:     "Number of students to display per page",
                         default_display: true


  PreferableItem.create! item:            "Paging",
                         item_type:       "MissionSubmissions",
                         name:            "Mission Submissions",
                         default_value:   "50",
                         description:     "Number of mission submissions to display per page",
                         default_display: true

  PreferableItem.create! item:            "Paging",
                         item_type:       "TrainingSubmissions",
                         name:            "Training Submissions",
                         default_value:   "50",
                         description:     "Number of training submissions to display per page",
                         default_display: true

  PreferableItem.create! item:            "Paging",
                         item_type:       "Comments",
                         name:            "Comments",
                         default_value:   "50",
                         description:     "Number of topics to display per page",
                         default_display: true

  PreferableItem.create! item:            "Paging",
                         item_type:       "Achievements",
                         name:            "Achievements",
                         default_value:   "50",
                         description:     "Number of achievements to display per page",
                         default_display: true

  PreferableItem.create! item:            "Paging",
                         item_type:       "Students",
                         name:            "Students",
                         default_value:   "50",
                         description:     "Number of students to display per page",
                         default_display: true

  PreferableItem.create! item:            "Paging",
                         item_type:       "ManageStudents",
                         name:            "Manage Students",
                         default_value:   "50",
                         description:     "Number of students to display per page",
                         default_display: true

  PreferableItem.create! item:            "Paging",
                         item_type:       "StudentSummary",
                         name:            "Student Summary",
                         default_value:   "50",
                         description:     "Number of students to display per page",
                         default_display: true


end

if PreferableItem.count == 56
  PreferableItem.create! item:          "Mission",
                         item_type:     "Submission",
                         name:          "auto",
                         default_value: "",
                         description:   "Auto create submissions for missions, special feature for courses that just want to take advantage of Coursemology's social features",
                         default_display: false

end

if SurveyQuestionType.count == 0
  SurveyQuestionType.create! title:         "MCQ",
                             description:   "Multiple Choice Question"

  SurveyQuestionType.create! title:         "MRQ",
                             description:   "Multiple Response Question"

  SurveyQuestionType.create! title:         "Essay",
                             description:   "Essay"

end

if PreferableItem.count == 57
  PreferableItem.create! item:          "Sidebar",
                         item_type:     "Student",
                         name:          "surveys",
                         default_value: "Surveys",
                         description:   "Course surveys",
                         default_display: true
end

if PreferableItem.count == 58
  PreferableItem.create! item:          "Sidebar",
                         item_type:     "Student",
                         name:          "materials",
                         default_value: "Workbin",
                         description:   "All course materials uploaded",
                         default_display: true
end

if PreferableItem.count == 59
  PreferableItem.create! item:          "Sidebar",
                         item_type:     "Student",
                         name:          "lesson_plan",
                         default_value: "Lesson Plan",
                         description:   "Lesson Plan",
                         default_display: true
end

if PreferableItem.count == 60
  PreferableItem.create! item:          "Sidebar",
                         item_type:     "Student",
                         name:          "forums",
                         default_value: "Forums",
                         description:   "Discussion Forums",
                         default_display: true
end

if PreferableItem.count == 61
  PreferableItem.create! item:            "Paging",
                         item_type:       "Forums",
                         name:            "Forums",
                         default_value:   "20",
                         description:     "Number of topics to display per forum page",
                         default_display: true
end

if PreferableItem.count == 62
  PreferableItem.create! item:            "Sidebar",
                         item_type:       "Other",
                         name:            "ranking",
                         default_value:   "",
                         description:     "Student's level and achievement status",
                         default_display: true
end

if Action.count == 8
  Action.create! text: 'created Forum topic', description: 'actor created Forum topic'
  Action.create! text: 'asked', description: 'actor asked Forum question'
  Action.create! text: 'voted on', description: 'actor voted on Forum post'
end

if AssignmentDisplayMode.count == 0
  AssignmentDisplayMode.create! title: "Single Page", description: 'Put all questions in a single page'
  AssignmentDisplayMode.create! title: "Tab", description: 'Put each question under one tab'
end

if PreferableItem.count == 63
  PreferableItem.create! item:          "Sidebar",
                         item_type:     "Student",
                         name:          "comics",
                         default_value: "Comics",
                         description:   "Comics",
                         default_display: true
end

if PreferableItem.count == 64

  PreferableItem.create! item:          "Mission",
                         item_type:     "Export",
                         name:          "pdf",
                         default_value: "PDF",
                         description:   "Allow PDF export of completed missions",
                         default_display: false

  PreferableItem.create! item:          "Training",
                         item_type:     "Export",
                         name:          "pdf",
                         default_value: "PDF",
                         description:   "Allow PDF export of completed trainings",
                         default_display: false

end

if PreferableItem.count == 66
  PreferableItem.create! item:             "UserCourse",
                         item_type:        "ChangeName",
                         name:             "ChangeName",
                         default_value:    "",
                         description:      "Allow students to change their names in course",
                         default_display:  true
end

PreferableItem.find_or_create_by! item:             "Assessment",
                                  item_type:        "StartAt",
                                  name:             "IgnoreStartAt",
                                  default_value:    "",
                                  description:      "Allow students to attempt the assessments that start at a future time provided they have fulfilled the prerequisites",
                                  default_display:  false

if NavbarLinkType.count == 0
  NavbarLinkType.create! link_type: 'module'
  NavbarLinkType.create! link_type: 'admin'
end

if NavbarPreferableItem.count == 0
  NavbarPreferableItem.create! item:  "announcements",
                               navbar_link_type_id:  1,
                               name: "Announcements",
                               is_displayed: true,
                               is_enabled: true,
                               description: "course announcements",
                               pos: 1

  NavbarPreferableItem.create! item:  "missions",
                               navbar_link_type_id:  1,
                               name: "Missions",
                               is_displayed: true,
                               is_enabled: true,
                               description: "course missions",
                               pos: 2

  NavbarPreferableItem.create! item:  "trainings",
                               navbar_link_type_id:  1,
                               name: "Trainings",
                               is_displayed: true,
                               is_enabled: true,
                               description: "course trainings",
                               pos: 3


  NavbarPreferableItem.create! item:  "submissions",
                               navbar_link_type_id:  1,
                               name: "Submissions",
                               is_displayed: true,
                               is_enabled: true,
                               description: "course submissions",
                               pos: 4

  NavbarPreferableItem.create! item:  "achievements",
                               navbar_link_type_id:  1,
                               name: "Achievements",
                               is_displayed: true,
                               is_enabled: true,
                               description: "course achievements",
                               pos: 5

  NavbarPreferableItem.create! item:  "comments",
                               navbar_link_type_id:  1,
                               name: "Comments",
                               is_displayed: true,
                               is_enabled: true,
                               description: "course comments",
                               pos: 6


  NavbarPreferableItem.create! item:  "leaderboard",
                               navbar_link_type_id:  1,
                               name: "Leaderboard",
                               is_displayed: true,
                               is_enabled: true,
                               description: "course leaderboard",
                               pos: 7

  NavbarPreferableItem.create! item:  "students",
                               navbar_link_type_id:  1,
                               name: "Students",
                               is_displayed: true,
                               is_enabled: true,
                               description: "course students",
                               pos: 8

  NavbarPreferableItem.create! item:  "lesson_plan",
                               navbar_link_type_id:  1,
                               name: "Lesson Plan",
                               is_displayed: false,
                               is_enabled: false,
                               description: "course lesson plan",
                               pos: 9

  NavbarPreferableItem.create! item:  "materials",
                               navbar_link_type_id:  1,
                               name: "Materials",
                               is_displayed: false,
                               is_enabled: false,
                               description: "course materials",
                               pos: 10

  NavbarPreferableItem.create! item:  "forums",
                               navbar_link_type_id:  1,
                               name: "Forums",
                               is_displayed: false,
                               is_enabled: false,
                               description: "course forums",
                               pos: 11

  NavbarPreferableItem.create! item:  "surveys",
                               navbar_link_type_id:  1,
                               name: "Surveys",
                               is_displayed: false,
                               is_enabled: false,
                               description: "course surveys",
                               pos: 12

end

if NavbarPreferableItem.count == 12
  NavbarPreferableItem.create! item:  "comics",
                               navbar_link_type_id:  1,
                               name: "Comics",
                               is_displayed: false,
                               is_enabled: false,
                               description: "course comics",
                               pos: 13
end

if NavbarPreferableItem.count == 13
  NavbarPreferableItem.create! item:  "guilds",
                               navbar_link_type_id:  1,
                               name: "Guilds",
                               is_displayed: false,
                               is_enabled: false,
                               description: "course guilds",
                               pos: 14
end

ProgrammingLanguage.find_or_create_by!(name: "Python",
                                       codemirror_mode: "python",
                                       version:  "3.3",
                                       cmd: "python3.3")

ProgrammingLanguage.find_or_create_by!(name: "Python",
                                       codemirror_mode: "python",
                                       version:  "3.4",
                                       cmd: "python3.4")

ProgrammingLanguage.find_or_create_by!(name: "Python",
                                       codemirror_mode: "python",
                                       version:  "2.7",
                                       cmd: "python2.7")

ProgrammingLanguage.find_or_create_by!(name: "Python",
                                       codemirror_mode: "python",
                                       version:  "3.5",
                                       cmd: "python3.5")