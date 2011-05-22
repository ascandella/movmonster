class Movie
  include DataMapper::Resource

  property :filename, FilePath, :key => true
  property :name,     String
  property :genres,   Text
  property :year,     Integer
  property :rating,   Float
  property :director, Text
  property :imdb_id,  String
  property :certification, String

end
