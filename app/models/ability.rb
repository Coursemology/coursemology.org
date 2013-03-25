class Ability
  include CanCan::Ability

  def initialize(user)
    puts 'Using Ability for authorization!'
    if user
      if user.is_admin?
        can :manage, :all
      end

      user.user_courses.lecturer.each do |uc|
        can :manage, uc.course
      end

      can :manage, User, id: user.id
      can :new, RoleRequest
    end
    can :read, :all
  end
end
