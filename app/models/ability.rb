class Ability
  include CanCan::Ability

  def initialize(user)
    can :read, Course, is_publish: true
    if user
      can :manage, User, id: user.id
      can :manage, RoleRequest, user_id: user.id
      cannot :update_role, User

      if user.is_admin?
        can :manage, :all
        can :masquerade, :user
        can :update_role, User
      elsif user.is_lecturer?
        can :manage, Course, creator_id: user.id
        can :create, Course
      end
    end
  end
end
