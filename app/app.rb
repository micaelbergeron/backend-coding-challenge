$:.unshift File.dirname('./lib')
$:.unshift File.dirname(__FILE__)

require 'config/environment'
require 'sinatra'

require 'model/geoname'
require 'engine/query'
require 'json'

include SinCity::Engine

engine = QueryEngine.new
engine.startup()

set :bind, '0.0.0.0'
set :public_folder, File.dirname(__FILE__) + '/assets'


get '/suggestions' do
  content_type :json, 'charset' => 'utf-8'
  q = Query.new(params['q'],
                params['longitude']&.to_f,
                params['latitude']&.to_f)

  results = engine.run(q)
  results = [] if results.equal? SKIP
  
  { suggestions: results.map(&:to_h) }.to_json
end

get '/' do
  markdown File.read('README.md'), :layout_engine => :haml
end

__END__

@@ layout
%html
  %head
    %link{rel: 'stylesheet', href: '/css/retro.css'}
  = yield


