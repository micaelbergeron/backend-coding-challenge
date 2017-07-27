require 'engine'

module SinCity
  module Engine
    class PrefixEngine < Base
      include SinCity::Engine

      # TODO: refactor this into an helper
      def pre_process(query)
        return SKIP if query.q.nil?
        query.q = query.q.chomp.downcase
        return SKIP if query.q !~ /^\w+/

        query
      end

      def process(query)
        input = query.q
        matches = @redis.keys "city:names:#{input}*"
        return SKIP if matches.length == 0

        key_val = lambda {|k| k.split(':').last }
        geokeys = @redis.pipelined do
          matches.each {|key| @redis.smembers key}
        end

        geokeys = Hash[matches.zip(geokeys)]
        keys_distance = geokeys.map do |match, keys|
          distance = key_val[match].length - input.length
          keys.map {|key| [key_val[key], distance]}
        end
        
        Hash[keys_distance.flatten(1)]
      end

      def post_process(output)
        sorted_groups = output.sort_by {|k,dist| [dist, k]} 
                          .group_by {|k,dist| dist}

        min_prefix = sorted_groups.each_key.min
        
        # basically, we prefixes to have a score sorted from 1..N, (N = #output)
        # but the same key should yield the same score
        byebug
        normalized = {}
        sorted_groups.each.with_index do |grp, i|
          _, elems = grp
          elems.each {|k, _| normalized[k] = i + min_prefix}
        end

        normalized
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
