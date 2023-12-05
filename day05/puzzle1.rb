#!/usr/bin/env ruby

# lines = File.readlines("sample.txt") # Answer: 35
lines = File.readlines("input.txt") # Answer: 282277027

# Parse the seeds
seeds = lines
          .map {|line| /seeds:\s*(?<seeds>.*)/.match(line)}
          .filter {|m| m}
          .map {|m| m[:seeds].split.map {|seed| seed.to_i}}
          .flatten

puts "Seeds"
puts "-----"
puts seeds.to_s

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

def resolve(maps, source, value)
  map = maps.find {|m| m[:source] == source}
  return {source => value} unless map

  mapper = map[:map].find {|range, mapper| range.include?(value)}

  resolve(maps, map[:destination], mapper ? mapper[1].call(value) : value).merge(source => value)
end

resolved_seeds = seeds.map do |seed|
  resolve(maps, "seed", seed)
end

puts ""
puts "Resolved Seeds"
puts "--------------"
puts resolved_seeds

puts ""
puts "Locations"
puts "---------"
puts resolved_seeds.map {|o| o["location"]}

puts ""
puts "Answer"
puts "------"
puts resolved_seeds.map {|o| o["location"]}.min
