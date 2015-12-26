require 'chunky_png'
require './paletti.rb'

DEBUG = true
VERBOSE = false

# Make sure a file is passed in
if ARGV.empty?
  raise ArgumentError, 'Missing image to process.'
end

image, filename = Paletti.load_png(ARGV[0])

pixels = Paletti.count_pixels(image)

if DEBUG
  puts "Found #{image.pixels.length} items"
  print "#{pixels}\n"
end

out_img = Paletti.create_image(pixels)
  
file_out_name = "output/p_#{filename}"
out_img.save(file_out_name)
puts "Wrote to #{file_out_name}"
