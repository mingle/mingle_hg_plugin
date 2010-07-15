# Copyright 2009 ThoughtWorks, Inc.  All rights reserved.

ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => "changesets" do |changesets|
    changesets.changeset 'projects/:project_id/changesets/:rev', :action => 'show'
  end
end