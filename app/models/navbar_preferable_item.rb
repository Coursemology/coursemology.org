class NavbarPreferableItem < ActiveRecord::Base
  attr_accessible :item, :name, :is_enabled, :is_displayed, :description, :pos, :navbar_link_type_id

  belongs_to :navbar_link_type
end
