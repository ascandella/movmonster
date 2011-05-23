class Poster
  include DataMapper::Resource

  property :id,       Serial
  property :location, Text
  property :width,    Integer
  property :height,   Integer
  property :size,     String

  belongs_to :movie

  def href 
    location.sub('web/public/', '')
  end
end
