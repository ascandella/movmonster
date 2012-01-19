require 'test-common'


describe "the environment" do
  it "should respond to both strings and symbols" do
    MovMonster::Configurator['categories'].should == MovMonster::Configurator[:categories]
  end

  it "should know about categories" do
    cats = MovMonster::Configurator[:categories]
    cats.should_not be_nil
    cats.length.should be > 0
  end
end

describe "the database" do
  before(:all) do
    @monster = MovMonster::Monster.new
    MovMonster::Ignore.all.destroy
  end

  it "should not have anything to prune" do
    MovMonster::Ignore.all.count.should be 0
  end
end
