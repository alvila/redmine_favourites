module RedmineLike
  module RedmineExt

    module QueryPatch
      def self.included(base) # :nodoc:
        base.extend(ClassMethods)

        base.send(:include, InstanceMethods)
	base.send(:include, InstanceMethodsFor09Later)

        # Same as typing in the class
        base.class_eval do
          unloadable # Send unloadable so it will not be unloaded in development

          alias_method_chain :available_filters, :redmine_like unless method_defined?(:available_filters_without_redmine_like)
          alias_method_chain :sql_for_field, :redmine_like unless method_defined?(:sql_for_field_without_redmine_like)
       end

      end
    end

    module ClassMethods

      unless Query.respond_to?(:available_columns=)
        # Setter for +available_columns+ that isn't provided by the core.
        def available_columns=(v)
          self.available_columns = (v)
        end
      end

      unless Query.respond_to?(:add_available_column)
        # Method to add a column to the +available_columns+ that isn't provided by the core.
        def add_available_column(column)
          self.available_columns << (column)
        end
      end
    end

    module InstanceMethods

      def available_filters_with_redmine_like
        return @available_filters if @available_filters

        available_filters_without_redmine_like

        #return @available_filters unless project

        like_filters

        @like_filters.each do |filter|
          @available_filters[filter.name] = filter.available_values
        end
        return @available_filters
      end

      def sql_for_like_state(field, operator, value)
        #return sql_for_always_false unless project
        like_changesets = find_like_set
        return sql_for_issues_like(like_changesets, operator, value)
      end

      def find_like_set
	if User.current.pref[:others] == nil then
		User.current.pref[:others]=Hash.new
		User.current.pref.save
	end
	if User.current.pref[:others][:issue_like] == nil then
		User.current.pref[:others][:issue_like]=Array.new
		User.current.pref.save
	end
        return User.current.pref[:others][:issue_like]
      end

      # conditions always true
      def sql_for_always_true
        return "#{Issue.table_name}.id > 0"
      end

      # conditions always false
      def sql_for_always_false
        return "#{Issue.table_name}.id < 0"
      end

      def sql_for_issues_like(like_set, operator, value)
        return sql_for_always_false unless like_set
        return sql_for_always_false if like_set.length == 0 && operator=="="
        return sql_for_always_true if like_set.length == 0 && operator=="!"
	sql = "#{Issue.table_name}.id in (#{like_set.join(',')})" if operator=="="
	sql = "#{Issue.table_name}.id not in (#{like_set.join(',')})" if operator =="!"
        return sql
      end

      def conditions_for(field, operator, value)
        retval = ""

        available_filters
        return retval unless @like_filters
        filter = @like_filters.detect {|hfilter| hfilter.name == field}
        return retval unless filter

        case operator
        when "="
          retval = "#{Issue.table_name}.id IN (" + find_like_set.join(",") + ")"
        when "!"
          retval = "#{Issue.table_name}.id NOT IN (" + find_like_set.join(",") + ")"
        end
        return retval
      end

      def like_filters

        @like_filters = []
        #return @like_filters unless project
        return @like_filters unless @available_filters

        @like_filters << LikeQueryFilter.new("like_state", { :type => :list, :order => @available_filters.size + 2,:values => ["True"] }, "", "")

        return @like_filters

      end

    end #InstanceMethods
    module InstanceMethodsFor09Later
      def sql_for_field_with_redmine_like(field, operator, value, db_table, db_field, is_custom_filter=false)
        case field
        when "like_state"
          return sql_for_like_state(field, operator, value)
        else
           return sql_for_field_without_redmine_like(field, operator, value, db_table, db_field, is_custom_filter)
        end
      end
    end #InstanceMethodsFor09Later

  end #RedmineExt
end #RedmineLike
