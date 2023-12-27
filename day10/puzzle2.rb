#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample2a.txt") # Answer: 4
# lines = File.readlines("sample2b.txt") # Answer: 4
# lines = File.readlines("sample2c.txt") # Answer: 8
# lines = File.readlines("sample2d.txt") # Answer: 10
lines = File.readlines("input.txt") # Answer: 317 (in 312 ms)

map = lines
  .map do |line|
    line
      .split('')
      .map do |cell|
        case cell
        when '|' then {glyph: cell, start: false, traversals: {north: :south, south: :north}}
        when '-' then {glyph: cell, start: false, traversals: {east: :west, west: :east}}
        when 'L' then {glyph: cell, start: false, traversals: {north: :east, east: :north}}
        when 'J' then {glyph: cell, start: false, traversals: {north: :west, west: :north}}
        when '7' then {glyph: cell, start: false, traversals: {south: :west, west: :south}}
        when 'F' then {glyph: cell, start: false, traversals: {south: :east, east: :south}}
        when 'S' then {glyph: cell, start: true, traversals: {}}
        else
          {glyph: cell, start: false, traversals: {}}
        end
      end
end

puts "Map"
puts "---"
map.each do |row|
  puts row.map {|cell| cell[:glyph]}.join
end

START = {}
START[:x] = map.find_index do |row|
  START[:y] = row.find_index {|cell| cell[:start]}
end

puts ""
puts "Start"
puts "-----"
puts START

def next_step(map, navigation)
  current_cell = map[navigation[:x]][navigation[:y]]
  next_direction = current_cell[:traversals][navigation[:arriving_from]]
  case next_direction
  when :north then {x: navigation[:x] - 1, y: navigation[:y], going: :north, arriving_from: :south}
  when :east then {x: navigation[:x], y: navigation[:y] + 1, going: :east, arriving_from: :west}
  when :south then {x: navigation[:x] + 1, y: navigation[:y], going: :south, arriving_from: :north}
  when :west then {x: navigation[:x], y: navigation[:y] - 1, going: :west, arriving_from: :east}
  else
    throw Exception.new "Cannot arrive to [#{navigation[:x]}, #{navigation[:y]}] from #{navigation[:arriving_from]}"
  end
end

def follow_pipe(original_map, map_copy, navigation)
  x = navigation[:x]
  y = navigation[:y]

  until navigation[:x] == START[:x] and navigation[:y] == START[:y]
    navigation = next_step(original_map, navigation)
    map_copy[x][y] = original_map[x][y][:glyph]
    puts "[#{x}, #{y}] going #{navigation[:going]}"
    x = navigation[:x]
    y = navigation[:y]
  end
end

puts ""
puts "Following Pipe"
puts "--------------"

simplified_map = map.collect do |row|
  (1..row.size).collect {|cell| ' '}
end

simplified_map[START[:x]][START[:y]] = 'S'

begin
  follow_pipe(map, simplified_map, { x: START[:x] - 1, y: START[:y], arriving_from: :south})
rescue
  begin
    follow_pipe(map, simplified_map, { x: START[:x], y: START[:y] + 1, arriving_from: :west})
  rescue
    follow_pipe(map, simplified_map, { x: START[:x] + 1, y: START[:y], arriving_from: :north})
  end
end

puts ""
puts "Simplified Map"
puts "--------------"
simplified_map.each do |row|
  puts row.join
end

# Determining 'I' (in) and 'O' (out) of enclosed by loop areas
# by counting the number of times we cross the pipe.  We choose
# to check horizontally from the western edge of the map because
# that's the easiest with our map data structure.
simplified_map.each_with_index do |row, x|
  row.each_with_index do |cell, y|
    if cell == ' '
      crossing_pipes_to_the_western_edge =
        row[0..y]
          .join
          .gsub(/(L-*7)|(F-*J)/, '|')
          .split('')
          .filter {|c| c == '|'}
          .count
      simplified_map[x][y] = (crossing_pipes_to_the_western_edge % 2 == 1) ? 'I' : 'O'
    end
  end
end

puts ""
puts "Enclosure Map"
puts "-------------"
simplified_map.each do |row|
  puts row.join
end

# Counting the 'I's
answer = simplified_map.map do |row|
  row.filter {|cell| cell == 'I'}.count
end.sum

puts ""
puts "Answer"
puts "------"
puts answer