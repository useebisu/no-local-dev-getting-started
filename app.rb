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


# 親エンティティ
class Parent < ActiveRecord::Base
  self.table_name = 'salesforce.parent__c'
  has_many :childs, primary_key: 'sfid', foreign_key: 'parent__c', class_name: 'Child'

end

# 子エンティティ
class Child < ActiveRecord::Base
  self.table_name = 'salesforce.child__c'
  belongs_to :parent, primary_key: :sfid, foreign_key: :parent__c
end


# 親一覧
get "/parents" do
  @parents = Parent.all
  erb :index_parents
end


# 親詳細
get "/parent_detail/:id" do
  id =  params[:id]
  @parent = Parent.where(:id => id).first

  #logger.info('あ')
  #logger.info(@parent.inspect)

  #logger.info('い')
  #child = Child.where(:parent__c => @parent.sfid)

  #logger.info('う')
  #logger.info(child.inspect)

  #logger.info('え')
  #logger.info(@parent.childs.inspect)

  @childs = @parent.childs

  erb :parent_detail
end

# 親登録画面遷移
get "/parent_new" do
  erb :parent_new
end

# 親登録
post "/parent_new_complete" do
  @parent = Parent.new
  @parent.parent__c = parent.sfid
  @parent.sei__c = params[:sei__c]
  @parent.mei__c = params[:mei__c]
  @parent.save!
  path = 'parent_detail/' + @parent.id_to_s
  redirect path
end




# 子登録画面遷移
get "/child_new/:parent_id" do
  @parent_id =  params[:parent_id]
  erb :child_new
end

# 子登録
post "/chile_new_complete" do
  parent_id = params[:parent_id]
  parent = Parent.where(:id => parent_id).first

  child = Child.new
  child.parent__c = parent.sfid
  child.sei__c = params[:sei__c]
  child.mei__c = params[:mei__c]
  child.save!
  path = 'parent_detail/' + parent_id.to_s
  redirect path
end

