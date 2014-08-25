class AddPubAskCtrToUsers < ActiveRecord::Migration
  def change
    add_column :users, :pub_ask_ctr, :tinyint
  end
end
