#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample1a.txt") # Answer: 374
lines = File.readlines("input.txt") # Answer: 10289334

map = lines
  .map do |line|
    line.chomp.split('')
  end

puts "Map"
puts "---"
map.each do |row|
  puts row.join
end

# Double empty rows
half_expanded_map = map.flat_map do |row|
  row.all? {|c| c == '.'} ? [row.clone, row.clone] : [row.clone]
end

puts ""
puts "Half-Expanded Map"
puts "-----------------"
half_expanded_map.each do |row|
  puts row.join
end

# Find empty cols
empty_cols = (0...map.first.size).select do |j|
  map.collect {|row| row[j]}.all? {|c| c == '.'}
end

puts ""
puts "Empty Cols"
puts "----------"
puts empty_cols.to_s

expanded_map = half_expanded_map.collect do |row|
  row_copy = row.clone
  empty_cols.reverse.each do |col|
    row_copy.insert col, '.'
  end
  row_copy
end

puts ""
puts "Expanded Map"
puts "------------"
expanded_map.each do |row|
  puts row.join
end

galaxies = []
expanded_map.each_with_index do |row, i|
  row.each_with_index do |cell, j|
    if cell == '#'
      galaxies << {x: i, y: j}
    end
  end
end

puts ""
puts "Galaxies"
puts "--------"
puts galaxies

distances = galaxies.map do |from_galaxy|
  galaxies.map do |to_galaxy|
    # A galaxy to itself has distance 0, so it does not influence the answer
    (from_galaxy[:x] - to_galaxy[:x]).abs + (from_galaxy[:y] - to_galaxy[:y]).abs
  end
end

puts ""
puts "Distances"
puts "---------"
puts distances.to_s

puts ""
puts "Answer"
puts "------"
puts distances.map(&:sum).sum / 2 # divide by two because each distance is present twice
