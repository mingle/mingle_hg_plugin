# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'ostruct'

class HgSourceBrowserSynchTest < Test::Unit::TestCase

  def setup_repos(browser, options = {})
    @repos, @source_browser = TestRepositoryFactory.create_repository_with_source_browser(browser, options)
    @repos = HgSourceBrowserSynch.new(@repos, @source_browser)
  end
    
  # todo: introduce mocks, remove dependency on actual source browser
  def test_does_not_blow_up_on_empty_repos
    setup_repos(nil)
    assert_equal [], @repos.next_revisions(nil, 100)
  end

  # todo: introduce mocks, remove dependency on actual source browser
  def test_source_browser_caches_results_of_next_revisions
    setup_repos('one_add', :use_cached_source_browser_files => false)
    @repos.next_revisions(nil, 100)
    cache_files = Dir["#{@source_browser.cache_path}/**/*.yml"].map do |cache_file|
      cache_file.split("#{@source_browser.cache_path}/").last
    end.sort
    assert_equal ['2/0/0/source_browser_info.yml', '2/1/1/source_browser_info.yml'], cache_files
  end

  # todo: introduce mocks, remove dependency on actual source browser
  def test_source_browser_caches_missing_revisions_when_no_new_revisions
    setup_repos('one_add', :use_cached_source_browser_files => false)
    @repos.next_revisions(nil, 100)
    FileUtils.rm_rf(@source_browser.cache_path)
    @repos.next_revisions(OpenStruct.new(:number => 1), 100)
    cache_files = Dir["#{@source_browser.cache_path}/**/*.yml"].map do |cache_file|
      cache_file.split("#{@source_browser.cache_path}/").last
    end.sort
    assert_equal ['2/0/0/source_browser_info.yml', '2/1/1/source_browser_info.yml'], cache_files
  end

  # todo: introduce mocks, remove dependency on actual source browser
  def test_source_browser_caches_missing_revisions_when_new_revisions
    setup_repos('one_add', :use_cached_source_browser_files => false)
    @repos.next_revisions(nil, 1)
    FileUtils.rm_rf(@source_browser.cache_path)
    @repos.next_revisions(OpenStruct.new(:number => 0), 100)
    cache_files = Dir["#{@source_browser.cache_path}/**/*.yml"].map do |cache_file|
      cache_file.split("#{@source_browser.cache_path}/").last
    end.sort
    assert_equal ['2/0/0/source_browser_info.yml', '2/1/1/source_browser_info.yml'], cache_files
  end

  # todo: introduce mocks, remove dependency on actual source browser
  def test_any_directory_not_matching_current_cache_file_format_is_cleaned_up
    setup_repos('one_add', :use_cached_source_browser_files => false)
    FileUtils.mkdir_p(File.join(@source_browser.cache_path, '0'))
    FileUtils.mkdir_p(File.join(@source_browser.cache_path, '1'))
    FileUtils.mkdir_p(File.join(@source_browser.cache_path, '1.7'))
    FileUtils.mkdir_p(File.join(@source_browser.cache_path, 'abc'))
    @repos.next_revisions(nil, 1)
    assert !File.exist?(File.join(@source_browser.cache_path, '0'))
    assert !File.exist?(File.join(@source_browser.cache_path, '1'))
    assert !File.exist?(File.join(@source_browser.cache_path, '1.7'))
    assert !File.exist?(File.join(@source_browser.cache_path, 'abc'))
    assert File.exist?(File.join(@source_browser.cache_path, '2'))
  end
  
end