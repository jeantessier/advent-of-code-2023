#!/usr/bin/env ruby

lines = readlines
# lines = File.readlines("sample2a.txt") # Answer: 4
# lines = File.readlines("sample2b.txt") # Answer: 4
# lines = File.readlines("sample2c.txt") # Answer: 8
# lines = File.readlines("sample2d.txt") # Answer: 10
# lines = File.readlines("input.txt") # Answer: 317

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
# puts original_map.original_map {|row| row.to_s}

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

def follow_loop(original_map, map_copy, navigation)
  x = navigation[:x]
  y = navigation[:y]
  from = navigation[:arriving_from]

  until navigation[:x] == START[:x] and navigation[:y] == START[:y]
    navigation = next_step(original_map, navigation)
    map_copy[x][y] = original_map[x][y][:glyph]
    puts "[#{x}, #{y}] #{navigation[:going]}"
    x = navigation[:x]
    y = navigation[:y]
    from = navigation[:arriving_from]
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
  follow_loop(map, simplified_map, {x: START[:x] - 1, y: START[:y], arriving_from: :south})
rescue
  begin
    follow_loop(map, simplified_map, {x: START[:x], y: START[:y] + 1, arriving_from: :west})
  rescue
    follow_loop(map, simplified_map, {x: START[:x] + 1, y: START[:y], arriving_from: :north})
  end
end

puts ""
puts "Simplified Map"
puts "--------------"
simplified_map.each do |row|
  puts row.join
end

simplified_map.each_with_index do |row, x|
  row.each_with_index do |cell, y|
    if cell == ' '
      left_part = row[0..y].join.gsub(/(L-*7)|(F-*J)/, '|').split('')
      right_part = row[y..].join.gsub(/(L-*7)|(F-*J)/, '|').split('')
      pipes_to_the_left = left_part.filter {|c| c == '|'}.count
      pipes_to_the_right = right_part.filter {|c| c == '|'}.count
      simplified_map[x][y] = ((pipes_to_the_left % 2 == 1) and (pipes_to_the_right % 2 == 1)) ? 'I' : 'O'
    end
  end
end

puts ""
puts "Colored Map"
puts "-----------"
simplified_map.each do |row|
  puts row.join
end

answer = simplified_map.map do |row|
  row.filter {|cell| cell == 'I'}.count
end.sum

puts ""
puts "Answer"
puts "-----------"
puts answer