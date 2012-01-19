require 'test-common'

def get_movie(name, destroy_first = true)
  if destroy_first
    movie = MovMonster::Movie.first :name => name
    MovMonster.log.info "Destroying record for '#{movie}'"
    movie.destroy unless movie.nil?
  end

  filename = create_mock_movie name
  @monster.lookup_movie filename
end

describe 'the monster' do
  before(:all) do
    @monster = MovMonster::Monster.new
    MovMonster::Movie.all.destroy
    MovMonster::Poster.all.destroy
  end

  it 'should be able to look up a movie' do
    name = 'A Few Good Men'
    get_movie(name)

    MovMonster.log.info "Expecting to find '#{name}' in movies table"
    movie = MovMonster::Movie.first :name => name
    movie.should exist
    movie.imdb_id.should == 'tt0104257'
    MovMonster::Configurator.log.info "Found it: #{movie.inspect}"
  end

  it 'should handle data access' do
    name = 'The Royal Tenenbaums'
    movie = get_movie(name)

    movie.imdb_id.should == 'tt0265666'
    movie.genres.split(',').should include 'Comedy'
  end

  it 'should categorize movies by genre' do
    name = 'The Life Aquatic With Steve Zissou'
    movie = get_movie name
    base_name = File.basename(movie.filename)

    MovMonster.log.info "Expecting symlinks for each of the genres: #{movie.genres}"
    movie.genres.split(',').each do |genre|
      name = File.join(MovMonster::Configurator[:destination_dir],
                       MovMonster::Configurator[:categories]['genres'],
                       genre, base_name)
      MovMonster.log.info "Found link at #{name}"
      File.readlink(name).to_s.should == movie.filename.to_s
    end
    MovMonster.log.info 'Genres seem sane'
  end

end
