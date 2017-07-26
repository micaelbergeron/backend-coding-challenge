ruby "2.4.1"
source "https://rubygems.org"

gem "sinatra", :require => "sinatra/base"
gem "thin"
gem "kramdown"
gem "redis"
gem "redis-asm"
gem "tsv"
gem "bk", :path => "lib/bktree"

group :test do
  gem "rack-test"
  gem "bacon"
  gem "rspec"
end

group :development do
  gem "rubocop"
  gem "byebug"
  gem "pry-byebug"
end
