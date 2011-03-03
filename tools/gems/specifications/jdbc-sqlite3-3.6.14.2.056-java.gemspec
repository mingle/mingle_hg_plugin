# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{jdbc-sqlite3}
  s.version = "3.6.14.2.056"
  s.platform = %q{java}

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Sieger, Ola Bini and JRuby contributors"]
  s.date = %q{2010-10-10}
  s.description = %q{Install this gem and require 'sqlite3' within JRuby to load the driver.}
  s.email = %q{nick@nicksieger.com, ola.bini@gmail.com}
  s.extra_rdoc_files = ["Manifest.txt", "README.txt", "LICENSE.txt"]
  s.files = ["Manifest.txt", "Rakefile", "README.txt", "LICENSE.txt", "lib/sqlitejdbc-3.6.14.2.056.jar", "lib/jdbc/sqlite3.rb"]
  s.homepage = %q{http://jruby-extras.rubyforge.org/ActiveRecord-JDBC}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{jruby-extras}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{SQLite3 JDBC driver for Java and SQLite3/ActiveRecord-JDBC.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rubyforge>, [">= 2.0.4"])
    else
      s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
    end
  else
    s.add_dependency(%q<rubyforge>, [">= 2.0.4"])
  end
end
