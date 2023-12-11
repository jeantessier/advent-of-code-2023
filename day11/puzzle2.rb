#!/usr/bin/env ruby

lines = readlines
# lines = File.readlines("sample.txt") # Answer: 2x: 374, 10x: 1030, 100x 8410
# lines = File.readlines("input.txt") # Answer: 649862989626

# EXPANSION_FACTOR = 2
# EXPANSION_FACTOR = 10
# EXPANSION_FACTOR = 100
EXPANSION_FACTOR = 1_000_000

map = lines
  .map do |line|
    line.chomp.split('')
  end

puts "Map"
puts "---"
map.each do |row|
  puts row.join
end

# Find empty rows
empty_rows = []
map.each_with_index do |row, i|
  empty_rows << i if row.all? {|c| c == '.'}
end

puts ""
puts "Empty Rows"
puts "----------"
puts empty_rows.to_s

# Find empty cols
empty_cols = (0...map.first.size).select do |j|
  map.collect {|row| row[j]}.all? {|c| c == '.'}
end

puts ""
puts "Empty Cols"
puts "----------"
puts empty_cols.to_s

galaxies = []
map.each_with_index do |row, i|
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

def build_range(m, n)
  m < n ? m...n : n...m
end

distances = galaxies.map do |from_galaxy|
  galaxies.map do |to_galaxy|
    # A galaxy to itself has distance 0, so it does not influence the answer
    row_range = build_range from_galaxy[:x], to_galaxy[:x]
    expanded_rows = empty_rows.select {|r| row_range.include?(r)}.count
    col_range = build_range from_galaxy[:y], to_galaxy[:y]
    expanded_cols = empty_cols.select {|c| col_range.include?(c)}.count
    row_range.size - expanded_rows + (expanded_rows * EXPANSION_FACTOR) + col_range.size - expanded_cols + (expanded_cols * EXPANSION_FACTOR)
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
