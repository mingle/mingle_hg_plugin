# Copyright 2010 ThoughtWorks, Inc.  All rights reserved.

if RUBY_PLATFORM =~ /java/
#<snippet name="registration">
['app', 'lib', 'config'].each do |dir| 
  Dir[File.join(File.dirname(__FILE__), dir, '**', '*.rb')].each do |file| 
    require File.expand_path(file)
  end
end

begin
  require File.expand_path(File.join(File.dirname(__FILE__), 'app/models/hg_configuration'))
  MinglePlugins::Source.register(HgConfiguration)
rescue Exception => e
  ActiveRecord::Base.logger.error "Unable to register HgConfiguration. Root cause: #{e}"
end
#</snippet>

#<snippet name="xml_serialization">
  # use Mingle's XML serialization library when the plugin is deployed to a Mingle instance
  if defined?(RAILS_ENV)
    HgConfiguration.class_eval do
      include ::API::XMLSerializer
      serializes_as :id, :marked_for_deletion, :project, :repository_path, :username
    end
  end
#</snippet>
end