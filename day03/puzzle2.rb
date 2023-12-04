#!/usr/bin/env ruby

require 'set'

# lines = File.readlines("sample.txt") # Answer: 467835
lines = File.readlines("input.txt") # Answer: 75519888

def dump_map(name, map, mark = 'T')
  puts name
  map.each {|row| puts row.map {|c| c ? mark : '.'}.join}
end

# Find where all the gears are
gear_map = lines.map {|line| line.chars.map {|c| c == '*'}}

puts "Gear Map"
puts "--------"
gear_map.each {|row| puts row.map {|c| c ? 'G' : '.'}.join}

# Find places that are adjacent to a gear
adjacency_map = gear_map.map {|row| row.map {|c| []}}
gear_map.each_index do |i|
  gear_map[i].each_index do |j|
    if gear_map[i][j]
      gear_name = "#{i}:#{j}"
      if i > 0
        # expand in previous row if symbol is on second row or further
        adjacency_map[i-1][j-1] << gear_name if j > 0
        adjacency_map[i-1][j] << gear_name
        adjacency_map[i-1][j+1] << gear_name if j+1 < adjacency_map[i-1].size
      end

      adjacency_map[i][j-1] << gear_name if j > 0
      adjacency_map[i][j] << gear_name
      adjacency_map[i][j+1] << gear_name if j+1 < adjacency_map[i].size

      if i+1 < adjacency_map.size
        # expand in next row if symbol is not on last row
        adjacency_map[i+1][j-1] << gear_name if j > 0
        adjacency_map[i+1][j] << gear_name
        adjacency_map[i+1][j+1] << gear_name if j+1 < adjacency_map[i].size
      end
    end
  end
end

puts ""
puts "Adjacency Map"
puts "-------------"
adjacency_map.each {|row| puts row.map {|c| c.empty? ? '.' : c}.join}

# Find the part numbers that are adjacent to gears

gear_to_part_number = {}
gear_to_part_number.default_proc = lambda { |hash, key| hash[key] = [] }

regex = /(\d+)/
lines.each_index do |i|
  offset = 0
  while (match = regex.match(lines[i], offset))
    adjacent_gears = adjacency_map[i].slice(match.begin(1), match[1].size).reject {|c| c.empty?}.flatten
    Set.new(adjacent_gears).each do |gear|
      gear_to_part_number[gear] << match[1].to_i
      puts "#{match.begin(1)}..#{match.end(1) - 1}: #{match[1]} --> #{gear}"
    end
    offset = match.end(1)
  end
end

puts ""
puts "Gears"
puts "-----"
gear_to_part_number.each do |gear, part_numbers|
  puts "#{gear}: #{part_numbers}"
end

histo = {}
histo.default = 0
gear_to_part_number.each {|gear, part_numbers| histo[part_numbers.size] += 1}

puts ""
puts "Gears Histo"
puts "-----------"
puts histo.to_s

puts ""
puts "Answer"
puts "------------"
puts gear_to_part_number
       .values
       .filter {|part_numbers| part_numbers.size == 2}
       .map {|part_numbers| part_numbers[0] * part_numbers[1]}
       .sum
