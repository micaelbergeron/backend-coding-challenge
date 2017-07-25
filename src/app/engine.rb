module SinCity
  module Engine

    # This is used to stop the pipeline gracefully
    SKIP = -1
    
    # Query parsing
    def pre_process(query)
      query
    end
    
    # Main process
    def process(input)
      input
    end

    # Output sorting and normalization
    def post_process(output)
      output
    end

    def run(input)
      # call each method in a pipeline
      %i(pre_process process post_process).inject(input) do |output, method|
        return SKIP if output.equal?(SKIP)
        begin
          self.send(method, output)
        rescue => e
          puts "#{self.class} failed at #{method} with #{output}: #{e}"
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
    Proposition = Struct.new(:score, :confidence, :components) do
      def initialize(*)
        super
        self.score ||= 0
        self.confidence ||= 0
        self.components ||= []
      end
    end

  end
end
