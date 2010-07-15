# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

require 'rubygems'
require 'active_support'
require 'active_record'
require 'test/unit'
require 'ostruct'
require 'md5'
require 'fileutils'

# Used to create tmp paths in testing
module RandomString 
  def size_32
    md5 = Digest::MD5::new
    now = Time.now
    md5.update(now.to_s)
    md5.update(now.usec.to_s)
    md5.hexdigest
  end
  module_function :size_32  
end

# Stub Mingle's NoSuchRevisionError, which must be thrown by the plugin
# in a couple of places in order for Mingle to work correctly.  
#
# This code is included here because HgRepository raises this exception. This
# requires that some definition of the module be present in test code in order for tests to run.
# When deployed to Mingle, Mingle will supply this code.  
#
# TODO: I'd love to kill this dependency
class Repository  
  class NoSuchRevisionError < StandardError
  end
end

# RepositoryModelHelper is a direct copy of Mingle source that allows for the existing
# SVN and Perforce plugins to have fairly simple controllers. Mixing this module into your
# configuration allows for save to know whether to perform a simple update of the model
# or a delete, while saving a copy with applied changes.  The latter being appropriate
# when a fresh repository synch is needed, e.g., the repository path is changed.
#
# This code is included here because HgConfiguration mixes in this model. This
# requires that some definition of the module be present in test code in order for tests to run.
# When deployed to Mingle, Mingle will supply this code.  
module RepositoryModelHelper
  def self.included(base)
    base.extend ClassMethods
  end
  
  module ClassMethods
    
    # depends upon :repository_location_changed?, :mark_for_deletion
    def create_or_update(project_id, id, options={})
      options = options.symbolize_keys
      options.delete(:project_id)
      options.delete(:id)

      if !id.blank? && config = self.find_by_project_id_and_id(project_id, id)
        if config.username != options[:username].to_s.strip
          config.password = nil
        end

        if config.repository_location_changed?(options.dup)
          config.mark_for_deletion
          create_or_update(project_id, nil, config.clone_repository_options.merge(options))
        else
          config.update_attributes(options)
          config
        end
      else
        options.merge! :project_id => project_id
        self.create(options)
      end
    end
  end
  
  #overwrite this method if behaviour is different
  def mark_for_deletion
    update_attribute :marked_for_deletion, true
  end  
end

# Most all Mingle models use this to trim leading and trailing whitespace
# before writing to the database.  You can use this in your configuration model
# if you wish the same convenience. 
#
# This code is included here because HgConfiguration uses strip_on_write. This
# requires that some definition of the module be present in test code in order for tests to run.
# When deployed to Mingle, Mingle will supply this code.  
class ActiveRecord::Base
  class << self
    def strip_on_write(options={})
      return if instance_methods.include?("write_attribute_with_strip")
      exceptions = options[:except] || []
      self.send(:define_method, :should_strip?, lambda do |attribute_name|
        !(options[:except] || []).include?(attribute_name.to_sym)
      end)
      
      self.send(:define_method, :write_attribute_with_strip, lambda do |attribute_name, value|
        if should_strip?(attribute_name) && value.respond_to?(:trim)
          value = value.trim
        end
        write_attribute_without_strip(attribute_name, value)
      end)
      
      alias_method_chain :write_attribute, :strip
    end
  end  
end

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

# stub the Mingle Project
class Project  
  def encrypt(text)
    "ENCRYPTED" + text
  end
  
  def decrypt(text)
    text.split("ENCRYPTED").last
  end
  
  def id
    3487
  end
  
  def new_record?
    false
  end
  
  def identifier
    "test_project"
  end  
end

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
      RandomString.size_32
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

class StubMingleRevisionRepository

  def initialize
    @mingle_revs = {}
    @mingle_revs['bdc6584d0f24562c2bae56ce5abb208126d2a60b'] = OpenStruct.new(
      :user => 'wpc',
      :commit_time => Time.mktime(2009, 2, 2, 8, 3, 45),
      :commit_message => 'fake revision from wpc'
    )
    @mingle_revs['25c12050e5597a54698b1b0c1c8f8c89b9147548'] = OpenStruct.new(
      :user => 'jen',
      :commit_time => Time.mktime(2009, 2, 3, 8, 3, 45),
      :commit_message => 'fake revision from jen'
    )
  end

  def sew_in_most_recent_changeset_data_from_mingle(children)
    children.each do |child|
      mingle_rev = @mingle_revs[child.most_recent_changeset_identifier]
      if (!mingle_rev.nil?)
        child.most_recent_committer = mingle_rev.user
        child.most_recent_commit_time = mingle_rev.commit_time
        child.most_recent_commit_desc = mingle_rev.commit_message
      end
    end
  end

end

class NoOpMingleRevisionRepository
  def sew_in_most_recent_changeset_data_from_mingle(children)
  end
end

module GitPatchSnippets
  
  TWO_ADDS = %q{diff --git a/person.rb b/person.rb
new file mode 100644
--- /dev/null
+++ b/person.rb
@@ -0,0 +1,13 @@
+class Employee
+  
+  attr_accessor :name, :age, :salary, :start_date, :tasks
+  
+  def initialize(name, age, salary, start_date, tasks)
+    @name = name
+    @age = age
+    @salary = salary
+    @start_date = start_date
+    @tasks = tasks
+  end
+  
+end
\ No newline at end of file
diff --git a/task.rb b/task.rb
new file mode 100644
--- /dev/null
+++ b/task.rb
@@ -0,0 +1,10 @@
+class Task
+  
+  attr_accessor :name, :description
+  
+  def initialize(name, description)
+    @name = name
+    @description = description
+  end
+  
+end
\ No newline at end of file
}

  DELETE = %q{diff --git a/salary.rb b/salary.rb
deleted file mode 100644
--- a/salary.rb
+++ /dev/null
@@ -1,9 +0,0 @@
-class Salary
-  
-  attr_reader :amount
-  
-  def initialize(amount)
-    @amount = amount
-  end
-  
-end
\ No newline at end of file
}

  RENAME_WITH_MODIFY = %q{diff --git a/task.rb b/todo.rb
rename from task.rb
rename to todo.rb
--- a/task.rb
+++ b/todo.rb
@@ -1,4 +1,4 @@
-class Task
+class Todo

   attr_accessor :name, :description

}

  FUNKY_PATHS = %q{diff --git a/foo/n o o b/b c a/README b/foo/n o o b/README.txt
rename from foo/n o o b/b c a/README
rename to foo/n o o b/README.txt

}

  MODIFY = %q{diff --git a/person.rb b/person.rb
--- a/person.rb
+++ b/person.rb
@@ -1,13 +1,13 @@
 class Employee

-  attr_accessor :name, :age, :salary, :start_date, :tasks
+  attr_accessor :name, :age, :salary, :start_date, :todos

-  def initialize(name, age, salary, start_date, tasks)
+  def initialize(name, age, salary, start_date, todos)
     @name = name
     @age = age
     @salary = salary
     @start_date = start_date
-    @tasks = tasks
+    @todos = todos
   end

 end
\ No newline at end of file}

  BINARY_ADD = <<-SNIPPET
diff --git a/image.png b/image.png
new file mode 100644
index 0000000000000000000000000000000000000000..9f0927f73e033a6b16f069a349cc608a72ce5174
GIT binary patch
literal 11168
zc$@*CD__(fiwFqJ7A8pm17mDyW@cYxVlH!WYyj<jdvofzvhUxlPeHA!eP`wlGYgyd
zn%Y$t2ua9FNFWIiYE@Bw1)Lb0!H_^c{b|W>Te4-aGjng<GqcYGTW<YY>Tb29mimuB
zzWnh=@y;-}i;Z$Wye`VZRuBbKDayOm8s2^Ra^HI>N}8(Z+qt4khOFv~;(v?3K;e1&
zzT5Br@)s^*ZUtQyHu79D^k-wUf?{)XyMh0hP~3Qawu(thMS7h-?{sOa8v0xWdI~D=
zENG_km%lQgFkdOADJ*b-cVVLgF{_ATO2S&P>Cf#~PBjQMFf|ZX%J<@Z_p*1>F0OZ?
zrb>Sm9}a7H*uA~E=?xzKD&7N}mGHgz$6v+UcU{@QUzlgRK=F1EBv9<%1LroU&NCAe}
  SNIPPET
  
  BINARY_MODIFY = <<-SNIPPET
diff --git a/image.png b/image.png
index 9f0927f73e033a6b16f069a349cc608a72ce5174..b0349fd40a279047c70a0b1fcbd74f5cd8a44d6b
GIT binary patch
literal 247052
zc$^ehV_2na5I!f{wz=_S+qT`wt__=Ao2|{p?uO0gR;SI_YO`(Q>-+V-*E4g?%rm&>
zerVOCWLP*@K}fWNyH~r%71xDRgTqK%6zmi(7WPO&LKJLD*3LGbwiMhSM;a7tGIoxh
z*6tr)M{`eWDQim?D{Bf75hM>!cWZMeBp+Z?*J(qotlRlx*N<XRNK6v-)Ru41r4%F_
z1IiO6<&#sd$o6A!3oUX|czo}YhbXoi>%P&<<Lj~S@vruV_V+IQ&r2uTo;EhtVC&s4
zug{O?lkb7wE3Thk*423T-JJgfy<EK<UwiM92R;M@1U|pEiRh}HLf*CJ+XRB%?^Y)#
  SNIPPET
  
  BINARY_DELETE = <<-SNIPPET
diff --git a/image.png b/image.png
deleted file mode 100644
Binary file image.png has changed

  SNIPPET
  
  BINARY_RENAME_WITH_MODIFY = <<-SNIPPET
diff --git a/image.png b/picture.png
rename from image.png
rename to picture.png
index 5008ddfcf53c02e82d7eee2e57c38e5672ef89f6..b0349fd40a279047c70a0b1fcbd74f5cd8a44d6b
GIT binary patch
literal 247052
zc$^ehV_2na5I!f{wz=_S+qT`wt__=Ao2|{p?uO0gR;SI_YO`(Q>-+V-*E4g?%rm&>
zerVOCWLP*@K}fWNyH~r%71xDRgTqK%6zmi(7WPO&LKJLD*3LGbwiMhSM;a7tGIoxh
z*6tr)M{`eWDQim?D{Bf75hM>!cWZMeBp+Z?*J(qotlRlx*N<XRNK6v-)Ru41r4%F_
z1IiO6<&#sd$o6A!3oUX|czo}YhbXoi>%P&<<Lj~S@vruV_V+IQ&r2uTo;EhtVC&s4
zug{O?lkb7wE3Thk*423T-JJgfy<EK<UwiM92R;M@1U|pEiRh}HLf*CJ+XRB%?^Y)#
zW`)pieQSrWTlP(Yl(mCq3f518@}t0hM@QfPd`F$voTPuM2>kxAd!s8X694+>^mNRn
  SNIPPET
  
  COPY = <<-SNIPPET
diff --git a/trunk/README b/tags/thought_viscera-3.6/README
copy from trunk/README
copy to tags/thought_viscera-3.6/README
diff --git a/trunk/Rakefile b/tags/thought_viscera-3.6/Rakefile
copy from trunk/Rakefile
copy to tags/thought_viscera-3.6/Rakefile
  SNIPPET
  
end

