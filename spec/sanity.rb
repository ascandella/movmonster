require 'rspec/expectations'

base_dir = File.join(File.dirname(__FILE__), '..')
require File.join(base_dir, 'src/configurator')
require File.join(base_dir, 'src/movmonster')

config_file = File.join(base_dir, 'config.yml')

describe "the environment" do
  before(:all) do
    Configurator.load_yaml(config_file, 'test') 
  end

  it "should respond to both strings and symbols" do
    Configurator['categories'].should == Configurator[:categories]
  end

  it "should know about categories" do
    cats = Configurator['categories']
    cats.should_not be_nil
    cats.length.should be > 0
  end
end

describe "the database" do
  before(:all) do
    Configurator.load_yaml(config_file, 'test') 
    Configurator.setup!

    @monster = MovMonster.new
  end

  it "should not have anything to prune" do
    # TODO: Movie.all or Ignore.all
  end
end
