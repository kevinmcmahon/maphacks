module MapHacks
  class Placemark
      attr_accessor :name
      attr_accessor :region
      
      def initialize(*args)
        args.flatten!
        args.uniq!
        raise InsufficientPlacemarkArguments unless args.size == 2
        @name, @region = args
      end
  end
end