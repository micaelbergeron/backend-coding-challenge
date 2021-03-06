require 'engine'
require 'lib/levenshtein_damerau'

class LevenshteinDamerauDistancer
  def call(a, b)
    Text::LevenshteinDamerau.distance(a, b)
  end
end

module SinCity::Engine
  class BKTreeEngine < Base
    include SinCity::Engine

    @@defaults = {
      distance: 2,
      result_count: 100,
      index_file: INDEX_FILE,
      input_file: INPUT_FILE,
      distancer: LevenshteinDamerauDistancer
    }

    def initialize(**args)
      super(@@defaults.merge(args))
    end

    def startup()
      super()
      @tree = BK::Tree.new(@config[:distancer].new)

      File.unlink @config[:index_file] if DB_FLUSH and File.exists? @config[:index_file]

      begin
        File.open(@config[:index_file], "rb") do |f|
          puts "Found #{@config[:index_file]} index file, importing..."
          @tree = BK::Tree.import(f)
        end
      rescue
        puts "Reloading data from #{INPUT_FILE}..."
        TSV[@config[:input_file]].each do |row|
          geo = Geoname.from_a row.to_a
          @tree.add geo.asciiname.downcase, {geonameid: geo.geonameid}
        end
        puts "Saving the index to disk: #{@config[:index_file]}"
        File.open(@config[:index_file], "wb") { |f| @tree.export(f) }
      end
    end

    def pre_process(query)
      return SKIP if query.q.nil?
      query.q = query.q.chomp.downcase
      return SKIP if query.q !~ /^\w+/

      @input = query.q
      query
    end

    def process(query)
      @tree.query(query.q, @config[:distance])
    end

    # sort by levenshtein distance
    #         first letter index distance
    #         input length delta
    def post_process(output)      
      sorted = output.sort_by {|k,v| [v[:dist],
                                      k.index(@input[0]) || k.length,
                                      (@input.length - k.length).abs,
                                      k]}
                 .take(@config[:result_count])
                 .map {|k,v| [v[:data][:geonameid], v[:dist]]}
      Hash[sorted]
    end
    
  end
end

if ENV['RACK_ENV'] == 'cli'
  engine = SinCity::Engine::BKTreeEngine.new
  engine.startup()

  puts "Awaiting request...\n"
  while STDIN.gets
    query = $_.chomp
    puts "Searching for #{query}..."  
    puts engine.run(SinCity::Engine::Query.new(query))
    puts
  end 
end
