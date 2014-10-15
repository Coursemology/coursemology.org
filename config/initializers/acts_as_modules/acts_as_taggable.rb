module ActsAsTaggable

  #adopted from acts-as-taggable-on
  def acts_as_taggable
    class_eval do
      has_many :taggings, as: :taggable, dependent: :destroy, class_name: 'TaggableTag'
      has_many :tags, through: :taggings, source: :tag, class_name: 'Tag'

      def self.tagged_with(tags, options = {})
        options = options.dup
        unless tags.is_a? Array
          tags = [tags]
        end
        empty_result = where('1 = 0')

        return empty_result if tags.empty?

        any = options.delete(:any)
        joins = []
        conditions = []
        select_clause = []
        order_by = []

        alias_base_name = undecorated_table_name.gsub('.', '_')
        quote = ''

        # setup taggings alias so we can chain, ex: items_locations_taggings_awesome_cool_123
        # avoid ambiguous column name
        taggings_alias = adjust_taggings_alias(
            "#{alias_base_name[0..4]}_taggings_#{sha_prefix(tags.map(&:name).join('_'))}"
        )

        tagging_join = "JOIN #{TaggableTag.table_name} #{taggings_alias}" +
            "  ON #{taggings_alias}.taggable_id = #{quote}#{table_name}#{quote}.#{primary_key}" +
            " AND #{taggings_alias}.taggable_type = #{quote_value(base_class.name, nil)}"

        # don't need to sanitize sql, map all ids and join with OR logic
        conditions << tags.map { |t| "#{taggings_alias}.tag_id = #{quote_value(t.id, nil)}" }.join(' OR ')


        joins << tagging_join
        unless any == 'distinct' # Fix issue #544
          group = "#{table_name}.#{primary_key}"
          select_clause << group
        end

        group ||= [] # Rails interprets this as a no-op in the group() call below
        order_by << options[:order] if options[:order].present?

        query = self
        query = self.select(select_clause.join(',')) unless select_clause.empty?
        query.joins(joins.join(' '))
        .where(conditions.join(' AND '))
        .group(group)
        .order(order_by.join(', '))
        .readonly(false)
      end

      def self.adjust_taggings_alias(taggings_alias)
        if taggings_alias.size > 75
          taggings_alias = 'taggings_alias_' + Digest::SHA1.hexdigest(taggings_alias)
        end
        taggings_alias
      end

      def self.sha_prefix(string)
        Digest::SHA1.hexdigest("#{string}#{rand}")[0..6]
      end
    end
  end
end

# Extend ActiveRecord's functionality
ActiveRecord::Base.send :extend, ActsAsTaggable
