class AddBonusExpAndBonusCutoffTimeForTrainings < ActiveRecord::Migration
  def change
    add_column :trainings, :bonus_exp, :integer
    add_column :trainings, :bonus_cutoff, :datetime
  end

end
