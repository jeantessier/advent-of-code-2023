#!/usr/bin/env ruby

require 'rb_heap'

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

class DijkstraCandidate
  attr_reader :x, :y
  attr_accessor :distance

  def initialize(x, y)
    @x = x
    @y = y
    @distance = Float::INFINITY
  end

  def <=>(other)
    distance <=> other.distance
  end

  def to_s
    "[#{x}, #{y}]: #{distance}"
  end
end

def dijkstra(map, x, y)
  result_map = map.collect do |row|
    row.collect do |_|
      Float::INFINITY
    end
  end

  x_bounds = 0...(map.size)
  y_bounds = 0...(map.first.size)

  heap = []

  map.each_with_index do |row, x|
    row.each_with_index do |_, y|
      heap << DijkstraCandidate.new(x, y)
    end
  end

  # heap.find {|c| c.x == x_bounds.max and c.y == y_bounds.max}.distance = 0
  heap.find {|c| c.x == x and c.y == y}.distance = 0

  until heap.empty?
    candidate = heap.sort!.shift

    result_map[candidate.x][candidate.y] = candidate.distance

    if x_bounds.include?(candidate.x - 1) # :up
      neighbor = heap.find {|c| c.x == candidate.x - 1 and c.y == candidate.y}
      if neighbor
        new_distance = candidate.distance + map[candidate.x - 1][candidate.y]
        neighbor.distance = new_distance if new_distance < neighbor.distance
      end
    end

    if y_bounds.include?(candidate.y + 1) # :right
      neighbor = heap.find {|c| c.x == candidate.x and c.y == candidate.y + 1}
      if neighbor
        new_distance = candidate.distance + map[candidate.x][candidate.y + 1]
        neighbor.distance = new_distance if new_distance < neighbor.distance
      end
    end

    if x_bounds.include?(candidate.x + 1) # :down
      neighbor = heap.find {|c| c.x == candidate.x + 1 and c.y == candidate.y}
      if neighbor
        new_distance = candidate.distance + map[candidate.x + 1][candidate.y]
        neighbor.distance = new_distance if new_distance < neighbor.distance
      end
    end

    if y_bounds.include?(candidate.y - 1) # :left
      neighbor = heap.find {|c| c.x == candidate.x and c.y == candidate.y - 1}
      if neighbor
        new_distance = candidate.distance + map[candidate.x][candidate.y - 1]
        neighbor.distance = new_distance if new_distance < neighbor.distance
      end
    end
  end

  result_map
end

source_dijkstra_map = dijkstra(heat_loss_map, 0, 0)

puts ""
puts "Dijkstra Map (source)"
puts "---------------------"
print_map(source_dijkstra_map)

destination_dijkstra_map = dijkstra(heat_loss_map, heat_loss_map.size - 1, heat_loss_map.first.size - 1)

puts ""
puts "Dijkstra Map (destination)"
puts "--------------------------"
print_map(destination_dijkstra_map)

puts ""
puts "Combined Dijkstra Map"
puts "---------------------"

(0...(heat_loss_map.size)).each do |x|
  row = (0...(heat_loss_map.first.size)).collect do |y|
    (source_dijkstra_map[x][y] + destination_dijkstra_map[x][y]).abs
  end.map {|n| sprintf("%3d", n)}.join ('|')
  puts row
end

puts ""
puts "Answer"
puts "------"
