# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class HgConfigurationTest < Test::Unit::TestCase
  
  def setup
    @project_stub = Project.new
  end
  
  def test_password_encrypted_on_create
    project_stub = Project.new
    config = HgConfiguration.create!(:repository_path => '/tutorial/hello',
      :project => project_stub, :username => 'sammy', :password => 'soso')
    assert_equal 'ENCRYPTEDsoso', config.attributes['password']
  end
  
  def test_password_encrypted_on_save
    config = HgConfiguration.create!(:repository_path => '/tutorial/hello',
      :project => @project_stub, :username => 'sammy', :password => 'soso')
    config.password = 'new password'
    config.save!
    assert_equal 'ENCRYPTEDnew password', config.attributes['password']
  end
  
  PATHS_WITH_PASSWORD = [ 
    'http://user:pass@hg.serpentine.com/tutorial/hello',
    'http://:pass@hg.serpentine.com/tutorial/hello',
  ]
  
  def test_cannot_create_when_repository_path_contains_password
    PATHS_WITH_PASSWORD.each do |path|
      config = HgConfiguration.create(:repository_path => path)
      assert config.errors.full_messages.first.index("password")
    end
  end
  
  def test_cannot_save_when_repository_path_contains_password
    PATHS_WITH_PASSWORD.each do |path|
      config = HgConfiguration.create!(:repository_path => '/good/one/')
      config.repository_path = path
      config.save
      assert config.errors.full_messages.first.index("password")
    end
  end
  
  def test_cannot_save_when_repository_path_is_invalid
    config = HgConfiguration.create(:repository_path => 'https://your_server/mercurial_res/trunk')
    assert_equal ["\n        The repository path appears to be of invalid URI format.\n        Please check your repository path.\n      "], config.errors.full_messages
  end
  
  PATHS_WITH_USER_BUT_NO_PASSWORD = [ 
    'http://user@hg.serpentine.com/tutorial/hello',
    'http://user:@hg.serpentine.com/tutorial/hello',
  ]
  
  def test_can_create_when_repository_path_contains_username_but_no_password
    PATHS_WITH_USER_BUT_NO_PASSWORD.each do |path|
      config = HgConfiguration.create(:repository_path => path)
      assert config.errors.full_messages.empty?
    end
  end
  
  def test_can_save_when_repository_path_contains_username_but_no_password
    PATHS_WITH_USER_BUT_NO_PASSWORD.each do |path|
      config = HgConfiguration.create!(:repository_path => '/good/one/')
      config.repository_path = path
      config.save
      assert config.errors.full_messages.empty?
    end
  end
  
  def test_repository_path_with_userinfo_when_credentials_supplied_as_attributes_and_no_userinfo_in_path
    config = HgConfiguration.new(:repository_path => 'http://hg.serpentine.com/tutorial/hello')
    config.project = Project.new
    config.username = 'sammy'
    config.password = 'soso'
    assert_equal 'http://sammy:soso@hg.serpentine.com:80/tutorial/hello', config.repository_path_with_userinfo
  end
  
  def test_repository_path_with_userinfo_when_username_supplied_as_attribute_and_no_userinfo_in_path
    config = HgConfiguration.new(:repository_path => 'http://hg.serpentine.com/tutorial/hello')
    config.project = Project.new
    config.username = 'sammy'
    assert_equal 'http://sammy@hg.serpentine.com:80/tutorial/hello', config.repository_path_with_userinfo
  end
  
  def test_repository_path_with_userinfo_overrides_path_supplied_user_with_username_attribute
    config = HgConfiguration.new(:repository_path => 'http://jimmy@hg.serpentine.com/tutorial/hello')
    config.project = Project.new
    config.username = 'sammy'
    config.password = 'soso'
    assert_equal 'http://sammy:soso@hg.serpentine.com:80/tutorial/hello', config.repository_path_with_userinfo
  end
  
  def test_repository_path_with_userinfo_merges_password_attribute_with_path_username
    config = HgConfiguration.new(:repository_path => 'http://jimmy@hg.serpentine.com/tutorial/hello')
    config.project = Project.new
    config.password = 'soso'
    assert_equal 'http://jimmy:soso@hg.serpentine.com:80/tutorial/hello', config.repository_path_with_userinfo
  end
  
  def test_repository_path_with_user_supplied_as_path_userinfo_and_not_as_attribute
    config = HgConfiguration.new(:repository_path => 'http://jimmy@hg.serpentine.com/tutorial/hello')
    config.project = Project.new
    assert_equal 'http://jimmy@hg.serpentine.com:80/tutorial/hello', config.repository_path_with_userinfo
  end
  
  def test_repository_path_can_build_ssh_path_with_no_specified_port
    config = HgConfiguration.new(:repository_path => 'ssh://jimmy@hg.serpentine.com/tutorial/hello')
    config.project = Project.new
    assert_equal 'ssh://jimmy@hg.serpentine.com/tutorial/hello', config.repository_path_with_userinfo
  end
  
  def test_repository_path_can_build_ssh_path_with_specified_port
    config = HgConfiguration.new(:repository_path => 'ssh://jimmy@hg.serpentine.com:877/tutorial/hello')
    config.project = Project.new
    assert_equal 'ssh://jimmy@hg.serpentine.com:877/tutorial/hello', config.repository_path_with_userinfo
  end
  
  def test_repository_path_with_userinfo_ignores_credentials_when_nil_scheme
    config = HgConfiguration.new(:repository_path => '/tutorial/hello')
    config.project = Project.new
    config.username = 'sammy'
    config.password = 'soso'
    assert_equal '/tutorial/hello', config.repository_path_with_userinfo
  end
  
  def test_deletes_any_existing_cache_directory_upon_creation
    expected_id = (HgConfiguration.create!(:repository_path => '/foo/bar').id + 1).to_s
    another_id = expected_id.next
    FileUtils.mkdir_p(File.join(MINGLE_DATA_DIR, 'mercurial', expected_id, 'repository'))
    FileUtils.touch(File.join(MINGLE_DATA_DIR, 'mercurial', expected_id, 'repository', 'foo.txt'))
    FileUtils.mkdir_p(File.join(MINGLE_DATA_DIR, 'mercurial', expected_id, 'source_browser_cache'))
    FileUtils.touch(File.join(MINGLE_DATA_DIR, 'mercurial', expected_id, 'source_browser_cache', 'bar.txt'))
    FileUtils.mkdir_p(File.join(MINGLE_DATA_DIR, 'mercurial', another_id, 'source_browser_cache'))
    FileUtils.touch(File.join(MINGLE_DATA_DIR, 'mercurial', another_id, 'source_browser_cache', 'decoy.txt'))
    HgConfiguration.create!(:repository_path => '/foo/bar')
    assert !File.exist?(File.join(MINGLE_DATA_DIR, 'mercurial', expected_id, 'repository', 'foo.txt'))
    assert !File.exist?(File.join(MINGLE_DATA_DIR, 'mercurial', expected_id, 'source_browser_cache', 'bar.txt'))
    assert File.exist?(File.join(MINGLE_DATA_DIR, 'mercurial', another_id, 'source_browser_cache', 'decoy.txt'))
  end
  
  def test_cache_files_are_deleted_upon_destroy
    config = HgConfiguration.create!(:repository_path => '/foo/bar')
    config_id = config.id.to_s
    another_config_id = HgConfiguration.create!(:repository_path => '/foo/bar').id.to_s
    FileUtils.mkdir_p(File.join(MINGLE_DATA_DIR, 'mercurial', config_id, 'repository'))
    FileUtils.mkdir_p(File.join(MINGLE_DATA_DIR, 'mercurial', config_id, 'source_browser_cache'))
    FileUtils.touch(File.join(MINGLE_DATA_DIR, 'mercurial', config_id, 'repository', 'foo.txt'))
    FileUtils.touch(File.join(MINGLE_DATA_DIR, 'mercurial', config_id, 'source_browser_cache', 'bar.txt'))
    FileUtils.mkdir_p(File.join(MINGLE_DATA_DIR, 'mercurial', another_config_id, 'source_browser_cache'))
    FileUtils.touch(File.join(MINGLE_DATA_DIR, 'mercurial', another_config_id, 'source_browser_cache', 'decoy.txt'))
    config.destroy
    assert !File.exist?(File.join(MINGLE_DATA_DIR, 'mercurial', config_id, 'repository', 'foo.txt'))
    assert !File.exist?(File.join(MINGLE_DATA_DIR, 'mercurial', config_id, 'source_browser_cache', 'bar.txt'))
    assert File.exist?(File.join(MINGLE_DATA_DIR, 'mercurial', another_config_id, 'source_browser_cache', 'decoy.txt'))
  end
  
  def test_source_browsing_ready_returns_true_when_initialized_is_true
    assert_equal true, HgConfiguration.create!(:initialized => true, :repository_path => '/foo/bar').source_browsing_ready?
  end
  
  def test_source_browsing_ready_returns_false_when_initialized_is_false
    assert_equal false, HgConfiguration.create!(:initialized => false, :repository_path => '/foo/bar').source_browsing_ready?
  end
  
end

