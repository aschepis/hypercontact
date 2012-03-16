require 'sinatra'
require 'mongo'
require 'uri'
require_relative './contact'
require_relative './contact_representer'

Mongoid.configure do |config|
  config.master = Mongo::Connection.from_uri(ENV['MONGOLAB_URI'], :logger => Logger.new(STDOUT)).db('heroku_app3171386')
  config.logger = Logger.new($stdout, :info)
end

get '/' do
  return [200, {'Link' => 'http://hypercontact.heroku.com/contacts; rel=contacts'},'']
end

get '/contacts' do
  [200, {'Content-Type' => 'application/vnd.hypercontact-list+json'}, (Contact.all.map {|c| c.extend(ContactRepresenter)}).to_json]
end

post '/contacts' do
  contact = Contact.create(JSON.parse request.body.read)
  puts contact.save
  [201, {'Content-Type' => 'application/vnd.hypercontact+json'}, contact.extend(ContactRepresenter).to_json] unless contact.nil?
end

get '/contacts/:id' do
  contact = Contact.where(:_id => params['id']).first.extend(ContactRepresenter)
  
  return [200, {'Content-Type' => 'application/vnd.hypercontact+json'}, contact.to_json] unless contact.nil?
  [404, {'Content-Type' => 'application/vnd.hypercontact-error+json'}, '{"error":"not found"}']
end

delete '/contacts/:id' do
  contact = Contact.where(:_id => params['id']).first
  return [404, {'Content-Type' => 'application/vnd.hypercontact-error+json'}, '{"error":"not found"}'] if contact.nil?
  contact.destroy
  return 204
end
  