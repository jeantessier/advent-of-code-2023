#!/usr/bin/env ruby

require 'rb_heap'
require './dijkstra'
require './a_star'

lines = readlines
# lines = File.readlines("sample.txt") # Answer: 102 (in 284 ms)
# lines = File.readlines("input.txt") # Answer:  (in  ms)

heat_loss_map = lines
  .map(&:chomp)
  .map do |line|
    line
      .split('')
      .map(&:to_i)
  end

# Renders the map (on *STDOUT* by default)
def print_map(map, out = STDOUT, x_range: nil, y_range: nil)
  x_range ||= 0...(map.size)
  y_range ||= 0...(map.first.size)

  map[x_range].each do |row|
    out.puts row[y_range].map {|c| c.infinite? ? "INF" : sprintf("%3d", c)}.join('|')
  end
end

puts "Heat Loss Map"
puts "-------------"
print_map(heat_loss_map)

x_bounds = 0...(heat_loss_map.size)
y_bounds = 0...(heat_loss_map.first.size)
cost_function = lambda {|x, y| heat_loss_map[x][y]}

dijkstra_map = Dijkstra::dijkstra(x_bounds, y_bounds, cost_function)

puts ""
puts "Dijkstra Map"
puts "------------"
print_map(dijkstra_map)


puts ""
puts "A* Search"
puts "---------"
heuristic_function = lambda {|x, y| dijkstra_map[x][y]}
goal_function = lambda {|x, y| x == x_bounds.max and y == y_bounds.max}
a_star_paths = AStar::a_star(x_bounds, y_bounds, cost_function, heuristic_function, goal_function)

puts ""
puts "A* Paths"
puts "--------"
a_star_paths.each do |row|
  puts row.map {|r| r.nil? ? nil : r.cost}.map {|c| c.nil? ? "   " : sprintf("%3d", c)}.join("|")
end

puts ""
puts "Answer"
puts "------"
puts a_star_paths[x_bounds.max][y_bounds.max].cost
