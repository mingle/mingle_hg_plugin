# Copyright 2009 ThoughtWorks, Inc.  All rights reserved.

ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => "changesets" do |changesets|
    changesets.changeset 'projects/:project_id/changesets/:rev', :action => 'show'
  end
  
  map.with_options :controller => 'repository' do |hg_configuration|
    hg_configuration.hg_configurations_show 'projects/:project_id/hg_configurations', :action => 'index', :conditions => {:method => :get}, :repository_type => "HgConfiguration"
    
    hg_configuration.rest_hg_configurations_index 'api/:api_version/projects/:project_id/hg_configurations.xml', :action => 'index', :conditions => {:method => :get}, :format => 'xml', :repository_type => "HgConfiguration"
    hg_configuration.rest_hg_configurations_show 'api/:api_version/projects/:project_id/hg_configurations/:id.xml', :action => 'show', :conditions => {:method => :get}, :format => 'xml', :repository_type => "HgConfiguration"
    hg_configuration.rest_hg_configurations_create_or_update 'api/:api_version/projects/:project_id/hg_configurations.xml', :action => 'save', :conditions => {:method => [:put, :post]}, :format => 'xml', :repository_type => "HgConfiguration"
    hg_configuration.rest_hg_configurations_update 'api/:api_version/projects/:project_id/hg_configurations/:id.xml', :action => 'save', :conditions => {:method => :put}, :format => 'xml', :repository_type => "HgConfiguration"
    hg_configuration.map 'projects/:project_id/hg_configurations.xml', :action => 'unsupported_api_call'
    hg_configuration.map 'projects/:project_id/hg_configurations/:id.xml', :action => 'unsupported_api_call'
  end
end