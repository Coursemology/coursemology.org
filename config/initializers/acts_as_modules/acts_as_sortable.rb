module ActsAsSortable

  def acts_as_sortable(options = {})
    configuration = {column: "position", scope: "1 = 1", top_of_list: 1}
    configuration.update(options) if options.is_a?(Hash)
    position_column = configuration[:column]

    class_eval <<-EOV

      def self.reordering(new_order)
        self.transaction do
          new_order.each_with_index do |id, index|
            self.find_by_id(id.to_i).update_attribute("#{position_column}", index)
          end
        end
      end

    EOV
  end

end

ActiveRecord::Base.send :extend, ActsAsSortable
