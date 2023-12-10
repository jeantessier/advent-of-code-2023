#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample1a.txt") # Answer: 4
# lines = File.readlines("sample1b.txt") # Answer: 4
# lines = File.readlines("sample1c.txt") # Answer: 8
# lines = File.readlines("sample1d.txt") # Answer: 8
lines = File.readlines("input.txt") # Answer: 7086 (in 292 ms)

map = lines
  .map do |line|
    line
      .split('')
      .map do |cell|
        case cell
        in '|'
          {glyph: cell, start: false, traversals: {north: :south, south: :north}}
        in '-'
          {glyph: cell, start: false, traversals: {east: :west, west: :east}}
        in 'L'
          {glyph: cell, start: false, traversals: {north: :east, east: :north}}
        in 'J'
          {glyph: cell, start: false, traversals: {north: :west, west: :north}}
        in '7'
          {glyph: cell, start: false, traversals: {south: :west, west: :south}}
        in 'F'
          {glyph: cell, start: false, traversals: {south: :east, east: :south}}
        in 'S'
          {glyph: cell, start: true, traversals: {}}
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
  in :north
    {x: navigation[:x] - 1, y: navigation[:y], going: :north, arriving_from: :south}
  in :east
    {x: navigation[:x], y: navigation[:y] + 1, going: :east, arriving_from: :west}
  in :south
    {x: navigation[:x] + 1, y: navigation[:y], going: :south, arriving_from: :north}
  in :west
    {x: navigation[:x], y: navigation[:y] - 1, going: :west, arriving_from: :east}
  else
    throw Exception.new "Cannot arrive to [#{navigation[:x]}, #{navigation[:y]}] from #{navigation[:arriving_from]}"
  end
end

def follow_pipe(map, navigation)
  x = navigation[:x]
  y = navigation[:y]
  num_steps = 1

  until navigation[:x] == START[:x] and navigation[:y] == START[:y]
    navigation = next_step(map, navigation)
    puts "#{num_steps} [#{x}, #{y}] going #{navigation[:going]}"
    x = navigation[:x]
    y = navigation[:y]
    num_steps += 1
  end

  num_steps
end

puts ""
puts "Following Pipe"
puts "--------------"
total_steps = 0
begin
  # If we cannot go North from the start, it will blow up and we'll try another direction.
  total_steps = follow_pipe(map, { x: START[:x] - 1, y: START[:y], arriving_from: :south})
rescue
  begin
    # If we cannot go East from the start, it will blow up and we'll try another direction.
    total_steps = follow_pipe(map, { x: START[:x], y: START[:y] + 1, arriving_from: :west})
  rescue
    # We must be able to go in two directions from the start.  If not North or East, than South will work.
    total_steps = follow_pipe(map, { x: START[:x] + 1, y: START[:y], arriving_from: :north})
  end
end

puts ""
puts "Total Steps"
puts "-----------"
puts total_steps

puts ""
puts "Answer"
puts "-----------"
puts (total_steps / 2.0).round
