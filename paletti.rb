# Paletti module for image color extraction

module Paletti
  require 'chunky_png'

  PNG_REGEX = /(.+\/)?([\w_\s\.\-\(\)]+.png)/

  # Load a PNG by path name into a ChunkyPNG::image
  def Paletti.load_png(filepath)
    filename = filepath[PNG_REGEX, 2]
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

    return image, filename
  end

  # Given a ChunkyPNG::image, count the pixels into a hash
  def Paletti.count_pixels(image)
    all_pixels = Hash.new(0)
    # Go through each pixel and pull it into a map
    image.pixels.each do |pixel|
      hex_color = pixel.to_s(16)[0,8]
      all_pixels[hex_color] += 1
    end
    return all_pixels.to_a.sort_by { |_key, count| count }
  end
end
