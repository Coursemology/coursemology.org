module ActsAsDuplicable

  def acts_as_duplicable
    has_many  :duplicate_logs_orig, class_name: "DuplicateLog", as: :origin_obj, autosave: true
    has_many  :duplicate_logs_dest, class_name: "DuplicateLog", as: :dest_obj, autosave: true
    amoeba do
      customize(lambda { |o_a, n_a|
        log = n_a.duplicate_logs_dest.build
        log.origin_obj = o_a
      })
    end

    def self.all_dest_logs
      DuplicateLog.where(dest_obj_type: self.to_s, dest_obj_id: self.all.map(&:id))
    end
  end
end

# Extend ActiveRecord's functionality
ActiveRecord::Base.send :extend, ActsAsDuplicable
