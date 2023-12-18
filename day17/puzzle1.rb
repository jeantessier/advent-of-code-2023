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

def dijkstra(map)
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

  heap.find {|c| c.x == x_bounds.max and c.y == y_bounds.max}.distance = 0

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

dijkstra_map = dijkstra(heat_loss_map)

puts ""
puts "Dijkstra Map"
puts "------------"
print_map(dijkstra_map)

# For testing purposes
null_dijkstra_map = dijkstra_map.collect do |row|
  row.collect {|_| 0}
end

PATH_CACHE = {"" => 0}

def measure_path(heat_loss_map, path, coords)
  result = PATH_CACHE[path]
  return result if result

  last_coord = coords.last
  result = measure_path(heat_loss_map, path[..-2], coords[..-2]) + heat_loss_map[last_coord[0]][last_coord[1]]
  PATH_CACHE[path] = result

  result
end

class MinHeatLossCandidate
  include Comparable

  attr_reader :x, :y, :weight, :total_heat_loss, :path, :coords

  def initialize(x, y, weight, total_heat_loss = Float::INFINITY, path = "", coords = [])
    @x = x
    @y = y
    @weight = weight
    @total_heat_loss = total_heat_loss
    @path = path
    @coords = coords
    coords << [x, y]
  end

  def <=>(other)
    # total_heat_loss <=> other.total_heat_loss
    # weight <=> other.weight

    total_heat_loss_ordering = (total_heat_loss <=> other.total_heat_loss)
    return total_heat_loss_ordering unless total_heat_loss_ordering.zero?

    weight <=> other.weight
  end

  def to_s
    "[#{x}, #{y}]: #{total_heat_loss} \"#{path}\""
  end
end

def min_heat_loss(heat_loss_map, dijkstra_map)
  x_bounds = 0...(heat_loss_map.size)
  y_bounds = 0...(heat_loss_map.first.size)

  best_so_far = Float::INFINITY
  best_path_so_far = ""

  seen_so_far = heat_loss_map.collect do |row|
    row.collect {|_| Float::INFINITY}
  end

  starting_position = MinHeatLossCandidate.new(0, 0, dijkstra_map[0][0], 0)

  possible_next_steps = Heap.new
  possible_next_steps << starting_position

  until possible_next_steps.empty?
    # puts ""
    # puts "possibles (#{possible_next_steps.size})"
    # puts possible_next_steps

    next_step = possible_next_steps.pop
    puts ""
    puts "next: #{next_step}"

    total_heat_loss = measure_path(heat_loss_map, next_step.path, next_step.coords)
    puts "total_heat_loss: #{total_heat_loss}"

    next unless total_heat_loss < best_so_far

    seen_so_far[next_step.x][next_step.y] = next_step.total_heat_loss if next_step.total_heat_loss < seen_so_far[next_step.x][next_step.y]

    if next_step.x == x_bounds.max and next_step.y == y_bounds.max
      best_so_far = total_heat_loss
      best_path_so_far = next_step.path
    end

    # puts ""
    # print_map(seen_so_far)
    puts "best_so_far: #{best_so_far} \"#{best_path_so_far}\""

    if x_bounds.include?(next_step.x - 1) # :up
      unless next_step.path =~ /((uuu)|d)$/
        unless next_step.coords.include?([next_step.x - 1, next_step.y])
          potential_heat_loss = total_heat_loss + heat_loss_map[next_step.x - 1][next_step.y]
          # puts "candidate: [#{next_step.x - 1}, #{next_step.y}]: #{potential_heat_loss} \"#{next_step.path + "u"}\""
          possible_next_steps << MinHeatLossCandidate.new(next_step.x - 1, next_step.y, dijkstra_map[next_step.x - 1][next_step.y], potential_heat_loss, next_step.path + "u", next_step.coords.clone) unless potential_heat_loss >= best_so_far or potential_heat_loss >= seen_so_far[next_step.x - 1][next_step.y]
        end
      end
    end

    if y_bounds.include?(next_step.y + 1) # :right
      unless next_step.path =~ /((rrr)|l)$/
        unless next_step.coords.include?([next_step.x, next_step.y + 1])
          potential_heat_loss = total_heat_loss + heat_loss_map[next_step.x][next_step.y + 1]
          # puts "candidate: [#{next_step.x}, #{next_step.y + 1}]: #{potential_heat_loss} \"#{next_step.path + "r"}\""
          possible_next_steps << MinHeatLossCandidate.new(next_step.x, next_step.y + 1, dijkstra_map[next_step.x][next_step.y + 1], potential_heat_loss, next_step.path + "r", next_step.coords.clone) unless potential_heat_loss >= best_so_far or potential_heat_loss >= seen_so_far[next_step.x][next_step.y + 1]
        end
      end
    end

    if x_bounds.include?(next_step.x + 1) # :down
      unless next_step.path =~ /((ddd)|u)$/
        unless next_step.coords.include?([next_step.x + 1, next_step.y])
          potential_heat_loss = total_heat_loss + heat_loss_map[next_step.x + 1][next_step.y]
          # puts "candidate: [#{next_step.x + 1}, #{next_step.y}]: #{potential_heat_loss} \"#{next_step.path + "d"}\""
          possible_next_steps << MinHeatLossCandidate.new(next_step.x + 1, next_step.y, dijkstra_map[next_step.x + 1][next_step.y], potential_heat_loss, next_step.path + "d", next_step.coords.clone) unless potential_heat_loss >= best_so_far or potential_heat_loss >= seen_so_far[next_step.x + 1][next_step.y]
        end
      end
    end

    if y_bounds.include?(next_step.y - 1) # :left
      unless next_step.path =~ /((lll)|r)$/
        unless next_step.coords.include?([next_step.x, next_step.y - 1])
          potential_heat_loss = total_heat_loss + heat_loss_map[next_step.x][next_step.y - 1]
          # puts "candidate: [#{next_step.x}, #{next_step.y - 1}]: #{potential_heat_loss} \"#{next_step.path + "l"}\""
          possible_next_steps << MinHeatLossCandidate.new(next_step.x, next_step.y - 1, dijkstra_map[next_step.x][next_step.y - 1], potential_heat_loss, next_step.path + "l", next_step.coords.clone) unless potential_heat_loss >= best_so_far or potential_heat_loss >= seen_so_far[next_step.x][next_step.y - 1]
        end
      end
    end
  end

  seen_so_far
end

min_heat_loss_map = min_heat_loss(heat_loss_map, dijkstra_map)

puts ""
puts "Answer"
puts "------"
puts min_heat_loss_map[-1][-1]
