class UserMailer < ActionMailer::Base
  default from: "coursemology@gmail.com"

  def new_comment(user, comment, redirect_url)
    puts "to email #{user.email} comment #{comment.text}"
    puts "redirect #{redirect_url}"
    @user = user
    @comment = comment
    @redirect_url = redirect_url
    mail(to: user.email, subject: "New comment!")
  end
end
