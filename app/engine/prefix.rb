require 'engine'

module SinCity
  module Engine
    class PrefixEngine < Base
      include SinCity::Engine

      def pre_process(query)
        query.q.downcase
      end

      def process(input)
        matches = @redis.keys "city:names:#{input}*"
        return SKIP if matches.length == 0

        byebug
        key_val = lambda {|k| k.split(':').last }
        geokeys = @redis.pipelined do
          matches.each {|key| @redis.smembers key}
        end

        keys_distance = geokeys.map.with_index do |key_or_array, i|
          geoname = key_val.call(matches[i])

          # Let's handle multiple same names
          case key_or_array
          when Array
            key_or_array.map {|k| [key_val[k], (geoname.length - input.length).to_s]}
          else
            geoid = key_val[key_or_array]
            [geoid, (geoname.length - input.length).to_s]
          end
        end
        
        Hash[keys_distance.flatten(1)]
      end

      def post_process(output)
        sorted = output.sort_by {|k,v| [v, k]} 
                   .map.with_index {|k,i| [k[0], i]} # the index is what is relevant
        Hash[sorted]
      end
    end
  end
end

if ENV['RACK_ENV'] == 'cli'
  engine = SinCity::Engine::PrefixEngine.new
  engine.startup()

  puts "Awaiting request...\n"
  while STDIN.gets
    query = $_.chomp
    puts "Searching for #{query}..."  
    puts engine.run(SinCity::Engine::Query.new(query))
    puts
  end 
end
