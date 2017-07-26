require "rubygems"
require "bundler/setup"

# Config
REDIS_HOST = ENV['REDIS_HOST'] || 'localhost'
REDIS_PORT = ENV['REDIS_PORT'] || 6379
INPUT_FILE = ENV['INPUT_FILE'] || '../data/cities_canada-usa.tsv'
INDEX_FILE = ENV['INDEX_FILE'] || 'cities.idx'
ENGINE     = ENV['ENGINE']     || 'redis'
DB_LOAD    = ENV['DB_LOAD'] == "1"
DB_FLUSH   = ENV['DB_FLUSH'] == "1"
DEBUG      = ENV['DEBUG'] == "1"

puts "Loading environment..."
Bundler.require(:default)                   # load all the default gems
Bundler.require(Sinatra::Base.environment)  # load all the environment specific gems

if DEBUG
  puts "Debugger is enabled."
  Bundler.require(:debug)
else
  def byebug
    puts "Debugging is disabled, run with DEBUG=1 to enable it."
  end
end
