# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))
require 'ostruct'

class HgSourceBrowserTest < Test::Unit::TestCase

  def setup_repos(bundle)
    options = {
      :use_cached_source_browser_files => false,
      :stub_mingle_revision_repository => StubMingleRevisionRepository.new,
    }
    @repos, @source_browser = TestRepositoryFactory.create_repository_with_source_browser(bundle, options)
  end
      
  def test_file_cache_is_built_correctly_for_first_changeset
    setup_repos('one_changeset')
    synch_source_browser_up_to(@source_browser, 0)
    
    expected_file_cache_content = {
      '/' => '5bb588cbc98c0a4c46ea0fadea4092ec5c92afb4', 
      'README' => '5bb588cbc98c0a4c46ea0fadea4092ec5c92afb4'
    }
    actual_file_cache_content = @source_browser.raw_file_cache_content(0)
    assert_equal_hash(expected_file_cache_content, actual_file_cache_content)
  end
  
  def test_file_cache_is_built_correctly_for_add_changeset
    setup_repos('one_add')
    synch_source_browser_up_to(@source_browser, 1)
  
    expected_file_cache_content = {
      '/' => '6b3f0eefe63182cd2dea92d4a219199ef6429125', 
      'README' => '5bb588cbc98c0a4c46ea0fadea4092ec5c92afb4',
      'INSTALL' => '6b3f0eefe63182cd2dea92d4a219199ef6429125'
    }
    actual_file_cache_content = @source_browser.raw_file_cache_content(1)
    assert_equal_hash(expected_file_cache_content, actual_file_cache_content)
  end
  
  def test_file_cache_is_built_correctly_for_remove_changeset
    setup_repos('one_remove')
    synch_source_browser_up_to(@source_browser, 1)
    
    expected_file_cache_content = {
      '/' => '93694ea4a21c1933bb8f5f4d46a8bb352ee0ed0a',
      'README' => '72e690d34170cef2eb7c1c3d71d8df8b3ec9e17d'
    }
    actual_file_cache_content = @source_browser.raw_file_cache_content(1)
    assert_equal_hash(expected_file_cache_content, actual_file_cache_content)
  end
  
  def test_file_cache_is_built_correctly_for_rename_changeset
    setup_repos('renames')
    synch_source_browser_up_to(@source_browser, 1)
    
    expected_file_cache_content = {
      '/' => '4bdbb6906cef5481b93e192395c933af43b4935b',
      'WorstestEver.png' => '4bdbb6906cef5481b93e192395c933af43b4935b',
      'some_stuff.txt' => '4bdbb6906cef5481b93e192395c933af43b4935b'
    }
    actual_file_cache_content = @source_browser.raw_file_cache_content(1)
    assert_equal_hash(expected_file_cache_content, actual_file_cache_content)
  end
          
  def test_node_returns_file_node_for_file_path
    setup_repos('one_changeset')
    synch_source_browser_up_to(@source_browser, 0)
    
    assert !@source_browser.node('README', "0", "5bb588cbc98c0a4c46ea0fadea4092ec5c92afb4").dir?
  end
  
  def test_node_returns_dir_node_for_dir_path
    setup_repos('one_changeset_with_subdirs')
    synch_source_browser_up_to(@source_browser, 0)
    
    assert @source_browser.node('src', "0", "32ecc7b520f6110ce0ebef34ae4c650a3126ec91").dir?
  end
  
  def test_node_returns_dir_node_for_root
    setup_repos('one_changeset')
    synch_source_browser_up_to(@source_browser, 0)
    
    assert @source_browser.node('', "0", "5bb588cbc98c0a4c46ea0fadea4092ec5c92afb4").dir?
  end
  
  def test_can_get_children_of_root_node
    setup_repos('one_changeset_with_many_files')
    synch_source_browser_up_to(@source_browser, 0)
        
    children = @source_browser.node('', "0", "25c12050e5597a54698b1b0c1c8f8c89b9147548").children
    assert_equal ['README', 'src', 'tests'].sort, children.map(&:path).sort
  end
  
  def test_can_get_children_of_root_node_when_root_contains_dot_files
    setup_repos('dot_files')
    synch_source_browser_up_to(@source_browser, 0)
        
    children = @source_browser.node('', "0", "201ad72d825eb5e601f1b817172a863a2b4ca72d").children
    assert_equal ['.bar', '.foo', 'foobar'].sort, children.map(&:path).sort
  end
    
  def test_can_get_children_of_non_root_node
    setup_repos('one_changeset_with_many_files')
    synch_source_browser_up_to(@source_browser, 0)
    
    children = @source_browser.node('src', "0", "25c12050e5597a54698b1b0c1c8f8c89b9147548").children
    assert_equal ['src/foo', 'src/foo.rb'].sort, children.map(&:path).sort
  end
  
  def test_can_get_children_of_non_root_node_when_node_contains_dot_files
    setup_repos('dot_files')
    synch_source_browser_up_to(@source_browser, 1)
        
    children = @source_browser.node('foobar', "1", "6681910051b605852dc4c33a88f924e5997dc58d").children
    assert_equal ['foobar/.stuff', 'foobar/non_dot.txt'].sort, children.map(&:path).sort
  end
  
  def test_can_get_children_of_non_root_node_when_node_is_a_dot_file
    setup_repos('dot_files')
    synch_source_browser_up_to(@source_browser, 1)
        
    children = @source_browser.node('.bar', "1", "6681910051b605852dc4c33a88f924e5997dc58d").children
    assert_equal ['.bar/.stuff.txt', '.bar/stuff.txt'].sort, children.map(&:path).sort
  end
  
  def test_children_are_correct_node_types
    setup_repos('one_changeset_with_many_files')
    synch_source_browser_up_to(@source_browser, 0)
    
    children = @source_browser.node('src', "0", "25c12050e5597a54698b1b0c1c8f8c89b9147548").children
    assert children.find{|c| c.name == 'foo'}.dir?
    assert !children.find{|c| c.name == 'foo.rb'}.dir?
  end
  
  def test_most_recent_commit_information_is_included_in_child_nodes
    setup_repos('two_changesets_with_many_files')
    synch_source_browser_up_to(@source_browser, 1)
    
    dir = @source_browser.node('', "1", "bdc6584d0f24562c2bae56ce5abb208126d2a60b")
    children = dir.children
    foo_rb_file = children.find{|c| c.path == 'src'}
    expected_details = ['wpc', java.util.Date.new(Time.mktime(2009, 2, 2, 8, 3, 45).to_i * 1000), 'fake revision from wpc']
    assert_equal expected_details,
      [foo_rb_file.most_recent_committer, foo_rb_file.most_recent_commit_time, foo_rb_file.most_recent_commit_desc]

    readme_file = children.find{|c| c.path == 'README'}
    expected_details = ['jen', java.util.Date.new(Time.mktime(2009, 2, 3, 8, 3, 45).to_i * 1000), 'fake revision from jen']
    assert_equal expected_details,
      [readme_file.most_recent_committer, readme_file.most_recent_commit_time, readme_file.most_recent_commit_desc]
  end
  
  # this is relevant while large chunks of changesets are being cached, particularly during initialization
  def test_child_nodes_are_still_created_if_mingle_revisions_cannot_be_found_to_populate_most_recent_commit_info
    setup_repos('one_changeset_with_subdirs')
    synch_source_browser_up_to(@source_browser, 0)
    
    dir = @source_browser.node('', "0", "32ecc7b520f6110ce0ebef34ae4c650a3126ec91")
    children = dir.children
    children.each do |child|
      assert_nil child.most_recent_committer
      assert_nil child.most_recent_commit_time
      assert_nil child.most_recent_commit_desc
    end
  end
  
  def test_tip_node_returns_proposed_tip_if_its_cached
    setup_repos('hello')
    synch_source_browser_up_to(@source_browser, 1)
    
    assert_equal 1, @source_browser.tip_node('', 1, 
      "82e55d328c8ca4ee16520036c0aaace03a5beb65").changeset_number
  end
  
  def test_tip_node_returns_only_youngest_from_file_cache
    setup_repos('hello')
    synch_source_browser_up_to(@source_browser, 1)
    
    assert_equal 1, @source_browser.tip_node('', 2, 
      "fef857204a0c58caefe249dda038316e856e896d").changeset_number
  end
  
  def test_tip_node_returns_rev_zero_when_nothing_cached
    setup_repos('hello')
    
    assert_equal 0, @source_browser.tip_node('', 2, 
      "fef857204a0c58caefe249dda038316e856e896d").changeset_number
  end

  def test_can_get_file_contents_from_fixed_node
    setup_repos('hello')
    synch_source_browser_up_to(@source_browser, 1)  
    node = @source_browser.node("hello.c", "1", "82e55d328c8ca4ee16520036c0aaace03a5beb65")
    io = StringIO.new
    node.file_contents(io)

    expected_file_contents = %q{/*
 * hello.c
 *
 * Placed in the public domain by Bryan O'Sullivan
 *
 * This program is not covered by patents in the United States or other
 * countries.
 */

#include <stdio.h>

int main(int argc, char **argv)
{
	printf("hello, world!\n");
	return 0;
}
}

    io.rewind
    assert_equal(io.readlines.join, expected_file_contents)
  end

  def synch_source_browser_up_to(source_browser, up_to)
    0.upto(up_to) do |n|
      @source_browser.ensure_file_cache_synched_for(n)
    end
  end

  def assert_equal_hash(expected, actual)
    assert_equal(expected.keys.sort, actual.key_set.sort)
    expected.keys.each do |k|
      unless expected[k] == actual[k]
        fail("Value of #{k} expected to be #{expected[k]} but was #{actual[k]}")
      end
    end
  end  
    
end