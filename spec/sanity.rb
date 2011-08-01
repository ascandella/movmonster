require 'test-common'


describe "the environment" do
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
    @monster = MovMonster.new
  end

  it "should not have anything to prune" do
    Ignore.all.count.should be 0
  end
end
