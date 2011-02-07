#Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

class HgConfigurationsController < ApplicationController
  
  #<snippet name="method_verification">
  verify :method => :post, :only => [ :save, :create ]
  verify :method => :put, :only => [ :update ]
  #</snippet>
  #<snippet name="privileges">
  privileges UserAccess::PrivilegeLevel::PROJECT_ADMIN => ['index', 'save', 'update', 'show', 'create']
  #</snippet>

  def current_tab
    Project::ADMIN_TAB_INFO
  end

  def admin_action_name
    super.merge(:controller => 'repository')
  end
  #</snippet>

  def index
    @hg_configuration = HgConfiguration.find(:first, :conditions => ["marked_for_deletion = ? AND project_id = ?", false, @project.id])
    respond_to do |format|
      format.html do
        render :template => 'hg_configurations/index'
      end
      format.xml do
        if !@hg_configuration.blank? 
          render :xml => [@hg_configuration].to_xml(:dasherize => false)
        else
          render :xml => "No Mercurial configuration found in project #{@project.identifier}.", :status => 404
        end
      end
    end
  end

  def save
    create_or_update
    if @hg_configuration.errors.empty?
      flash[:notice] = 'Repository settings were successfully saved.' 
    else
      set_rollback_only
      flash[:error] = @hg_configuration.errors.full_messages.join(', ')
    end

    redirect_to :action => 'index'
  end

  def show
    @hg_configuration = HgConfiguration.find(:first, :conditions => ["marked_for_deletion = ? AND project_id = ?", false, @project.id])
    #<snippet name="handling_xml_call">
    respond_to do |format|
      format.xml do
        if @hg_configuration 
          render :xml => @hg_configuration.to_xml
        else
          render :xml => "No Mercurial configuration found in project #{@project.identifier}.", :status => 404
        end
      end
    end
    #</snippet>
  end

  def update
    @hg_configuration = HgConfiguration.find_by_id(params[:id])
    create_or_update if @hg_configuration
    
    respond_to do |format|
      format.xml do
        if @hg_configuration.nil?
          render :xml => "No Mercurial configuration found in project #{@project.identifier} with id #{params[:id]}.", :status => 404
        elsif @hg_configuration.errors.empty?
          render :xml => @hg_configuration.to_xml
        else
          render :xml => @hg_configuration.errors.to_xml, :status => 422
        end
      end
    end
  end

  def create
    create_or_update
    respond_to do |format|
      format.xml do
        if @hg_configuration.errors.empty?
          head :created, :location => url_for(:action => @hg_configuration.id, :format => :xml)
        else
          render :xml => @hg_configuration.errors.to_xml, :status => 422
        end
      end
    end
  end

  def create_or_update
    @hg_configuration = HgConfiguration.create_or_update(@project.id, params[:id], params[:hg_configuration])
  end
    
end