env = ENV['RACK_ENV']
ENV['RACK_ENV'] = nil

require 'engine/redis'
require 'engine/bk'

ENV['RACK_ENV'] = env

##
# This class is the composition of multiple engines
module SinCity
  module Engine
    class QueryEngine < Base
      include SinCity::Engine

      def startup()
        super()
        @engines = []
        @engines << BKTreeEngine.new
        @engines << GeoEngine.new

        @engines.each(&:startup)
      end

      def process(input)
        begin
          bk, geo = @engines.map {|engine| engine.run input}
        rescue => e
          puts e
        end

        return bk if geo.equal?(SKIP)
        
        # let's map everything we found together
        # and weight it
        propositions = bk.map do |k, bkdist|
          next [k, 0] if bkdist == 0 # A perfect match is always first
          geodist = geo[k] || 25  # TODO: this should be the actual radius?

          next [k, bkdist + geodist]
        end
        
        Hash[propositions]
      end

      # Let's get the data once and for all
      def post_process(input)
        byebug
        cities = @redis.pipelined do
          input.each {|k, v| @redis.hgetall "city:#{k}"}
        end

        cities.map(&Geoname.method(:from_h))
      end 
    end
  end
end

if ENV['RACK_ENV'] == 'cli'
  engine = SinCity::Engine::QueryEngine.new
  engine.startup()

  puts "Awaiting request...\n"
  while STDIN.gets.chomp
    q, long, lat = $_.split(' ')
    
    puts "Searching for #{$_}..."  
    puts engine.run(SinCity::Engine::Query.new(q, long.to_i, lat.to_i))
  end
end
