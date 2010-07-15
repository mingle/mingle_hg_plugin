require 'rubygems'
require 'activeresource'
require 'test/unit'

class ApiTest < Test::Unit::TestCase
    
  def test_get
    HgConfiguration.site = "http://david:p@localhost:8080/projects/hg_plugin_chinese_chars"
    HgConfiguration.prefix = "/projects/hg_plugin_chinese_chars/"
    config = HgConfiguration.find(:first)
    puts config.id
    HgConfiguration.delete(config.id)
  end
  
  def test_create
    HgConfiguration.site = "http://david:p@localhost:8080/projects/hg_plugin_chinese_chars"
    HgConfiguration.prefix = "/projects/hg_plugin_chinese_chars/"
    config = HgConfiguration.create(:repository_path => '/Users/djrice/studios/mingle_hg_plugin')
  end
  
  def test_update
    HgConfiguration.site = "http://david:p@localhost:8080/projects/hg_plugin_chinese_chars"
    HgConfiguration.prefix = "/projects/hg_plugin_chinese_chars/"
    config = HgConfiguration.find(:first);
    config.repository_path = '/Users/djrice/studios/anti_alm/spike_one'
    config.save
  end
    
  class Card < ActiveResource::Base
  end
  
  class HgConfiguration < ActiveResource::Base
  end
end