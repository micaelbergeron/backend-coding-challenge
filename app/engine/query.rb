# TODO: remove this workaround for CLI
env = ENV['RACK_ENV']
ENV['RACK_ENV'] = nil

require 'engine/geo'
require 'engine/bktree'
require 'engine/prefix'

ENV['RACK_ENV'] = env

##
# This class is the composition of multiple engines
module SinCity
  module Engine
    class QueryEngine < Base
      include SinCity::Engine

      DISTANCE = 500

      def startup()
        super()
        @engines = []
        @engines << PrefixEngine.new
        @engines << BKTreeEngine.new
        @engines << GeoEngine.new(distance: DISTANCE, result_count: 100)

        @engines.each(&:startup)
      end

      def process(input)
        begin
          prefix, bk, geo = @engines.map {|engine| engine.run input}
        rescue => e
          puts e
        end
        byebug

        propositions = {}

        # merge all trees
        prefix.each do |id,dist|
          score = dist
          propositions[id] ||= Proposition.new
          propositions[id].score += score
          propositions[id].components << {prefix: score}
          propositions[id].confidence += 0.4
        end unless prefix.equal? SKIP

        bk.each do |id,dist|
          score = dist
          propositions[id] ||= Proposition.new
          propositions[id].score += score
          propositions[id].components << {bktree: score}
          propositions[id].confidence += 0.3
        end unless bk.equal? SKIP

        # let's mark everything as VERY far, and locate what we know
        propositions.each do |id, prop|
          dist = DISTANCE * 2 
          score = lambda {|d| Math.log10(d).floor}
          if geo.has_key?(id)
            dist = geo[id]
            prop.components << {geo: score[dist]}
            prop.confidence += 0.3
          else
            prop.components << {geo_penalty: score[dist]}
          end 
          prop.score += score[dist]
        end unless geo.equal?(SKIP)

        normalize = lambda {|_, prop| prop.score = (1.0 - prop.score / max_score)}

        # confidence pass and normalization
        propositions.each {|id, prop| prop.score /= prop.confidence }
        max_score = propositions.max_by {|id, prop| prop.score}[1].score
        propositions.each(&normalize) unless max_score.zero?
          
        Hash[propositions]
      end

      # Let's get the data once and for all
      def post_process(input)
        sorted = Hash[input.sort_by {|k,v| [-v.score, k]}] # sort by weight
        cities = @redis.pipelined do
          sorted.each {|k, v| @redis.hgetall "city:#{k}"}
        end

        cities.map do |h|
          geo = Geoname.from_h h
          meta = sorted[geo.geonameid]
          
          suggestion = {
            name: geo.name,
            display_name: geo.display_name,
            asciiname: geo.asciiname,
            alternate_names: geo.alternatenames,
            latitude: geo.latitude,
            longitude: geo.longitude,
            score: meta[:score],
            score_components: meta[:components],
            score_confidence: meta[:confidence]
          }
        end
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
