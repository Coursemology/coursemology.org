class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.is_admin?
        can :manage, :all
        can :masquerade, :user
        can :update_role, :all
      elsif user.is_lecturer?
        can :manage, Course, creator_id: user.id
      end

      can :manage, User, id: user.id
      can :manage, RoleRequest, user_id: user.id
    end
    can :read, :all
  end
end
