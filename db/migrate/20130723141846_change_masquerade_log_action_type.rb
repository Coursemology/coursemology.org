class ChangeMasqueradeLogActionType < ActiveRecord::Migration
  def change
    change_column :masquerade_logs, :action, :text
  end
end
