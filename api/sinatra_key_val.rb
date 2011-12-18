require 'sinatra/base'
require 'sinatra/reloader'
require 'rest_client'
require 'json'

DB = 'http://haseeb.iriscouch.com/sinatra-key-val'

class SinatraKeyVal < Sinatra::Base

  configure :development do
    register Sinatra::Reloader
  end

  enable :sessions

  get '/token' do

    token_response = RestClient.post("#{DB}", {}.to_json, :content_type => :json) rescue nil

    if token_response.nil?
      {:error_code => "101", :error_message => "Unable to initialize the session."}.to_json
    else
      token_json = JSON.parse(token_response)
      session['token'] = token_json['id']

      token_response
    end


  end

  get '/complete-session-data' do

    token_json_response = JSON.parse(RestClient.get("#{DB}/#{session['token']}")) rescue nil

    if token_json_response.nil?
      {:error_code => "201", :error_message => "Session expired."}.to_json
    else
      complete_data = Array.new

      if !token_json_response['values'].nil?
        token_json_response['values'].each do |value|
          complete_data << RestClient.get("#{DB}/#{value}").chomp
        end
      end

      complete_data.to_json
    end

  end

  post '/save-values' do

    values_response = RestClient.post("#{DB}", params.to_json, :content_type => :json)
    values_json = JSON.parse(values_response)

    token_json_response = JSON.parse(RestClient.get("#{DB}/#{session['token']}")) rescue nil

    if token_json_response.nil?
      {:error_code => "301", :error_message => "Values saved. Unable to associate with session. Session might have expired."}.to_json
    else
      token_json_response['values'] ||= []
      token_json_response['values'] << values_json['id']
      RestClient.put("#{DB}/#{session['token']}", token_json_response.to_json, :content_type => 'application/json')

      values_response
    end

  end

  post '/specific-data' do

    json_response = RestClient.get("#{DB}/#{params[:id]}") rescue nil

    if json_response.nil?
      json_response = {:error_code => "401", :error_message => "No document with the provided id exists."}.to_json
    end

    json_response

  end

end