require 'chunky_png'

DEBUG = true
VERBOSE = false

# Make sure a file is passed in
if ARGV.empty?
  raise ArgumentError, 'Missing image to process.'
end

# Do some regex stripping for filenames
filepath = ARGV[0]
PNG_DETECTOR = /(.+\/)?([\w_\s\.\-\(\)]+.png)/
filename = filepath[PNG_DETECTOR, 2]

if filename == nil
  abort('File parameter is empty')
end

unless File.exist?(filepath)
  abort('File parameter is not a file')
end

# Practice safe File I/O
begin
  image = ChunkyPNG::Image.from_file(filepath)
rescue ChunkyPNG::SignatureMismatch
  abort('File parameter not a PNG file')
end

all_pixels = Hash.new(0)

# Go through each pixel and pull it into a map
image.pixels.each do |pixel|
  hex_color = pixel.to_s(16)[0,8]
  all_pixels[hex_color] += 1
end

pixels = all_pixels.to_a.sort_by { |_key, count| count }

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
num_rows = (all_pixels.length.to_f / NUM_COLS).ceil

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
  
file_out_name = "output_#{filename}"
out_img.save(file_out_name)
puts "Wrote to #{file_out_name}"
