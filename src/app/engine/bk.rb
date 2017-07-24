require 'lib/levenshtein_damerau'

class LevenshteinDamerauDistancer
  def call(a, b)
    dist = Text::LevenshteinDamerau.distance(a, b)
    # puts "#{a} --[#{dist}]-- #{b}"
    dist
  end
end

class WhiteDistancer
  def call(a,b)
  end
end

tree = BK::Tree.new(LevenshteinDamerauDistancer.new)
#tree = BK::Tree.new(WhiteDistancer.new)

File.unlink INDEX_FILE if DB_FLUSH and File.exists? INDEX_FILE

begin
  File.open(INDEX_FILE, "rb") do |f|
    puts "Found #{INDEX_FILE} index file, importing..."
    tree = BK::Tree.import(f)
  end
rescue
  puts "Reloading data from #{INPUT_FILE}..."
  TSV[INPUT_FILE].each do |row|
    geo = Geoname.from_a row.to_a
    loop unless %w(US CA).include? geo.country_code

    tree.add geo.name.downcase
  end
  puts "Saving the index to disk: #{INDEX_FILE}"
  File.open(INDEX_FILE, "wb") { |f| tree.export(f) }
end

puts "Awaiting request...\n"
while STDIN.gets
  query = $_.chomp.downcase
  puts "Searching for #{query}..."  
  puts
  puts tree.query(query, 2)
         .sort_by {|k,v| [v, (query.length - k.length).abs, k]}
         .take(10)
end 
