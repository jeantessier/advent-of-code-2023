#!/usr/bin/env ruby

# lines = File.readlines("sample1.txt") # Answer: 4361
lines = File.readlines("input1.txt") # Answer: 498835

def dump_map(name, map, mark = 'T')
  puts name
  map.each {|row| puts row.map {|c| c ? mark : '.'}.join}
end

SYMBOLS = %w[# $ % * + - / = @]

# Find where all the symbols are
symbol_map = lines.map {|line| line.chars.map {|c| SYMBOLS.include?(c)}}
dump_map "symbol_map", symbol_map

puts ""

# Find places that are adjacent to a symbol
adjacency_map = symbol_map.map {|row| row.map {|c| c}}
symbol_map.each_index do |i|
  symbol_map[i].each_index do |j|
    if symbol_map[i][j]
      if i > 0
        # expand in previous row if symbol is on second row or further
        adjacency_map[i-1][j-1] = true if j > 0
        adjacency_map[i-1][j] = true
        adjacency_map[i-1][j+1] = true if j+1 < adjacency_map[i-1].size
      end

      adjacency_map[i][j-1] = true if j > 0
      adjacency_map[i][j+1] = true if j+1 < adjacency_map[i].size

      if i+1 < adjacency_map.size
        # expand in next row if symbol is not on last row
        adjacency_map[i+1][j-1] = true if j > 0
        adjacency_map[i+1][j] = true
        adjacency_map[i+1][j+1] = true if j+1 < adjacency_map[i].size
      end
    end
  end
end
dump_map "adjacency_map", adjacency_map

puts ""

# Find where all the numbers are
number_map = lines.map {|line| line.chars.map {|c| c =~ /\d/}}
dump_map "number_map", number_map

# Find the part numbers

part_numbers = []

regex = /(\d+)/
lines.each_index do |i|
  offset = 0
  while (match = regex.match(lines[i], offset))
    is_adjacent = adjacency_map[i].slice(match.begin(1), match[1].size).any?
    part_numbers << match[1].to_i if is_adjacent
    puts "#{match.begin(1)}..#{match.end(1) - 1}: #{is_adjacent} --> #{match[1]}"
    offset = match.end(1)
  end
end

puts ""
puts "Part Numbers"
puts "------------"
puts part_numbers.join(', ')

puts ""
puts "Answer"
puts "------------"
puts part_numbers.sum
