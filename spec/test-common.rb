require 'rspec/expectations'

@@base_dir = File.join(File.dirname(__FILE__), '..')

%w{configurator movmonster}.map {|f| require File.join(@@base_dir, 'src', f)}

@@config_file = File.join(@@base_dir, 'config.yml')

MovMonster::Configurator.load_yaml(@@config_file, 'test')
MovMonster::Configurator.merge! :stdout => true
MovMonster::Configurator.setup!

def create_mock_movie(name, ext = '.avi')
  full = name + ext
  fname = File.join(@@base_dir, MovMonster::Configurator[:base_dirs][0], full)
  File.new(fname, 'w') unless File.exist? fname
  full
end
