module FindBy
  def find_by(conditions)
    find(:first, conditions: conditions)
  end

  def find_by!(conditions)
    find!(:first, conditions: conditions)
  end

  def find_or_create_by(conditions)
    find(:first, conditions: conditions) || create(conditions)
  end

  def find_or_create_by!(conditions)
    find(:first, conditions: conditions) || create!(conditions)
  end
end

ActiveRecord::Base.send(:extend, FindBy) if defined?(ActiveRecord::Base)
