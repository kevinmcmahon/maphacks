require 'rubygems'
require 'nokogiri'

def foo(placemark)
   pm = Nokogiri::XML(placemark.to_s)
    desc = pm.xpath('//description')
    html = Nokogiri::HTML(desc.text)
    rows = html.xpath('//td')
    return rows[1].text.strip, rows[3].text.strip
end

kml = File.read('./ChicagoNeighborhoods.kml')
doc = Nokogiri::XML(kml)

kvp = doc.xpath('//kml:Placemark','kml' =>'http://earth.google.com/kml/2.2').map do |placemark|
        foo(placemark)
      end
puts 'name,desc'
kvp.map do |x|
  puts "#{x[0]},#{x[1]}"
end

