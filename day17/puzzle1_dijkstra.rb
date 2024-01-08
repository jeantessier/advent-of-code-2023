#!/usr/bin/env ruby

require 'rb_heap'
require './dijkstra'

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

# Renders the map on *Sys.out*
def print_map(map, out = STDOUT)
  map.each do |row|
    out.puts row.map {|c| c.infinite? ? "INF" : sprintf("%3d", c)}.join('|')
  end
end

puts "Heat Loss Map"
puts "-------------"
heat_loss_map.each do |row|
  puts row.map {|c| sprintf("%3d", c)}.join('|')
end

x_bounds = 0...(heat_loss_map.size)
y_bounds = 0...(heat_loss_map.first.size)
cost_function = lambda {|x, y| heat_loss_map[x][y]}

source_dijkstra_map = Dijkstra::dijkstra(x_bounds, y_bounds, cost_function, x0: x_bounds.min, y0: y_bounds.min)

puts ""
puts "Dijkstra Map (source)"
puts "---------------------"
print_map(source_dijkstra_map)

destination_dijkstra_map = Dijkstra::dijkstra(x_bounds, y_bounds, cost_function, x0: x_bounds.max, y0: y_bounds.max)

puts ""
puts "Dijkstra Map (destination)"
puts "--------------------------"
print_map(destination_dijkstra_map)

puts ""
puts "Combined Dijkstra Map"
puts "---------------------"

x_bounds.each do |x|
  row = y_bounds.collect do |y|
    (source_dijkstra_map[x][y] + destination_dijkstra_map[x][y]).abs
  end.map {|n| sprintf("%3d", n)}.join ('|')
  puts row
end

puts ""
puts "Answer"
puts "------"
