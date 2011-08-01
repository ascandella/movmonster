require 'test-common'

describe 'the ignore bot' do
  before(:all) do
    Ignore.all.destroy
    @monster = MovMonster.new
  end

  it 'should ignore movies that do not exist' do
    invalid_name = 'That one movie where the guy gets the girl.mp4'
    @monster.lookup_movie(invalid_name)
    ignore_record = Ignore.first :filename => invalid_name
    ignore_record.should_not be_nil
    ignore_record.filename.should == invalid_name
  end
end
