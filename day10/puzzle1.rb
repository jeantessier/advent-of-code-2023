#!/usr/bin/env ruby

lines = readlines
# lines = File.readlines("sample1a.txt") # Answer: 4
# lines = File.readlines("sample1b.txt") # Answer: 4
# lines = File.readlines("sample1c.txt") # Answer: 8
# lines = File.readlines("sample1d.txt") # Answer: 8
# lines = File.readlines("input.txt") # Answer:

class Cell
  attr_reader :glyph, :x, :y

  def initialize(glyph, x, y)
    @glyph = glyph
    @x = x
    @y = y
  end

  def next(arriving_from)
    case arriving_from
    in :north
      case glyph
      in '|'
        :south
      in 'L'
        :east
      in 'J'
        :west
      else
        throw Exception.new("[#{x}, #{y}] does not connect to #{arriving_direction}")
      end
    in :east
      case glyph
      in '-'
        :west
      in 'L'
        :north
      in 'F'
        :south
      else
        throw Exception.new("[#{x}, #{y}] does not connect to #{arriving_direction}")
      end
    in :south
      case glyph
      in '|'
        :north
      in '7'
        :west
      in 'F'
        :east
      else
        throw Exception.new("[#{x}, #{y}] does not connect to #{arriving_direction}")
      end
    in :west
      case glyph
      in '-'
        :east
      in 'J'
        :north
      in '7'
        :south
      else
        throw Exception.new("[#{x}, #{y}] does not connect to #{arriving_direction}")
      end
    end
  end

end

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
# puts map.map {|row| row.to_s}

map.each_with_index do |row, i|
  text = ""
  row.each_with_index do |cell, j|
    text << cell[:glyph]
  end
  puts text
end

def find_start(map)
  result = {}

  result[:x] = map.find_index do |row|
    result[:y] = row.find_index {|cell| cell[:start]}
  end

  result
end

START = find_start map

puts ""
puts "Start"
puts "-----"
puts START

def next_step(map, x, y, arriving_from, steps)
  current_cell = map[x][y]
  next_direction = current_cell[:traversals][arriving_from]
  puts "#{steps}: [#{x}, #{y}] --> #{next_direction}"
  case next_direction
  in :north
    {x: x - 1, y: y, arriving_from: :south}
  in :east
    {x: x, y: y + 1, arriving_from: :west}
  in :south
    {x: x + 1, y: y, arriving_from: :north}
  in :west
    {x: x, y: y - 1, arriving_from: :east}
  else
    throw Exception.new "Cannot arrive to [#{x}, #{y}] from #{arriving_from}"
  end
end

def follow_loop(map, x, y, arriving_from, steps = 0)
  return steps if x == START[:x] and y == START[:y]

  step = next_step(map, x, y, arriving_from, steps)

  follow_loop(map, step[:x], step[:y], step[:arriving_from], steps + 1)
end

puts ""
puts "Following Pipe"
puts "--------------"
total_steps = 0
begin
  total_steps = follow_loop(map, START[:x] - 1, START[:y], :south, 1)
rescue
  begin
    total_steps = follow_loop(map, START[:x], START[:y] + 1, :west, 1)
  rescue
    total_steps = follow_loop(map, START[:x] + 1, START[:y], :north, 1)
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
