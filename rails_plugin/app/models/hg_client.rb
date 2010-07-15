# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

require 'rexml/document'
require 'md5'
require File.expand_path(File.join(File.dirname(__FILE__), 'hg_java_env'))

# HgClient makes it easier to invoke the hg cmd line client
class HgClient
  
  def initialize(java_hg_client)
    @java_hg_client = java_hg_client
  end

  def repository_empty?
    @java_hg_client.repository_empty?
  end

  def log_for_rev(rev)
    log_for_revs(rev, rev).first
  end

  def log_for_revs(from, to)
    begin
      @java_hg_client.log_for_revs(from.to_s, to.to_s).map do |log_entry|
        [
          log_entry.rev_number,
          log_entry.identifier,
          log_entry.epoch_time,
          log_entry.committer,
          log_entry.description
        ]
      end
    rescue NativeException => e
      raise e.cause.message
    end
  end

  def git_patch_for(rev, git_patch)
    @java_hg_client.git_patch_for(rev, GitPatchLineHandler.new(git_patch))
    git_patch.done_adding_lines
  end

  def binary?(path, rev)
    @java_hg_client.binary?(path, rev)
  end

  def pull
    @java_hg_client.pull
  end
    
  def ensure_local_clone
    @java_hg_client.ensure_local_clone
  end
  
  def try_to_connect
    @java_hg_client.try_to_connect
  end

end

class GitPatchLineHandler
  include com.thoughtworks.studios.mingle.hg.cmdline::LineHandler

  def initialize(git_patch)
    @git_patch = git_patch
  end

  def handleLine(line)
    @git_patch.add_line(line)
  end

end
