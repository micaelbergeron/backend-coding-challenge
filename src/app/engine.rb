module SinCity
  module Engine

    # This is use to stop the pipeline gracefully
    SKIP = -1
    
    # Input normalization
    def pre_process(input)
      input
    end
    
    # Main process
    def process(input)
      input
    end

    # Output
    def post_process(input)
      input
    end

    def run(input)
      # call each method in a pipeline
      %i(pre_process process post_process).inject(input) do |output, method|
        return SKIP if output.equal?(SKIP)
        begin
          self.send(method, output)
        rescue => e
          puts "#{self.class} failed at #{method} with #{output}: #{e}"
          byebug
          return SKIP
        end
      end
    end
    
    class Base
      @@loglevel = 0

      def initialize(**args)
        @config = {
          redis: {
            host: REDIS_HOST,
            port: REDIS_PORT,
          }
        }
        @config.merge! args
      end
      
      # Load the engine
      def startup()
        @redis = Redis.new(@config[:redis])
      end

    end  

    Query = Struct.new(:q, :longitude, :latitude)
  end

end
