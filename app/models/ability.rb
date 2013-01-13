class Ability
  include CanCan::Ability

  def initialize(user)
    puts 'Using Ability for authorization!'
    if user
      if user.is_admin?
        can :manage, :all
      elsif user.is_lecturer?
        can :manage, Course, creator_id: user.id
      end
      can :manage, User, id: user.id
      can :new, RoleRequest
    end
    can :read, :all
  end
end
