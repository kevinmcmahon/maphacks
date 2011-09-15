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

def processQuery(query,chicago,wards,hoods)
  
  location = address_geocode(query) 

  point = BorderPatrol::Point.new(location['lng'],location['lat'])

  if chicago.contains_point?(point)
    puts query + " is in Chicago."

    wards.each do |ward|
      if ward.region.contains_point?(point)
        puts "    Ward #{ward.name}"
        break
      end 
    end
  
    hoods.each do |hood|
      if hood.region.contains_point?(point)
        puts "    Neighborhood is #{hood.name}"
        break
      end
    end
  
  else
    puts query + " is not in Chicago"
  end
  puts ''
end

query = ['3278 E 133RD St, Chicago, IL 60633',
  '644 W Arlington Place, Chicago, Il 60614',
  '910 N Hermitage, Chicago, Il',
  '14200 Trenton Ave, Orland Park, IL 60642',
  '1826 West Wilson Avenue, Chicago, IL 60640',
  '4015 N Sheridan Rd,Chicago, IL',
  '10714 South Sawyer Avenue,Chicago, IL 60655',
  '1400 South Michigan, Chicago, IL 60605']

puts 'processing chicago boundary'
boundary_file = File.read('./ChicagoBoundary.kml')
chicago = BorderPatrol.parse_kml(boundary_file)

puts 'processing wards'
wards_file = File.read('./chicagowards.kml')
wards = MapHacks.parse_wards(wards_file)

puts 'processing neighborhoods'
hoods_file = File.read('./ChicagoHoods.kml')
hoods = MapHacks.parse_hoods(hoods_file)
puts ''

query.each do |q|
  processQuery(q,chicago,wards,hoods)
end
