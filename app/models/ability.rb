class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.is_admin?
        can :manage, :all
        can :masquerade, :user
        can :manage, :user
      elsif user.is_lecturer?
        can :manage, Course, creator_id: user.id
      end

      can :manage, User, id: user.id
      can :new, RoleRequest
    end
    can :read, :all
  end
end
