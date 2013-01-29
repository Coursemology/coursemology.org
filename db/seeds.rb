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

if User.count == 0
  admin = User.create!(name: "Admin", email: "jfdi@academy.com",
                       password: "supersecretpass",
                       password_confirmation: "supersecretpass",
                       system_role_id: super_role.id)
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
