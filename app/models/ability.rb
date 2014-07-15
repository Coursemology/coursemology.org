class Ability
  include CanCan::Ability

  def initialize(user)
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
      end
    end
  end
end
