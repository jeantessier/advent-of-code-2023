#!/usr/bin/env ruby

# lines = File.readlines("sample.txt") # Answer: 46
lines = File.readlines("input.txt") # Answer:

# Parse the seeds
seed_ranges = lines
                .map {|line| /seeds:\s*(?<seed_ranges>.*)/.match(line)}
                .filter {|m| m}
                .map do |m|
                  results = []
                  offset = 0
                  while (match = /(?<range_start>\d+)\s+(?<range_length>\d+)/.match(m[:seed_ranges], offset))
                    range_start = match[:range_start].to_i
                    range_length = match[:range_length].to_i
                    results << (range_start...(range_start + range_length))
                    offset = match.end(0)
                  end
                  results
                end.flatten

puts "Seed Ranges"
puts "-----------"
puts seed_ranges

# Parse all the maps

puts ""

maps = []

current_map = {}
current_map.default_proc = lambda { |hash, key| hash[key] = key }

lines.each do |line|
  case line
  when /(\w+)\-to\-(\w+) map/
    source = $1
    destination = $2
    puts "Start new maps from #{source} to #{destination}"
    current_map = {}
    current_map.default_proc = lambda { |hash, key| hash[key] = key }
    maps << {
      source: source,
      destination: destination,
      map: current_map,
    }
  when /^\s*(\d+)\s*(\d+)\s*(\d+)/
    destination_range_start = $1.to_i
    source_range_start = $2.to_i
    range_length = $3.to_i
    # puts "destination_range_start: #{destination_range_start}"
    # puts "source_range_start: #{source_range_start}"
    # puts "range_length: #{range_length}"
    # (0...(range_length.to_i)).each do |i|
    #   # puts "#{source_range_start.to_i + i} --> #{destination_range_start.to_i + i}"
    #   current_map[source_range_start.to_i + i] = destination_range_start.to_i + i
    # end
    source_range = source_range_start...(source_range_start + range_length)
    destination_range = destination_range_start...(destination_range_start + range_length)
    puts "#{source_range} --> #{destination_range}"
    current_map[source_range] = lambda {|n| destination_range_start + n - source_range_start}
  end
end

puts ""
puts "Maps"
puts "----"
puts maps

puts ""
puts "Resolving Seeds"
puts "---------------"

def resolve(maps, source, value)
  map = maps.find {|m| m[:source] == source}
  return value unless map

  mapper = map[:map].find {|range, mapper| range.include?(value)}

  resolve(maps, map[:destination], mapper ? mapper[1].call(value) : value)
end

locations = seed_ranges.map do |seed_range|
  puts "Seeds #{seed_range}"
  seed_range.reduce(1_000_000_000) do |memo, seed|
    location = resolve(maps, "seed", seed)
    location < memo ? location : memo
  end
end

puts ""
puts "Locations"
puts "---------"
puts locations

puts ""
puts "Answer"
puts "------"
puts locations.min
