# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'mingle-hg-source-browser.jar'))

if !defined?(RAILS_ROOT) && (RAILS_ENV == 'test')
  require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'log4j-1.2.15.jar'))
end