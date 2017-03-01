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


# 親
class Parent < ActiveRecord::Base
  self.table_name = 'salesforce.parent__c'
#  has_many :childs, primary_key: 'sfid', foreign_key: 'parent__c', class_name: 'Child'

end

# 子
class Child < ActiveRecord::Base
  self.table_name = 'salesforce.child__c'
#  belongs_to :parent, primary_key: :sfid, foreign_key: :parent__c
end



get "/parents" do
  @parents = Parent.all
  erb :index_parents
end


get "/parent_detail/:id" do
  id =  params[:id]
  @parent = Parent.where(:id => id).first

  logger.info('あ')
  logger.info(@parent.inspect)

  logger.info('い')
  child = Child.where(:parent__c => @parent.sfid)

  logger.info('う')
  logger.info(child.inspect)


#  erb :parent_detail
end
