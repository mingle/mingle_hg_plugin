#Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

class HgConfigurationsController < ProjectApplicationController

  verify :method => :post, :only => [ :save, :create ]
  verify :method => :put, :only => [ :update ]
  privileges UserAccess::PrivilegeLevel::PROJECT_ADMIN => ['index', 'save', 'update', 'show', 'create']

  def current_tab
    Project::ADMIN_TAB_INFO
  end

  def admin_action_name
    super.merge(:controller => 'repository')
  end

end