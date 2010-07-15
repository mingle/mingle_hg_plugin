# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class HgHtmlDiffTest < Test::Unit::TestCase

  def test_truncated_change_is_reflected_in_html
    repository = TestRepositoryFactory.create_repository_without_source_browser('big_diff')
    git_patch = repository.git_patch_for(repository.changeset('1'), 10)
    diff = HgHtmlDiff.new(git_patch.changes.first, 1)
    assert diff.content.index("diff truncated")
  end

  def test_content_does_not_show_truncation_message_when_not_needed
    repository = TestRepositoryFactory.create_repository_without_source_browser('big_diff')
    git_patch = repository.git_patch_for(repository.changeset('1'), 100)
    diff = HgHtmlDiff.new(git_patch.changes.first, 1)
    assert !diff.content.index("diff truncated")
  end

end
