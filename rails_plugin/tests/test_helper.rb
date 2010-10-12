# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

require 'rubygems'
require 'activesupport'
require 'activerecord'
require 'test/unit'
require 'ostruct'
require 'md5'
require 'fileutils'

require File.expand_path(File.join(File.dirname(__FILE__), 'mingle_stubs'))
require File.expand_path(File.join(File.dirname(__FILE__), 'mingle_rails_patches_and_extensions'))

# setup required env vars
RAILS_ENV = 'test'
MINGLE_DATA_DIR=File.dirname(__FILE__) + '/../../tmp/test/mingle_data_dir'

# require model
Dir[File.dirname(__FILE__) + '/../app/models/*.rb'].each do |lib_file|
  require File.expand_path(lib_file)
end

# setup logger
ActiveRecord::Base.logger = Logger.new($stdout)
ActiveRecord::Base.logger.level = Logger::ERROR

# setup db config and run migration (only works for sqlite3 now)
ActiveRecord::Base.configurations['test'] = {}
ActiveRecord::Base.configurations['test']['database'] = ':memory:'
if RUBY_PLATFORM =~ /java/
  ActiveRecord::Base.configurations['test']['adapter'] = 'jdbcsqlite3'
else
  require 'sqlite3'
  ActiveRecord::Base.configurations['test']['adapter'] = 'sqlite3'
end
ActiveRecord::Base.establish_connection
ActiveRecord::Migrator.migrate(File.dirname(__FILE__) + '/../db/migrate')


class TestRepositoryFactory
      
  class << self
    def create_repository_without_source_browser(bundle = nil, options = {})
      factory = TestRepositoryFactory.new(bundle, options)
      factory.unbundle
      style_dir = File.expand_path("#{File.dirname(__FILE__)}/../templates")
      java_hg_client = com.thoughtworks.studios.mingle.hg.hgcmdline::HgClient.new(nil, factory.dir, style_dir)
      hg_client = HgClient.new(java_hg_client)
      HgRepository.new(hg_client, nil)
    end

    def create_repository_with_source_browser(bundle = nil, options = {})
      factory = TestRepositoryFactory.new(bundle, options)
      factory.unbundle
      style_dir = File.expand_path("#{File.dirname(__FILE__)}/../app/templates")
      java_hg_client = com.thoughtworks.studios.mingle.hg.hgcmdline::HgClient.new(nil, factory.dir, style_dir)
      hg_client = HgClient.new(java_hg_client)
      source_browser = HgSourceBrowser.new(
        java_hg_client, 
        factory.source_browser_cache_path,
        options[:stub_mingle_revision_repository] || NoOpMingleRevisionRepository.new
      )
      source_browser.instance_variable_set(:@__cache_path, factory.source_browser_cache_path)
      def source_browser.cache_path
        @__cache_path
      end
      repository = HgRepository.new(hg_client, source_browser)
      [repository, source_browser]
    end

  end
  
  def initialize(bundle, options)
    @bundle = bundle
    @options = options
  end
  
  def unbundle
    FileUtils.mkdir_p(dir)
    if !File.exist?(File.join(dir, '.hg'))
      hg_exec('init')    
      if @bundle
        FileUtils.cp(bundle_path, dir)
        hg_exec("unbundle #{@bundle}.hg")
      end
    end
  end
  
  def use_cached_source_browser_files?
    @options[:use_cached_source_browser_files].nil? || @options[:use_cached_source_browser_files] == true
  end
      
  def dir
    @repos_dir ||= repos_path
  end
    
  def bundle_path
    File.join(File.dirname(__FILE__), 'bundles', "#{@bundle}.hg")
  end
  
  def source_browser_path_secret
    @source_browser_path_secret ||= if @use_cached_source_browser_files
      Digest::MD5.hexdigest(File.new(bundle_path).mtime.utc.to_s)
    else
      ActiveSupport::SecureRandom.hex(32)
    end
  end
  
  def repos_path_secret
    @repos_path_secret ||= Digest::MD5.hexdigest(File.new(bundle_path).mtime.utc.to_s)
  end
  
  def hg_exec(command_string)
    `hg --cwd \"#{dir}\" #{command_string}`
  end
  
  def source_browser_cache_path
    if (@bundle)
      File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'test',
        'test_source_browser_caches_from_bundles', @bundle, source_browser_path_secret))
    else
      File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'test',
        'test_source_browser_caches_from_bundles', 'empty'))
    end    
  end
  
  def repos_path
    if (@bundle)
      File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'test',
        'test_repositories_from_bundles', @bundle, repos_path_secret))
    else
      File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'tmp', 'test', 
        'test_repositories_from_bundles', 'empty'))
    end    
  end

end


class NoOpMingleRevisionRepository
  def sew_in_most_recent_changeset_data_from_mingle(children)
  end
end

