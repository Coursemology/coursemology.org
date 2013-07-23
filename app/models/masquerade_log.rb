class MasqueradeLog < ActiveRecord::Base
  attr_accessible :action, :as_user_id, :by_user_id, :description
end
