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

# Create the output image
# Each virtual "pixel" will be 16x16 so it's easy to see
PIXEL_SIZE = 16
# The number of columns in this preview
NUM_COLS = 4

# Find the number of total rows and account for remainders
num_rows = (pixels.length.to_f / NUM_COLS).ceil

out_img = ChunkyPNG::Image.new(NUM_COLS * PIXEL_SIZE, num_rows * PIXEL_SIZE,
                               ChunkyPNG::Color::TRANSPARENT)
pixels.each_with_index do |pixel, index|
  color = pixel[0]
  unless color.length == 8
    color = ChunkyPNG::Color::TRANSPARENT
  end
  x0 = (index % NUM_COLS) * PIXEL_SIZE
  x1 = (index % NUM_COLS + 1) * PIXEL_SIZE
  y0 = (index / NUM_COLS) * PIXEL_SIZE
  y1 = (index / NUM_COLS + 1) * PIXEL_SIZE
  puts "#{x0} #{y0} #{x1} #{y1} #{pixel[0]}" if VERBOSE
  out_img.rect(x0, y0, x1, y1,
               stroke_color=ChunkyPNG::Color::BLACK, fill_color=color)
end
  
file_out_name = "output/p_#{filename}"
out_img.save(file_out_name)
puts "Wrote to #{file_out_name}"
