#!/usr/bin/env ruby

lines = readlines
# lines = File.readlines("sample1a.txt") # Answer: 4
# lines = File.readlines("sample1b.txt") # Answer: 4
# lines = File.readlines("sample1c.txt") # Answer: 8
# lines = File.readlines("sample1d.txt") # Answer: 8
# lines = File.readlines("input.txt") # Answer: 7086

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

def follow_loop(map, navigation)
  x = navigation[:x]
  y = navigation[:y]
  from = navigation[:arriving_from]
  num_steps = 1

  until navigation[:x] == START[:x] and navigation[:y] == START[:y]
    navigation = next_step(map, navigation)
    puts "#{num_steps} [#{x}, #{y}] #{navigation[:going]}"
    x = navigation[:x]
    y = navigation[:y]
    from = navigation[:arriving_from]
    num_steps += 1
  end

  num_steps
end

puts ""
puts "Following Pipe"
puts "--------------"
total_steps = 0
begin
  total_steps = follow_loop(map, {x: START[:x] - 1, y: START[:y], arriving_from: :south})
rescue
  begin
    total_steps = follow_loop(map, {x: START[:x], y: START[:y] + 1, arriving_from: :west})
  rescue
    total_steps = follow_loop(map, {x: START[:x] + 1, y: START[:y], arriving_from: :north})
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
