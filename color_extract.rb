require 'chunky_png'

DEBUG = false

# Make sure a file is passed in
if ARGV.length == 0
  raise ArgumentError, 'Missing image to process.'
end

filename = ARGV[0]

image = nil

# Practice safe File I/O
begin
  image = ChunkyPNG::Image.from_file(filename)
rescue ChunkyPNG::SignatureMismatch
  abort('File parameter not a PNG file')
end

all_pixels = {}
pixel_count = 0

# Go through each pixel and pull it into a map
image.pixels.each do |pixel|
  pixel_count = pixel_count.next
  hex_color = pixel.to_s(16)[0,8]
  all_pixels[hex_color] = all_pixels[hex_color].to_i.next
end

pixels = all_pixels.to_a.sort_by { |_key, count| count }

puts "Found #{pixel_count} items"
if DEBUG
  print "#{pixels}\n"
end

# Create the output image
# Each virtual "pixel" will be 16x16 so it's easy to see
PIXEL_SIZE = 16
# The number of columns in this preview
NUM_COLS = 4

# Find the number of total rows
num_rows = all_pixels.keys.length / NUM_COLS
# And determine the remainder of "pixels" (if any) to see if we add an extra row
last_row_count = (all_pixels.keys.length - (NUM_COLS * num_rows))
num_rows = (last_row_count == 0) ? num_rows : num_rows + 1

out_img = ChunkyPNG::Image.new(NUM_COLS * PIXEL_SIZE, num_rows * PIXEL_SIZE,
                               ChunkyPNG::Color::TRANSPARENT)
pixels.each_with_index do |pixel, index|
  color = pixel[0]
  if color.length != 8
    color = ChunkyPNG::Color::TRANSPARENT
  end
  x0 = (index % NUM_COLS) * PIXEL_SIZE
  x1 = (index % NUM_COLS + 1) * PIXEL_SIZE
  y0 = (index / NUM_COLS) * PIXEL_SIZE
  y1 = (index / NUM_COLS + 1) * PIXEL_SIZE
  if DEBUG
    puts "#{x0} #{y0} #{x1} #{y1} #{pixel[0]}"
  end
  out_img.rect(x0, y0, x1, y1,
               stroke_color=ChunkyPNG::Color::BLACK, fill_color=color)
end
  
file_out_name = "output_#{filename}"
out_img.save(file_out_name)
puts "Wrote to #{file_out_name}"
