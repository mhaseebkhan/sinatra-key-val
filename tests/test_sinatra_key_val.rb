require File.join(File.dirname(__FILE__), '../api/sinatra_key_val.rb')
require "test/unit"
require 'rack/test'

ENV['RACK_ENV'] = 'test'

class SinatraKeyValTests < Test::Unit::TestCase

  include Rack::Test::Methods

  def setup
    get '/token'
  end

  def app
    SinatraKeyVal
  end

  # Checking for token response
  def test_success_scenario
    assert last_response.ok?
  end

  # Checking for valid token
  def test_checking_nil_id
    token_json = JSON.parse(last_response.body)
    assert_not_equal 'nil', token_json['id']
  end

  # Checking for whitespace in token
  def test_checking_id_as_space
    token_json = JSON.parse(last_response.body)
    assert_not_equal " ", token_json['id']
  end

  # Checking for saving values response
  def test_checking_saving_values
    post '/save-values', :value1 => '1', :value2 => '2'
    token_json = JSON.parse(last_response.body)
    assert_not_equal " ", token_json['id']
  end

  # Checking for valid id after saving values
  def test_checking_complete_session_data

    post '/save-values', :value1 => '1', :value2 => '2', :value3 => '3'
    token_json = JSON.parse(last_response.body)
    prev_id = token_json['id']

    get '/complete-session-data'
    token_json2 = JSON.parse(last_response.body)
    next_id = JSON.parse(token_json2[0])['_id']

    assert_equal prev_id, next_id
  end

  # Checking for specific data response
  def test_checking_specific_data

    post '/save-values', :value1 => '1', :value2 => '2', :value3 => '3', :value4 => '4'
    token_json = JSON.parse(last_response.body)
    prev_id = token_json['id']

    post '/specific-data', :id => prev_id
    token_json2 = JSON.parse(last_response.body)
    next_value = token_json2['value1']

    assert_equal '1', next_value
  end

end