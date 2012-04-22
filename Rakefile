require 'rubygems'
require 'bundler/setup'
require 'releasy'

Releasy::Project.new do
  name "TinyWorld"
  version "0.0.1"

  executable "tinyworld.rb"
  files ['tinyworld.rb', 'gfx/**/*.*', 'sfx/**/*.*', 'play.yml']
  add_link 'http://www.spilth.org/projects/ludum-dare-23', 'spilth.org'
  exclude_encoding

  add_build :osx_app do
    url 'org.spilth.ld23'
    wrapper 'support/gosu-mac-wrapper-0.7.41.tar.gz'
    icon 'media/donut.icns'
    add_package :tar_gz
  end
  
  add_build :windows_folder do
    icon "media/icon.ico"
    executable_type :windows
    add_package :exe
  end

end


