require 'test-common'

def get_movie(name, destroy_first = true)
  if destroy_first
    movie = Movie.first :name => name
    Configurator.log.info "Destroy #{movie}"
    movie.destroy unless movie.nil?
  end

  Configurator.log.error Movie.count :name => name

  filename = create_mock_movie name
  @monster.lookup_movie filename
end

describe 'the monster' do
  before(:all) do
    @monster = MovMonster.new
    Movie.all.destroy
    Poster.all.destroy
  end

  it 'should be able to look up a movie' do
    name = 'A Few Good Men'
    get_movie(name)
    movie = Movie.first :name => name
    movie.should exist
    movie.imdb_id.should == 'tt0104257'
  end

  it 'should categorize movies by genre' do
    name = 'The Life Aquatic With Steve Zissou'
    get_movie name
    movie = Movie.first :name => name
    base_name = File.basename(movie.filename)
    movie_path = Pathname.new movie.filename
    movie.genres.split(',').each do |genre|
      name = File.join(Configurator[:destination_dir],
                       Configurator[:categories]['genres'],
                       genre, base_name)
      File.readlink(name).to_s.should == movie.filename.to_s
    end
  end
end
