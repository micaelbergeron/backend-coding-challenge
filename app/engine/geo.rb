require 'engine'
require 'model/geoname'

include SinCity::Model

module SinCity::Engine
  class GeoEngine < Base
    include SinCity::Engine

    @@defaults = {
      radius: 10000,
      distance_unit: 'km',
      result_count: 100,
      input_file: INPUT_FILE,
    }

    def initialize(**args)
      super(@@defaults.merge(args))
    end

    def startup
      super()
      #NOTE: This is slow
      @redis.flushall if DB_FLUSH

      import_count = 0
      if DB_LOAD
        TSV[INPUT_FILE].each do |row|
          geo = Geoname.from_a row.to_a

          #TODO: keybuilder
          geokey = build_key(geo)
          @redis.mapped_hmset geokey, geo.to_h
          @redis.sadd "city:names:#{geo.asciiname.downcase}", geokey
          @redis.geoadd "city:geopos", geo.longitude, geo.latitude, geokey
          import_count += 1
        end
      end

      puts "Imported #{import_count} rows."
    end

    def pre_process(input)
      return SKIP unless input.latitude && input.longitude
      input
    end
    
    def process(input)
      byebug
      keys = @redis.georadius("city:geopos",
                       input[:longitude],
                       input[:latitude],
                       @config[:radius],
                       @config[:distance_unit],
                       "WITHDIST",
                       "COUNT", @config[:result_count])
      keys
    end 

    def post_process(input)
      Hash[ input.map {|k,v| [k.split(':')[1], v.to_f]} ]
    end

    private

    def build_key(geoname)
      "city:#{geoname.geonameid}"
    end
  end
end

if ENV['RACK_ENV'] == 'cli'
  engine = SinCity::Engine::GeoEngine.new
  engine.startup()

  puts "Awaiting request...\n"
  while STDIN.gets.chomp
    long, lat = $_.split(' ')
    
    puts "Searching for #{$_}..."  
    puts engine.run(SinCity::Engine::Query.new(nil, long.to_i, lat.to_i))
  end
end
