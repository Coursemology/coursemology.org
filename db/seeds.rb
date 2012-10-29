# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

super_role = Role.create! name: "superuser", title: "Super User"
Role.create! name: "normal", title: "User"
Role.create! name: "lecturer", title: "Lecturer"
Role.create! name: "ta", title: "Teaching Assistant"
Role.create! name: "student", title: "Student"

admin = User.create!(name: "Admin", email: "jfdi@academy.com",
                     password: "supersecretpass",
                     password_confirmation: "supersecretpass",
                     system_role_id: super_role.id)
