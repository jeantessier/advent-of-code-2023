#!/usr/bin/env ruby

# lines = File.readlines("sample.txt") # Answer: 46
# lines = File.readlines("modified_sample.txt") # Answer: 20
lines = File.readlines("input.txt") # Answer: 11554135

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

# puts ""

maps = []

current_map = {}
current_map.default_proc = lambda { |hash, key| hash[key] = key }

lines.each do |line|
  case line
  when /(\w+)\-to\-(\w+) map/
    source = $1
    destination = $2
    # puts "Start new maps from #{source} to #{destination}"
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
    source_range = source_range_start...(source_range_start + range_length)
    destination_range = destination_range_start...(destination_range_start + range_length)
    # puts "#{source_range} --> #{destination_range}"
    current_map[source_range] = lambda {|n| destination_range_start + n - source_range_start}
  end
end

puts ""
puts "Maps"
puts "----"
puts maps

puts ""
puts "Resolving Seed Ranges"
puts "---------------------"

def resolve(maps, source, source_ranges)
  puts ""
  puts "Resolving #{source}"
  map = maps.find {|m| m[:source] == source}
  return source_ranges unless map

  mappings = source_ranges.map do |source_range|

    # Mappings from mapped conversions
    mapped_ranges = map[:map].map do |range, mapper|
      ranges_are_overlapping = (
        range.cover?(source_range.min) or
        range.cover?(source_range.max) or
        source_range.cover?(range.min) or
        source_range.cover?(range.max)
      )

      if ranges_are_overlapping
        source_range_start = [source_range.min, range.min].max
        source_range_end = [source_range.max, range.max].min

        destination_range_start = mapper.call(source_range_start)
        destination_range_end = mapper.call(source_range_end)

        puts "  #{source} #{source_range_start..source_range_end} --> #{map[:destination]} #{destination_range_start..destination_range_end}"
        {
          source => source_range_start..source_range_end,
          map[:destination] => destination_range_start..destination_range_end,
        }
      else
        nil
      end
    end.filter do |range|
      range
    end.sort do |a, b|
      a[source].min <=> b[source].min
    end

    puts "#{source} #{source_range} has mappings #{mapped_ranges}" unless mapped_ranges.empty?

    # Fill out gaps with identity mappings
    pos = source_range.min
    gaps = []
    mapped_ranges.map do |mapped_range|
      mapped_range[source]
    end.each do |subrange|
      if pos < subrange.min
        gap = pos...(subrange.min)
        puts "  #{source} #{gap} --> #{map[:destination]} #{gap}"
        gaps << {
          source => gap,
          map[:destination] => gap,
        }
      end
      pos = subrange.max + 1
    end

    if pos < source_range.max
      gap = pos..(source_range.max)
      puts "  #{source} #{gap} --> #{map[:destination]} #{gap}"
      gaps << {
        source => gap,
        map[:destination] => gap,
      }
    end

    puts "#{source} #{source_range} has gaps #{gaps}" unless gaps.empty?

    result = (mapped_ranges + gaps).sort do |a, b|
      a[source].min <=> b[source].min
    end

    puts "#{source} #{source_range} totals #{result}"

    result
  end.flatten

  puts ""
  puts "Mappings"
  puts "--------"
  puts mappings

  destination_mappings = mappings.map do |mapped_range|
    mapped_range[map[:destination]]
  end.map do |range|
    (range.min)..(range.max)
  end.sort do |a, b|
    a.min <=> b.min
  end

  puts ""
  puts "#{map[:destination]} mappings"
  puts "-----------------"
  puts destination_mappings

  resolve(maps, map[:destination], destination_mappings)
  # destination_mappings

end

locations = resolve(maps, "seed", seed_ranges)

puts ""
puts "Locations"
puts "---------"
locations.each do |range|
  puts "#{range} (#{range.size})"
end

puts ""
puts "Answer"
puts "------"
puts locations.map {|r| r.min}.min
