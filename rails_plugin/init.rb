# Copyright 2010 ThoughtWorks, Inc.  All rights reserved.

#<snippet name="registration">
COMPATIBLE_MINGLE_VERSIONS = ['3_1', 'unstable_3_1', 'unsupported-developer-build']

if COMPATIBLE_MINGLE_VERSIONS.include?(MINGLE_VERSION)

  begin
    require File.expand_path(File.join(File.dirname(__FILE__), 'app/models/hg_configuration'))
    MinglePlugins::Source.register(HgConfiguration)
  rescue Exception => e
    ActiveRecord::Base.logger.error "Unable to register HgConfiguration. Root cause: #{e}"
  end
  
else
  ActiveRecord::Base.logger.warn %{
    The plugin mingle_hg_plugin is not compatible with Mingle version #{MINGLE_VERSION}. 
    This plugin only works with Mingle version(s): #{COMPATIBLE_MINGLE_VERSIONS.join(', ')}.
    The plugin mingle_hg_plugin will not be available.
  }
end
#</snippet>

#<snippet name="xml_serialization">
# use Mingle's XML serialization library when the plugin is deployed to a Mingle instance
if RUBY_PLATFORM =~ /java/ && defined?(RAILS_ENV)
  HgConfiguration.class_eval do
    include ::API::XMLSerializer
    serializes_as :id, :marked_for_deletion, :project, :repository_path, :username
  end
end
#</snippet>
