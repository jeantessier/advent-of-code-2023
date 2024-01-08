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

module AStar
  class FringeElement
    include Comparable

    attr_reader :x, :y, :cost, :heuristic

    def initialize(x, y, cost, heuristic)
      @x = x
      @y = y
      @cost = cost
      @heuristic = heuristic
    end

    def total
      @total ||= cost + heuristic
    end

    def <=>(other)
      total <=> other.total
    end

    def to_s
      "[#{x}, #{y}]: #{cost} + #{heuristic} = #{total}"
    end
  end

  class Result
    include Comparable

    attr_reader :x, :y, :cost, :path

    def initialize(x, y, cost, path)
      @x = x
      @y = y
      @cost = cost
      @path = path
    end

    def <=>(other)
      cost <=> other.cost
    end

    def to_s
      "[#{x}, #{y}]: #{cost} \"#{path}\""
    end
  end

  class DeterminedNeighbor
    include Comparable

    attr_reader :a_star_result

    def initialize(a_star_result, direction)
      @a_star_result = a_star_result
      @direction = direction
    end

    def x
      a_star_result.x
    end

    def y
      a_star_result.y
    end

    def cost
      a_star_result.cost
    end

    def path
      @path ||= a_star_result.path + @direction
    end

    def <=>(other)
      a_star_result <=> other.a_star_result
    end

    def to_s
      "[#{x}, #{y}]: #{cost} \"#{a_star_result.path}\"+\"#{@direction}\""
    end
  end

  def self.a_star(x_bounds, y_bounds, cost_function, heuristic_function, goal_function, x0: nil, y0: nil)
    x0 ||= x_bounds.min
    y0 ||= y_bounds.min

    results = Array.new(x_bounds.size) do
      Array.new(y_bounds.size)
    end

    # fringe = Heap.new
    fringe = []

    fringe << FringeElement.new(x0, y0, 0, heuristic_function.call(x0, y0))

    until fringe.empty?
      puts ""
      puts "fringe.size: #{fringe.size}"
      # current = fringe.pop # when using Heap
      current = fringe.sort!.shift # when using Array

      puts "current: #{current}"

      # Figure out current value based on determined neighbors
      # (or current if there are no determined neighbors, like at the start)

      determined_neighbors = []

      # :up, going "d"
      if x_bounds.include?(current.x - 1)
        if results[current.x - 1][current.y]
          unless results[current.x - 1][current.y].path =~ /((ddd)|u)$/
            determined_neighbors << DeterminedNeighbor.new(results[current.x - 1][current.y], "d")
          end
        end
      end

      # :right, going "l"
      if y_bounds.include?(current.y + 1)
        if results[current.x][current.y + 1]
          unless results[current.x][current.y + 1].path =~ /((lll)|r)$/
            determined_neighbors << DeterminedNeighbor.new(results[current.x][current.y + 1], "l")
          end
        end
      end

      # :down, going "u"
      if x_bounds.include?(current.x + 1)
        if results[current.x + 1][current.y]
          unless results[current.x + 1][current.y].path =~ /((uuu)|d)$/
            determined_neighbors << DeterminedNeighbor.new(results[current.x + 1][current.y], "u")
          end
        end
      end

      # :left, going "r"
      if y_bounds.include?(current.y - 1)
        if results[current.x][current.y - 1]
          unless results[current.x][current.y - 1].path =~ /((rrr)|l)$/
            determined_neighbors << DeterminedNeighbor.new(results[current.x][current.y - 1], "r")
          end
        end
      end

      determined_neighbors = determined_neighbors.compact.sort
      puts "determined neighbors"
      puts determined_neighbors

      results[current.x][current.y] = Result.new(
        current.x,
        current.y,
        determined_neighbors.empty? ? current.cost : determined_neighbors.first.cost + cost_function.call(current.x, current.y),
        determined_neighbors.empty? ? "" : determined_neighbors.first.path,
      )
      puts "result: #{results[current.x][current.y]}"

      # Terminate early if we reach the goal
      puts "BREAK!!!" if goal_function.call(current.x, current.y)
      break if goal_function.call(current.x, current.y)

      # Remove all from fringe that match coordinates
      fringe.delete_if {|e| e.x == current.x and e.y == current.y}

      # Put undetermined neighbors on the fringe

      # :up
      unless results[current.x][current.y].path =~ /((uuu)|d)$/
        if x_bounds.include?(current.x - 1)
          unless results[current.x - 1][current.y]
            candidate = FringeElement.new(current.x - 1, current.y, results[current.x][current.y].cost + cost_function.call(current.x - 1, current.y), heuristic_function.call(current.x - 1, current.y))
            puts "        --> #{candidate}"
            fringe << candidate
          end
        end
      end

      # :right
      unless results[current.x][current.y].path =~ /((rrr)|l)$/
        if y_bounds.include?(current.y + 1)
          unless results[current.x][current.y + 1]
            candidate = FringeElement.new(current.x, current.y + 1, results[current.x][current.y].cost + cost_function.call(current.x, current.y + 1), heuristic_function.call(current.x, current.y + 1))
            puts "        --> #{candidate}"
            fringe << candidate
          end
        end
      end

      # :down
      unless results[current.x][current.y].path =~ /((ddd)|u)$/
        if x_bounds.include?(current.x + 1)
          unless results[current.x + 1][current.y]
            candidate = FringeElement.new(current.x + 1, current.y, results[current.x][current.y].cost + cost_function.call(current.x + 1, current.y), heuristic_function.call(current.x + 1, current.y))
            puts "        --> #{candidate}"
            fringe << candidate
          end
        end
      end

      # :left
      unless results[current.x][current.y].path =~ /((lll)|r)$/
        if y_bounds.include?(current.y - 1)
          unless results[current.x][current.y - 1]
            candidate = FringeElement.new(current.x, current.y - 1, results[current.x][current.y].cost + cost_function.call(current.x, current.y - 1), heuristic_function.call(current.x, current.y - 1))
            puts "        --> #{candidate}"
            fringe << candidate
          end
        end
      end
    end

    results
  end
end

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
