# app.rb
require 'tilt/erb'
require 'rest-client'
require 'heroku-api'
require 'sinatra'
require 'sinatra/activerecord'
require 'json'
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

# 孫エンティティ
class Grandchild < ActiveRecord::Base
  self.table_name = 'salesforce.grandchild__c'
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
  @parent.sei__c = params[:sei__c]
  @parent.mei__c = params[:mei__c]
  @parent.save!
  path = 'parent_detail/' + @parent.id.to_s
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
  child.external_id__c = SecureRandom.uuid
  child.save!
  path = 'parent_detail/' + parent_id.to_s
  redirect path
end


# 孫一覧
get "/gchilds" do
  @gchilds = Grandchild.all
  erb :index_gchilds
end


# 孫詳細
get "/gchild_detail/:id" do
  id =  params[:id]
  @gchild = Grandchild.where(:id => id).first

  erb :gchild_detail
end

# 孫登録画面遷移
get "/gchild_new" do
  erb :gchild_new
end

# 孫登録
post "/gchild_new_complete" do
  @gchild = Grandchild.new
  @gchild.uuid__c = params[:uuid__c]
  @gchild.text__c = params[:text__c]
  @gchild.mail__c = params[:mail__c]
  @gchild.save!
  path = 'gchild_detail/' + @gchild.id.to_s
  redirect path
end

# 孫更新
post "/gchild_edit_complete" do
  @gchild = Grandchild.where(:id => params[:id]).first
  @gchild.uuid__c = params[:uuid__c]
  @gchild.text__c = params[:text__c]
  @gchild.mail__c = params[:mail__c]
  @gchild.save!
  redirect 'gchilds'
end



# heroku-api
get "/herokus" do
  @heroku_api = Heroku::API.new(:api_key => 'c7283065-0c22-40ee-a227-939559be0bad')
  @apps = @heroku_api.get_apps.body

  @hoge = RestClient.get('https://api.status.salesforce.com/v1/instances/AP0/status')
  logger.info('----------Salesforce AP0 status start--------------------')
  logger.info(@hoge)
  @result = JSON.parse(@hoge)

  #sort
  hogeArrays = @result['Maintenances'].sort_by{|val| val['id']}
  logger.info('----------array--------------------')
  hogeArrays.each do |hogeArray|
    logger.info(hogeArray[:id])
  end

  logger.info('----------Salesforce AP0 status end--------------------')

=begin
  @apps.each do |app|
    app_info = @heroku_api.get_app(app['name'])
    logger.info('--------------AP情報--------------')
    logger.info(app['name'])
    logger.info(app_info)
  end
=end

  erb :index_herokus
end

# heroku-api-mante-on
get "/herokus_mante_on/:app_name" do
  @app_name =  params[:app_name]
  @heroku_api = Heroku::API.new(:api_key => 'c7283065-0c22-40ee-a227-939559be0bad')
  @mainte_result = @heroku_api.post_app_maintenance(@app_name, '1') 
  redirect 'herokus'
end

# heroku-api-mante-off
get "/herokus_mante_off/:app_name" do
  @app_name =  params[:app_name]
  @heroku_api = Heroku::API.new(:api_key => 'c7283065-0c22-40ee-a227-939559be0bad')
  @mainte_result = @heroku_api.post_app_maintenance(@app_name, '0') 
  redirect 'herokus'
end


