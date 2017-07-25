## 
# This class represent the schema for geonames entries

# The main 'geoname' table has the following fields :
# ---------------------------------------------------
# geonameid         : integer id of record in geonames database
# name              : name of geographical point (utf8) varchar(200)
# asciiname         : name of geographical point in plain ascii characters, varchar(200)
# alternatenames    : alternatenames, comma separated, ascii names automatically transliterated, convenience attribute from alternatename table, varchar(10000)
# latitude          : latitude in decimal degrees (wgs84)
# longitude         : longitude in decimal degrees (wgs84)
# feature class     : see http://www.geonames.org/export/codes.html, char(1)
# feature code      : see http://www.geonames.org/export/codes.html, varchar(10)
# country code      : ISO-3166 2-letter country code, 2 characters
# cc2               : alternate country codes, comma separated, ISO-3166 2-letter country code, 200 characters
# admin1 code       : fipscode (subject to change to iso code), see exceptions below, see file admin1Codes.txt for display names of this code; varchar(20)
# admin2 code       : code for the second administrative division, a county in the US, see file admin2Codes.txt; varchar(80) 
# admin3 code       : code for third level administrative division, varchar(20)
# admin4 code       : code for fourth level administrative division, varchar(20)
# population        : bigint (8 byte int) 
# elevation         : in meters, integer
# dem               : digital elevation model, srtm3 or gtopo30, average elevation of 3''x3'' (ca 90mx90m) or 30''x30'' (ca 900mx900m) area in meters, integer. srtm processed by cgiar/ciat.
# timezone          : the iana timezone id (see file timeZone.txt) varchar(40)
# modification date : date of last modification in yyyy-MM-dd format

MAPPINGS = %i{
  geonameid         
  name              
  asciiname         
  alternatenames    
  latitude          
  longitude         
  feature_class
  feature_code
  country_code      
  cc2               
  admin1_code
  admin2_code       
  admin3_code       
  admin4_code       
  population        
  elevation         
  dem               
  timezone          
  modification_date
}

module SinCity
  module Model

    klass = Object.const_set "Geoname", Struct.new(*MAPPINGS)
    klass.class_eval do

      # This can be computed when querying
      attr_accessor :distance
      def distance=(value)
        @distance = value.to_f
      end

      attr_reader :display_name
      def display_name()
        "#{name}, #{admin1_code}, #{country_code}" 
      end
      
      def self.from_a(values)
        raise "Values are not the correct length!" if MAPPINGS.length != values.length
        
        instance = Geoname.new
        MAPPINGS.each.with_index do |map, i|
          instance.send("#{map}=", values[i])
        end
        instance
      end

      def self.from_h(values)
        instance = Geoname.new
        values.each do |k,v|
          instance.send("#{k}=", v)
        end
        instance
      end
    end

  end
end
