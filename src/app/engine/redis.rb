redis = Redis.current
redis = Redis.new(host: REDIS_HOST, port: REDIS_PORT)

#NOTE: This is slow
redis.flushall if DB_FLUSH

if DB_LOAD
  TSV[INPUT_FILE].each do |row|
    geo = Geoname.from_a row.to_a
    loop unless %w(CA).include? geo.country_code

    #TODO: keybuilder
    redis.mapped_hmset "city:#{geo.geonameid}", geo.to_h
    redis.sadd "city:names", geo.name

    # GEO?
    redis.geoadd "city:geopos", geo.longitude, geo.latitude, geo.name
  end
end

puts redis.smembers "city:names"

puts "Awaiting request...\n"
asm = Redis::Asm.new(redis)
while STDIN.gets
  puts "Searching for #{$_}..."  
  puts asm.search("city:names", $_, MAX_RESULTS=25)
end
