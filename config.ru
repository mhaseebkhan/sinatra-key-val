require 'rubygems'
require 'bundler'
require File.join(File.dirname(__FILE__), 'api/sinatra_key_val')

Bundler.require

SinatraKeyVal.run!