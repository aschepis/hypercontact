require 'roar/representer/json'
require 'roar/representer/feature/hypermedia'


module ContactRepresenter
  include Roar::Representer::JSON
  include Roar::Representer::Feature::Hypermedia
  
  property :name
  property :address
  property :city
  property :state
  property :zip
  property :notes
  
  link :self do
    "http://hypercontact.heroku.com/contacts/#{self.id}"
  end 
end