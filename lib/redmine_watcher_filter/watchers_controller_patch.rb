# -*- coding: utf-8-unix -*-

require_dependency 'watchers_controller'

module WatcherFilter
  module WatchersControllerPatch
    def users_for_new_watcher
      users = super

      # Display name when unfiltered.
      # Be careful when data volume increases.
      scope = User.all

      if params[:cfv_q].present?
        scope = scope.joins(:custom_values => :custom_field).
          merge(CustomValue.like(params[:cfv_q])).merge(CustomField.visible)
      end
      if params[:group_id].present?
        if params[:group_id].to_i > 0
          scope = scope.in_group(params[:group_id])
        else
          scope = scope.not_in_any_group
        end
      end
      if params[:role_id].present?
        scope = scope.joins(:members => :roles).
          #where("#{Role.table_name}.id = ?", params[:role_id]).uniq
          where("#{Role.table_name}.id = ?", params[:role_id])
      end
      users = scope.active.visible.sorted.like(params[:q]).to_a
      if @watchables && @watchables.size == 1
        users -= @watchables.first.watcher_users
      end
      users
    end
  end
end

WatchersController.prepend WatcherFilter::WatchersControllerPatch
