# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class HgChangesetTest < Test::Unit::TestCase
    
  def test_can_get_changes
    repository = TestRepositoryFactory.create_repository_without_source_browser('one_changeset')
    changeset = repository.changeset(0)
    changes = changeset.changes
    assert_equal ['README'], changes.map(&:path)
  end
  
  def test_change_action_when_add
    assert_expected_action(['A', 'added'], [:added])
  end
  
  def test_change_action_class_when_delete
    assert_expected_action(['D', 'deleted'], [:deleted])
  end
  
  def test_change_action_class_when_rename_with_mods
    assert_expected_action(['RM', 'renamed-modified'], [:renamed, :modified])
  end

  def test_change_action_class_when_rename_without_mods
    assert_expected_action(['R', 'renamed'], [:renamed])
  end
  
  def test_change_action_class_when_modification
    assert_expected_action(['M', 'modified'], [:modified])
  end
    
  def test_path_components
    git_change = HgGitChange::NotDiffable.new('foo/n o o b/README.txt', true, [], nil)
    change = HgChange.new(git_change, 1)
    assert_equal ['foo', 'n o o b', 'README.txt'], change.path_components
  end
  
  def test_binary_predicate
    git_change = HgGitChange::NotDiffable.new(nil, true, [], nil)
    change = HgChange.new(git_change, 1)
    assert change.binary?
    
    git_change = HgGitChange::NotDiffable.new(nil, false, [], nil)
    change = HgChange.new(git_change, 1)
    assert !change.binary?
  end
  
  def test_modification_predicate
    git_change = HgGitChange::NotDiffable.new(nil, true, [:modified], nil)
    change = HgChange.new(git_change, 1)
    assert change.modification?
    
    git_change = HgGitChange::NotDiffable.new(nil, true, [:add], nil)
    change = HgChange.new(git_change, 1)
    assert !change.modification?
  end
  
  def test_complies_with_mingle
    commit_time = Time.now
    changeset = HgChangeset.new({:changeset_identifier => '234lkjsf', :revision_number => '23',
      :person => 'dave', :time => commit_time, :desc => 'this is a change'}, nil)
    assert_equal '234lkjsf', changeset.identifier
    assert_equal '23', changeset.revision_number
    assert_equal 'dave', changeset.version_control_user
    assert_equal commit_time, changeset.time
    assert_equal 'this is a change', changeset.message
  end
  
  def test_short_identifier
    assert_equal '123456789012', HgChangeset.short_identifier('1234567890' * 4)
  end
    
  def assert_expected_action(expected_action, change_type)
    git_change = HgGitChange::NotDiffable.new(nil, true, change_type, nil)
    change = HgChange.new(git_change, 1)
    assert_equal expected_action[0], change.action
    assert_equal expected_action[1], change.action_class
  end
    
end