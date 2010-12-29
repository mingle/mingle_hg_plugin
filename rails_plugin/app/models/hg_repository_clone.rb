# Copyright 2010 ThoughtWorks, Inc. Licensed under the Apache License, Version 2.0.

# HgRepositoryClone manages when to pull from master to clone. Behavior pulled into
# decorator as it makes tests much faster and also keeps HgRepository more single-minded.
class HgRepositoryClone
    
  include FileUtils

  def initialize(repository, error_file_dir, project, retry_errored_connect = false)
    @repository = repository
    @error_file_dir = error_file_dir

    if File.exist?(error_file) && !retry_errored_connect
      raise StandardError.new(
        %{Mingle cannot connect to the Hg repository for project #{project.identifier}. 
        The details of the problem are in the file at #{error_file_dir}/error.txt}
      )
    end
  end

  def method_missing(method, *args)
    begin
      @repository.ensure_local_clone
      @repository.pull if (method.to_sym == :next_revisions) 
      delete_error_file 
    rescue StandardError => e
      write_error_file(e)
      raise e
    end

    @repository.send(method, *args)
  end

  private 

  def error_file
    "#{@error_file_dir}/error.txt"
  end

  def delete_error_file
    rm_f(error_file)
  end

  def write_error_file(e)    
    mkdir_p(File.dirname(error_file))
    File.open(error_file, 'w') do |file|
      file << "Message:\n#{e.message}\n\nTrace:\n"
      file << e.backtrace.join("\n")
    end
  end
    
end
