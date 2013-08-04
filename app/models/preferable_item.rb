class PreferableItem < ActiveRecord::Base
  attr_accessible :item, :item_type, :name, :default_value, :description, :default_display

  def self.mission_columns
    PreferableItem.where(item: "Mission", item_type: "Column")
  end

  def self.training_columns
    PreferableItem.where(item: "Training", item_type: "Column")
  end

end
