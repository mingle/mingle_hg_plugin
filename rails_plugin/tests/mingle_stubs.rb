# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

# mixed into all repository configuration models. allows us to treat repository path
# changes as separate delete and create steps, allowing for cleanup, while treating
# user and password updates as simple updates. (perhaps, we should treat all changes
# as 'new' repositories, but... initial repository caching is so expensive...)
module RepositoryModelHelper
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    def create_or_update(project_id, id, options={})
      options = options.symbolize_keys
      options.delete(:project_id)
      options.delete(:id)

      if !id.blank? && config = self.find_by_project_id_and_id(project_id, id)
        if config.username != options[:username].to_s.strip
          config.password = nil
        end

        if config.repository_location_changed?(options.dup)
          config.mark_for_deletion
          create_or_update(project_id, nil, config.clone_repository_options.merge(options))
        else
          config.update_attributes(options)
          config
        end
      else
        existing = find_project(project_id).repository_configuration
        if !existing
          options.merge! :project_id => project_id
          self.create(options)
        else
          errored_config = self.new(options)
          errored_config.errors.add_to_base("Could not create the new repository configuration because a repository configuration already exists.")
          errored_config
        end
      end
    end
    
    def find_project(project_id)
      Project.find(project_id)
    end
  end
  
  #overwrite this method if behaviour is different
  def mark_for_deletion
    update_attribute :marked_for_deletion, true
  end
end

# Unfortunately, Mingle is dependent upon a Repository::NoSuchRevisionError 
# defined in its code base...
class Repository  
  class NoSuchRevisionError < StandardError
  end
end

# stub Mingle's Project class
class Project
  
  @@instances = {}
  
  class << self
    def register_instance_for_find(project)
      @@instances[project.id] = project
    end
    
    def clear_find_registry
      @@instances = {}
    end
    
    def find(*args)
      @@last_requested = args.first
      @@instances[@@last_requested]
    end

    def current
      find(@@last_requested)
    end
  end
  
  def encrypt(text)
    "ENCRYPTED" + text
  end
  
  def decrypt(text)
    text.gsub(/\AENCRYPTED/, "")
  end
  
  def id
    3487
  end
  
  def new_record?
    false
  end
  
  def identifier
    "test_project"
  end  
  
  def repository_configuration
    nil
  end
end
