#!/usr/bin/env ruby

require 'rb_heap'

lines = readlines
# lines = File.readlines("sample.txt") # Answer: 102 (in 132 ms)
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
cost_function = -> (x, y) {heat_loss_map[x][y]}

module HeapSearch
  Coord = Struct.new(:x, :y)

  class HeapElement
    include Comparable

    attr_reader :x, :y, :cost, :path, :coords

    def initialize(x, y, cost, path, coords)
      @x = x
      @y = y
      @cost = cost
      @path = path
      @coords = coords
    end

    def <=>(other)
      cost <=> other.cost
    end

    def to_s
      "[#{x}, #{y}]: #{cost} \"#{path}\""
    end
  end

  class Result
    attr_reader :x, :y, :cost, :path

    def initialize(x, y, cost, path)
      @x = x
      @y = y
      @cost = cost
      @path = path
    end

    def to_s
      "[#{x}, #{y}]: #{cost} \"#{path}\""
    end
  end

  def self.search(x_bounds, y_bounds, cost_function, goal_function, x0: nil, y0: nil)
    x0 ||= x_bounds.min
    y0 ||= y_bounds.min

    results = Array.new(x_bounds.size) do
      Array.new(y_bounds.size, Float::INFINITY)
    end
    # puts "results:"
    # print_map(results.map)

    heap = Heap.new

    heap << HeapElement.new(x0, y0, 0, "", [])

    path_suffix_regex = /(?<suffix>(?<direction>[urdl])\k<direction>?\k<direction>?)$/

    until heap.empty?
      puts ""
      # puts "heap.size: #{heap.size}" if heap.size % 10_000 == 0
      puts "heap.size: #{heap.size}"

      current = heap.pop

      # puts "current: #{current}" if heap.size % 10_000 == 0
      # puts "current: #{current}" if goal_function.call(current.x, current.y)
      puts "current: #{current}"

      m = path_suffix_regex.match(current.path)
      path_suffix = m ? m[:suffix].to_sym : ""

      if current.cost < results[current.x][current.y]
        results[current.x][current.y] = current.cost
      end
      puts "results[#{current.x}][#{current.y}]: #{results[current.x][current.y]}"
      # print_map(results)

      # Terminate early if we reach the goal
      puts "BREAK!!!" if goal_function.call(current.x, current.y)
      break if goal_function.call(current.x, current.y)

      # Put neighbors on the heap

      # :up
      if x_bounds.include?(current.x - 1) # :up
        unless current.path =~ /((uuu)|d)$/
          coord = Coord.new(current.x - 1, current.y)
          new_cost = current.cost + cost_function.call(coord.x, coord.y)
          unless current.coords.include?(coord) and new_cost < results[coord.x][coord.y]
            candidate = HeapElement.new(coord.x, coord.y, new_cost, current.path + "u", current.coords + [coord])
            puts "        --> #{candidate}"
            heap << candidate
          end
        end
      end

      # :right
      if y_bounds.include?(current.y + 1) # :right
        unless current.path =~ /((rrr)|l)$/
          coord = Coord.new(current.x, current.y + 1)
          new_cost = current.cost + cost_function.call(coord.x, coord.y)
          unless current.coords.include?(coord) and new_cost < results[coord.x][coord.y]
            candidate = HeapElement.new(coord.x, coord.y, new_cost, current.path + "r", current.coords + [coord])
            puts "        --> #{candidate}"
            heap << candidate
          end
        end
      end

      # :down
      if x_bounds.include?(current.x + 1) # :down
        unless current.path =~ /((ddd)|u)$/
          coord = Coord.new(current.x + 1, current.y)
          new_cost = current.cost + cost_function.call(coord.x, coord.y)
          unless current.coords.include?(coord) and new_cost < results[coord.x][coord.y]
            candidate = HeapElement.new(coord.x, coord.y, new_cost, current.path + "d", current.coords + [coord])
            puts "        --> #{candidate}"
            heap << candidate
          end
        end
      end

      # :left
      if y_bounds.include?(current.y - 1) # :left
        unless current.path =~ /((lll)|r)$/
          coord = Coord.new(current.x, current.y - 1)
          new_cost = current.cost + cost_function.call(coord.x, coord.y)
          unless current.coords.include?(coord) and new_cost < results[coord.x][coord.y]
            candidate = HeapElement.new(coord.x, coord.y, new_cost, current.path + "l", current.coords + [coord])
            puts "        --> #{candidate}"
            heap << candidate
          end
        end
      end
    end

    results
  end
end

puts ""
puts "Heap Search"
puts "-----------"
goal_function = -> (x, y) {x == x_bounds.max and y == y_bounds.max}
heap_search_paths = HeapSearch::search(x_bounds, y_bounds, cost_function, goal_function)

puts ""
puts "Heap Search Paths"
puts "-----------------"
print_map(heap_search_paths)

puts ""
puts "Answer"
puts "------"
puts heap_search_paths[x_bounds.max][y_bounds.max]
