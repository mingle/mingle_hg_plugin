# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

# HgChange provides the detail on a single file change within an HgChangeset.
#
# Required by Mingle: file?, path, path_components, action, 
# action_class, binary?, modification?, html_diff
class HgChange
  
  # construct an HgChange from an HgGitChange. changeset_index is the index
  # of this change within the changeset and is used in diff styling
  def initialize(git_change, changeset_index)
    @git_change = git_change
    @changeset_index = changeset_index
  end

  # required by mingle
  # *returns*: whether change is a file. always true for mercurial
  def file?
    true
  end

  # required by mingle
  # *returns*: the path of the file change, relative to the repository root
  def path
    @git_change.path
  end
  
  # *returns*: the old path of the file if change is a rename; nil if not a rename
  def renamed_from_path
    @git_change.renamed_from_path
  end
  
  # required by mingle
  def path_components
    @path_components ||= path.split('/')
  end
  
  # required by mingle
  # *returns*: the type of change as single-letter representation for use in mingle feed rendering.
  def action
    @git_change.change_type.map{|ct| ct.to_s[0..0].upcase}.join
  end

  # required by mingle
  # *returns*: the type of change as a css classname for use in revision show page.
  def action_class
    # todo (med) shouldn't we move this logic into mingle??
    # must combine to single class since it's driving a bg image
    @git_change.change_type.join('-') 
  end

  # required by mingle
  # *returns*: whether this file has binary content
  def binary?
    @git_change.binary?
  end

  # required by mingle
  # *returns*: whether this change was a modification
  def modification?
    @git_change.change_type.include?(:modified)
  end
  
  # required by mingle
  # *returns*: whether this change was a file deletion 
  def deleted?
    @git_change.change_type.include?(:deleted)
  end
  
  # required by mingle
  # *returns*: whether this change was a rename
  def renamed?
    @git_change.change_type.include?(:renamed)
  end
  
  # required by mingle
  # *returns*: html snippet containing a diff of this change
  def html_diff
    HgHtmlDiff.new(@git_change, @changeset_index).content
  end
  
end
