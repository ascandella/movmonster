require 'rspec/expectations'

@@base_dir = File.join(File.dirname(__FILE__), '..')

%w{configurator movmonster}.map {|f| require File.join(@@base_dir, 'src', f)}

@@config_file = File.join(@@base_dir, 'config.yml')

Configurator.load_yaml(@@config_file, 'test')
Configurator.merge! :stdout => true
Configurator.setup!

def create_mock_movie(name, ext = '.avi')
  full = name + ext
  fname = File.join(@@base_dir, Configurator[:base_dir], full)
  File.new(fname, 'w') unless File.exist? fname
  full
end
