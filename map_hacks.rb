require 'rubygems'
require 'nokogiri'
require 'border_patrol'
require 'placemark'

module MapHacks
    class InsufficientPointsToActuallyFormAPolygonError < ArgumentError; end
    class InsufficientPlacemarkArguments < ArgumentError; end

    def self.parse_wards(string)
      doc = Nokogiri::XML(string)
      placemarks = doc.xpath('//kml:Placemark','kml' =>'http://www.opengis.net/kml/2.2').map do |placemark|
        region = parse_kml(placemark.to_s)
        pm = Nokogiri::XML(placemark.to_s)
        name = pm.xpath('//name').text
        MapHacks::Placemark.new(name,region)
      end
    end
    
    def self.parse_hoods(string)
      doc = Nokogiri::XML(string)
      placemarks = doc.xpath('//kml:Placemark','kml' =>'http://www.opengis.net/kml/2.2').map do |placemark|
        region = parse_kml(placemark.to_s)
        pm = Nokogiri::XML(placemark.to_s)
        name = pm.xpath('//Data/value').text
        MapHacks::Placemark.new(name,region)
      end
    end
    
    private 
    def self.parse_kml(string)
       doc = Nokogiri::XML(string)
       polygons = doc.xpath('//Polygon').map do |polygon_kml|
         begin 
           parse_kml_polygon_data(polygon_kml.to_s)
         rescue InsufficientPointsToActuallyFormAPolygonError => e
           puts "Problem with Polygon : #{polygon_kml}"
         end
       end
       BorderPatrol::Region.new(polygons)
     end
      
    private
    def self.parse_kml_polygon_data(string)
      doc = Nokogiri::XML(string)
      coordinates = doc.xpath("//coordinates").text.strip.split(" ")

      points = coordinates.map do |coord|
        x, y, z = coord.strip.split(',')
        BorderPatrol::Point.new(x.to_f, y.to_f)
      end
      BorderPatrol::Polygon.new(points)
    end
end