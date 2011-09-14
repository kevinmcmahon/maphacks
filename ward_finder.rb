require 'rubygems'
require 'open-uri'
require 'border_patrol'
require 'map_hacks'
require 'json'
require 'net/http'

def address_geocode(query)
  base_url = "http://maps.googleapis.com/maps/api/geocode/json"
  url = "#{base_url}?address=#{URI.encode(query)}&sensor=false"
  resp = Net::HTTP.get_response(URI.parse(url))
  data = resp.body
  
  # we convert the returned JSON data to native Ruby
  # data structure - a hash
  result = JSON.parse(data)
  
  # if the hash has 'Error' as a key, we raise an error
  if result.has_key? 'Error'
    raise "web service error"
  end
  return result['results'][0]['geometry']['location']
end

#query = '644 W Arlington Place, Chicago, Il 60614'
#query = '910 N Hermitage, Chicago, Il'
#query = '14200 Trenton Ave, Orland Park, IL 60642'
#query = '1826 West Wilson Avenue, Chicago, IL 60640'
#query = '4015 N Sheridan Rd,Chicago, IL'
query = '10714 South Sawyer Avenue,Chicago, IL 60655'
location = address_geocode(query) 

puts 'processing boundary'
boundary_file = File.read('./ChicagoBoundary.kml')
#boundary_file = open('http://cache.methodsix.com/kml/cityboundary.kml')
chicago = BorderPatrol.parse_kml(boundary_file)

puts 'processing wards'

placemarks_file = File.read('./chicagowards.kml')
placemarks = MapHacks.parse_wards(placemarks_file)

hoods_file = File.read('./ChicagoHoods.kml')
hoods = MapHacks.parse_hoods(hoods_file)

point = BorderPatrol::Point.new(location['lng'],location['lat'])

if chicago.contains_point?(point)
  puts "Location is in Chicago."
  
  placemarks.each do |ward|
    if ward.region.contains_point?(point)
      puts "The address is in Ward #{ward.name}"
      break
    end 
  end
  
  hoods.each do |hood|
    if hood.region.contains_point?(point)
      puts "The neighborhood is #{hood.name}"
      break
    end
  end
  
else
  puts "Location is not in Chicago"
end