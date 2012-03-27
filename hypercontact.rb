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
  html = <<-eos
      <html>
        <head>
          <title>Hypercontact</title>
        </head>
        <body>
          <p>
            This is a very simple example REST API (source code <a href="http://github.com/aschepis/hypercontact">here</a>)
            that was built to show how load testing an API works using <a href="https://www.cloudassault.com">Cloud Assault</a>
          </p>
        </body>
      </html>
    eos
  return [200, {'Link' => 'http://hypercontact.heroku.com/contacts; rel=contacts'},'']
end

get '/contacts' do
  # todo: is there a better way to do arrays w/ roar gem?
  contacts_json = Contact.all.map {|c| c.extend(ContactRepresenter).to_json}
  [200, {'Content-Type' => 'application/vnd.hypercontact-list+json', 'Link' => 'http://hypercontact.heroku.com/contacts; rel=new'}, '[' + contacts_json.join(',') + ']' ]
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

put '/contacts/:id' do
  contact = Contact.where(:_id => params['id']).first.extend(ContactRepresenter)
  return [404, {'Content-Type' => 'application/vnd.hypercontact-error+json'}, '{"error":"not found"}'] if contact.nil?
  
  contact.update(JSON.parse request.body.read)
  return [200, {'Content-Type' => 'application/vnd.hypercontact+json'}, contact.to_json] unless contact.nil?  
end

delete '/contacts/:id' do
  contact = Contact.where(:_id => params['id']).first
  return [404, {'Content-Type' => 'application/vnd.hypercontact-error+json'}, '{"error":"not found"}'] if contact.nil?
  contact.destroy
  return 204
end
  