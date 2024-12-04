#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines('sample.txt') # Answer: 952408144115 (in ?? ms)
lines = File.readlines('input.txt') # Answer: ?? (in ?? ms) (?? passes)

REGEX = /[DLRU] \d+ \(#(?<distance>\h{5})(?<direction>\h)\)/

Coord = Struct.new(:x, :y)

x = 0
y = 0

path = [ Coord.new(x, y) ]

lines
  .map { |line| REGEX.match(line) }
  .filter { |match| match }
  .each do |match|
    case match[:direction]
    when '1' then x += match[:distance].to_i(16)
    when '3' then x -= match[:distance].to_i(16)
    when '0' then y += match[:distance].to_i(16)
    when '2' then y -= match[:distance].to_i(16)
    else throw Exception.new("Unknown direction: #{match[:direction]}")
    end

    path << Coord.new(x, y)
  end

puts 'Path'
puts '----'
puts path
puts

translate_x = path.map(&:x).min
translate_y = path.map(&:y).min

translated_path = path.map { |point| Coord.new(point.x - translate_x, point.y - translate_y) }

puts 'Translated Path'
puts '---------------'
puts translated_path
puts

# # Renders the map (on *STDOUT* by default)
# def print_map(map, out = STDOUT)
#   map.each do |row|
#     out.puts row.join
#   end
# end

x_range = 0..(translated_path.map(&:x).max)
y_range = 0..(translated_path.map(&:y).max)

puts "x_range: #{x_range}"
puts "y_range: #{y_range}"

# def volume(map)
#   (map.size * map.first.size) - map.map { |row| row.map { |cell| cell == ' ' ? 1 : 0 }.sum }.sum
# end
#
# map = x_range.collect { |_| y_range.collect { |_| '.' } }
#
# puts 'Empty Map'
# puts '---------'
# print_map(map)
# puts
#
# translated_path.each_cons(2) do |p1, p2|
#   puts "  (#{p1.x}, #{p1.y}) --> (#{p2.x}, #{p2.y})"
#   (([ p1.x, p2.x ].min)..([ p1.x, p2.x ].max)).each do |x|
#     (([ p1.y, p2.y ].min)..([ p1.y, p2.y ].max)).each do |y|
#       map[x][y] = '#'
#     end
#   end
# end
# puts
#
# puts 'Map of Path'
# puts '-----------'
# print_map(map)
# puts
#
# # We mark what's outside the path to figure out the area that IS NOT in the
# # lake.  We start by marking the edges, then spiral in towards the center.
# # If a cell is not '#' and it touches a marked cell, it becomes marked.
#
# # Mark the exterior edges
#
# x_range.each do |x|
#   map[x][y_range.first] = ' ' unless map[x][y_range.first] == '#'
#   map[x][y_range.last] = ' ' unless map[x][y_range.last] == '#'
# end
#
# y_range.each do |y|
#   map[x_range.first][y] = ' ' unless map[x_range.first][y] == '#'
#   map[x_range.last][y] = ' ' unless map[x_range.last][y] == '#'
# end
#
# # Spiral in, check all 8 neighbors for a marked cell
#
# def outside?(map, x, y)
#   return false if map[x][y] == '#'
#   return true if map[x][y] == ' '
#
#   map[(x - 1)..(x + 1)].any? do |row|
#     row[(y - 1)..(y + 1)].any? do |cell|
#       cell == ' '
#     end
#   end
# end
#
# previous_volume = -1
# new_volume = volume(map)
#
# while previous_volume != new_volume
#   puts "previous_volume: #{previous_volume}, new volume: #{new_volume}"
#
#   (1...([ x_range.last, y_range.last ].min)).each do |n|
#     (n..(x_range.last - n)).each do |x|
#       map[x][y_range.first + n] = ' ' if outside?(map, x, y_range.first + n)
#       map[x][y_range.last - n] = ' ' if outside?(map, x, y_range.last - n)
#     end
#
#     (n..(y_range.last - n)).each do |y|
#       map[x_range.first + n][y] = ' ' if outside?(map, x_range.first + n, y)
#       map[x_range.last - n][y] = ' ' if outside?(map, x_range.last - n, y)
#     end
#   end
#
#   previous_volume = new_volume
#   new_volume = volume(map)
#
#   puts "new_volume: #{new_volume}"
# end
#
# puts 'Marked Map'
# puts '----------'
# print_map(map)
# puts
#
# volume = volume(map)
#
# puts 'Volume'
# puts '------'
# puts volume
