# app.rb

require 'sinatra'
require 'sinatra/activerecord'
require './environments'


get "/" do
  erb :home
end


class Contact < ActiveRecord::Base
  self.table_name = 'salesforce.contact'
end

get "/contacts" do
  @contacts = Contact.all
  erb :index
end

get "/create" do
  dashboard_url = 'https://dashboard.heroku.com/'
  match = /(.*?)\.herokuapp\.com/.match(request.host)
  dashboard_url << "apps/#{match[1]}/resources" if match && match[1]
  redirect to(dashboard_url)
end


# e
class Parent < ActiveRecord::Base
  self.table_name = 'salesforce.parent__c'
end


get "/parents" do
  @parents = Parent.all
  erb :index_parents
end


get "/parent_detail/:id" do
  puts prams[:id]
  erb :parent_detail
end
