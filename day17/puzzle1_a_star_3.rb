#!/usr/bin/env ruby

require 'rb_heap'
require './dijkstra'

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
cost_function = lambda {|x, y| heat_loss_map[x][y]}

dijkstra_map = Dijkstra::dijkstra(x_bounds, y_bounds, cost_function)

puts ""
puts "Dijkstra Map"
puts "------------"
print_map(dijkstra_map)

module AStar
  class FringeElement
    include Comparable

    attr_reader :x, :y, :cost, :heuristic, :path, :coords

    def initialize(x, y, cost, heuristic, path, coords)
      @x = x
      @y = y
      @cost = cost
      @heuristic = heuristic
      @path = path
      @coords = coords
    end

    def total
      @total ||= cost + heuristic
    end

    def <=>(other)
      # total <=> other.total

      total_ordering = (total <=> other.total)
      return total_ordering unless total_ordering.zero?

      heuristic <=> other.heuristic
    end

    def to_s
      "[#{x}, #{y}]: #{cost} + #{heuristic} = #{total} \"#{path}\""
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

  def self.a_star(x_bounds, y_bounds, cost_function, heuristic_function, goal_function, x0: nil, y0: nil)
    x0 ||= x_bounds.min
    y0 ||= y_bounds.min

    results = Array.new(x_bounds.size) do
      Array.new(y_bounds.size) do
        Hash.new
      end
    end

    fringe = Heap.new
    # fringe = []

    fringe << FringeElement.new(x0, y0, 0, heuristic_function.call(x0, y0), "", [])

    path_suffix_regex = /(?<suffix>(?<direction>[urdl])\k<direction>?\k<direction>?)$/

    until fringe.empty?
      puts ""
      # puts "fringe.size: #{fringe.size}" if fringe.size % 10_000 == 0
      puts "fringe.size: #{fringe.size}"

      current = fringe.pop # when using Heap
      # current = fringe.sort!.shift # when using Array

      # puts "current: #{current}" if fringe.size % 10_000 == 0
      # puts "current: #{current}" if goal_function.call(current.x, current.y)
      puts "current: #{current}"

      m = path_suffix_regex.match(current.path)
      path_suffix = m ? m[:suffix].to_sym : ""

      results[current.x][current.y][path_suffix] = Result.new(
        current.x,
        current.y,
        current.cost,
        current.path,
      )
      puts "result[#{current.x}][#{current.y}][#{path_suffix}]: #{results[current.x][current.y][path_suffix]}"

      # Terminate early if we reach the goal
      puts "BREAK!!!" if goal_function.call(current.x, current.y)
      break if goal_function.call(current.x, current.y)

      # Remove all from fringe that match coordinates
      # fringe.delete_if {|e| e.x == current.x and e.y == current.y}

      # Put neighbors on the fringe

      # :up
      unless current.path =~ /(u|d)$/
        running_cost = current.cost
        if x_bounds.include?(current.x - 1)
          coord1 = [current.x - 1, current.y]
          unless current.coords.include?(coord1)
            running_cost += cost_function.call(current.x - 1, current.y)
            unless results[current.x - 1][current.y][:u] and running_cost > results[current.x - 1][current.y][:u].cost
              candidate = FringeElement.new(current.x - 1, current.y, running_cost, heuristic_function.call(current.x - 1, current.y), current.path + "u", current.coords + [coord1])
              puts "        --> #{candidate}"
              fringe << candidate
            end

            if x_bounds.include?(current.x - 2)
              coord2 = [current.x - 2, current.y]
              unless current.coords.include?(coord2)
                running_cost += cost_function.call(current.x - 2, current.y)
                unless results[current.x - 2][current.y][:uu] and running_cost > results[current.x - 2][current.y][:uu].cost
                  candidate = FringeElement.new(current.x - 2, current.y, running_cost, heuristic_function.call(current.x - 2, current.y), current.path + "uu", current.coords + [coord1, coord2])
                  puts "        --> #{candidate}"
                  fringe << candidate
                end

                if x_bounds.include?(current.x - 3)
                  coord3 = [current.x - 3, current.y]
                  unless current.coords.include?(coord3)
                    running_cost += cost_function.call(current.x - 3, current.y)
                    unless results[current.x - 3][current.y][:uuu] and running_cost > results[current.x - 3][current.y][:uuu].cost
                      candidate = FringeElement.new(current.x - 3, current.y, running_cost, heuristic_function.call(current.x - 3, current.y), current.path + "uuu", current.coords + [coord1, coord2, coord3])
                      puts "        --> #{candidate}"
                      fringe << candidate
                    end
                  end
                end

              end
            end

          end
        end
      end

      # :right
      unless current.path =~ /(r|l)$/
        running_cost = current.cost
        if y_bounds.include?(current.y + 1)
          coord1 = [current.x, current.y + 1]
          unless current.coords.include?(coord1)
            running_cost += cost_function.call(current.x, current.y + 1)
            unless results[current.x][current.y + 1][:r] and running_cost > results[current.x][current.y + 1][:r].cost
              candidate = FringeElement.new(current.x, current.y + 1, running_cost, heuristic_function.call(current.x, current.y + 1), current.path + "r", current.coords + [coord1])
              puts "        --> #{candidate}"
              fringe << candidate
            end

            if y_bounds.include?(current.y + 2)
              coord2 = [current.x, current.y + 2]
              unless current.coords.include?(coord2)
                running_cost += cost_function.call(current.x, current.y + 2)
                unless results[current.x][current.y + 2][:rr] and running_cost > results[current.x][current.y + 2][:rr].cost
                  candidate = FringeElement.new(current.x, current.y + 2, running_cost, heuristic_function.call(current.x, current.y + 2), current.path + "rr", current.coords + [coord1, coord2])
                  puts "        --> #{candidate}"
                  fringe << candidate
                end

                if y_bounds.include?(current.y + 3)
                  coord3 = [current.x, current.y + 3]
                  unless current.coords.include?(coord3)
                    running_cost += cost_function.call(current.x, current.y + 3)
                    unless results[current.x][current.y + 3][:rrr] and running_cost > results[current.x][current.y + 3][:rrr].cost
                      candidate = FringeElement.new(current.x, current.y + 3, running_cost, heuristic_function.call(current.x, current.y + 3), current.path + "rrr", current.coords + [coord1, coord2, coord3])
                      puts "        --> #{candidate}"
                      fringe << candidate
                    end
                  end
                end

              end
            end

          end
        end
      end

      # :down
      unless current.path =~ /(u|d)$/
        running_cost = current.cost
        if x_bounds.include?(current.x + 1)
          coord1 = [current.x + 1, current.y]
          unless current.coords.include?(coord1)
            running_cost += cost_function.call(current.x + 1, current.y)
            unless results[current.x + 1][current.y][:d] and running_cost > results[current.x + 1][current.y][:d].cost
              candidate = FringeElement.new(current.x + 1, current.y, running_cost, heuristic_function.call(current.x + 1, current.y), current.path + "d", current.coords + [coord1])
              puts "        --> #{candidate}"
              fringe << candidate
            end

            if x_bounds.include?(current.x + 2)
              coord2 = [current.x + 2, current.y]
              unless current.coords.include?(coord2)
                running_cost += cost_function.call(current.x + 2, current.y)
                unless results[current.x + 2][current.y][:dd] and running_cost > results[current.x + 2][current.y][:dd].cost
                  candidate = FringeElement.new(current.x + 2, current.y, running_cost, heuristic_function.call(current.x + 2, current.y), current.path + "dd", current.coords + [coord1, coord2])
                  puts "        --> #{candidate}"
                  fringe << candidate
                end

                if x_bounds.include?(current.x + 3)
                  coord3 = [current.x + 3, current.y]
                  unless current.coords.include?(coord3)
                    running_cost += cost_function.call(current.x + 3, current.y)
                    unless results[current.x + 3][current.y][:ddd] and running_cost > results[current.x + 3][current.y][:ddd].cost
                      candidate = FringeElement.new(current.x + 3, current.y, running_cost, heuristic_function.call(current.x + 3, current.y), current.path + "ddd", current.coords + [coord1, coord2, coord3])
                      puts "        --> #{candidate}"
                      fringe << candidate
                    end
                  end
                end

              end
            end

          end
        end
      end

      # :left
      unless current.path =~ /(r|l)$/
        running_cost = current.cost
        if y_bounds.include?(current.y - 1)
          coord1 = [current.x, current.y - 1]
          unless current.coords.include?(coord1)
            running_cost += cost_function.call(current.x, current.y - 1)
            unless results[current.x][current.y - 1][:l] and running_cost > results[current.x][current.y - 1][:l].cost
              candidate = FringeElement.new(current.x, current.y - 1, running_cost, heuristic_function.call(current.x, current.y - 1), current.path + "l", current.coords + [coord1])
              puts "        --> #{candidate}"
              fringe << candidate
            end

            if y_bounds.include?(current.y - 2)
              coord2 = [current.x, current.y - 2]
              unless current.coords.include?(coord2)
                running_cost += cost_function.call(current.x, current.y - 2)
                unless results[current.x][current.y - 2][:ll] and running_cost > results[current.x][current.y - 2][:ll].cost
                  candidate = FringeElement.new(current.x, current.y - 2, running_cost, heuristic_function.call(current.x, current.y - 2), current.path + "ll", current.coords + [coord1, coord2])
                  puts "        --> #{candidate}"
                  fringe << candidate
                end

                if y_bounds.include?(current.y - 3)
                  coord3 = [current.x, current.y - 3]
                  unless current.coords.include?(coord3)
                    running_cost += cost_function.call(current.x, current.y - 3)
                    unless results[current.x][current.y - 3][:lll] and running_cost > results[current.x][current.y - 3][:lll].cost
                      candidate = FringeElement.new(current.x, current.y - 3, running_cost, heuristic_function.call(current.x, current.y - 3), current.path + "lll", current.coords + [coord1, coord2, coord3])
                      puts "        --> #{candidate}"
                      fringe << candidate
                    end
                  end
                end

              end
            end

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
puts a_star_paths[x_bounds.max][y_bounds.max].values.sort {|a, b| a.cost <=> b.cost}

puts ""
puts "Answer"
puts "------"
puts a_star_paths[x_bounds.max][y_bounds.max].values.map(&:cost).min
