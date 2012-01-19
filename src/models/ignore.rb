module MovMonster
  class Ignore 
    include DataMapper::Resource
    property :filename, String, :key => true
  end
end
