require 'mongoid'

class Contact
  include Mongoid::Document
  # connection Mongo::Connection.from_uri(ENV['MONGOLAB_URI'], :logger => Logger.new(STDOUT))
  # set_database_name "heroku_app3171386"
  attr_accessible :name, :address, :city, :state, :zip, :notes
  
  field :name, type: String
  field :address, type: String
  field :city,    type: String
  field :state,   type: String
  field :zip,     type: String
  field :notes,   type: String
  
end