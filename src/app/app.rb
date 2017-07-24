$:.unshift File.dirname('./lib')
$:.unshift File.dirname(__FILE__)

require 'config/environment'

require 'model/geoname'
require "engine/#{ENGINE}"
