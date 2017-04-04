require 'sinatra'
require 'json'

require './keys_server.rb'

class EndPoints < Sinatra::Base
  keys_server = KeysServer.new
  
  Thread.new do
	keys_server.monitor_keys
  end
  
  before do
  	content_type :json
  end

  def jsonize(result)
    JSON.generate({:result => result})
  end

  get '/' do
    'Hello'
  end

  get '/blocked' do
    jsonize(keys_server.assigned_keys)
  end

  get '/available' do
    jsonize(keys_server.available_keys)
  end

  get '/generate' do
    jsonize(keys_server.generate_keys)
  end

  get '/get' do
    jsonize(keys_server.get_key)
  end

  get '/free/:id' do
    jsonize(keys_server.unblock_key(params[:id]))
  end

  get '/delete/:id' do
    jsonize(keys_server.delete_key(params[:id]))
  end

  get '/keep-alive/:id' do
    jsonize(keys_server.live(params[:id]))
  end
end
