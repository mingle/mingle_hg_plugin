# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'ostruct'

module JavaLang
  include_package "java.lang"
end

module FooUtil
  include_package "com.thoughtworks.studios.mingle.hg.util"
end

def setup_repository(master_path, project_identifier)
  cache_base = File.expand_path("#{File.dirname(__FILE__)}/../../../tmp/break_and_perf")
  clone_path = File.expand_path(File.join(cache_base, 'mercurial', project_identifier, 'repos'))
  style_dir = File.expand_path("#{File.dirname(__FILE__)}/../../app/templates")
  @java_hg_client = com.thoughtworks.studios.mingle.hg.hgcmdline::HgClient.new(master_path, clone_path, style_dir)
  @hg_client = HgClient.new(@java_hg_client)
  source_browser_cache_path = File.expand_path(File.join(cache_base, 'mercurial', project_identifier, 'source'))
  mingle_rev_repos = nil
  @source_browser = HgSourceBrowser.new(
    @java_hg_client, source_browser_cache_path, mingle_rev_repos
  )
  @repository = HgRepository.new(@hg_client,  @source_browser)
  @repository = HgRepositoryClone.new(HgSourceBrowserSynch.new(@repository, @source_browser))

  tip_number = @repository.changeset("tip").revision_number
  0.upto(tip_number){|n| @source_browser.ensure_file_cache_synched_for(n)}
end


setup_repository("/tmp/chinese_repos", "chinese_repos")
log_entry = @java_hg_client.log_for_rev("0");

puts "FROM HG CLIENT:"
puts log_entry.description
log_entry.description.each_byte{|b| puts b}

puts "\n\nFROM JAVA OBJECT:"
puts FooUtil::StringMaker.chineseString
FooUtil::StringMaker.chineseString.each_byte{|b| puts b}

puts "\n\nRUBY STRING"
puts "这是中文"
"这是中文".each_byte{|b| puts b}
puts FooUtil::StringMaker.chineseString == "这是中文"
puts FooUtil::StringMaker.asciiString == "abc"




