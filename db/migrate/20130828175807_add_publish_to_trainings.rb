class AddPublishToTrainings < ActiveRecord::Migration
  def change
    add_column :trainings, :publish, :boolean, default: true
  end
end
