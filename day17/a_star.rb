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

    attr_reader :neighbor

    def initialize(neighbor, direction_from_neighbor)
      @neighbor = neighbor
      @direction_from_neighbor = direction_from_neighbor
    end

    def x
      neighbor.x
    end

    def y
      neighbor.y
    end

    def cost
      neighbor.cost
    end

    def path
      @path ||= neighbor.path + @direction_from_neighbor
    end

    def <=>(other)
      neighbor <=> other.neighbor
    end

    def to_s
      "[#{x}, #{y}]: #{cost} \"#{neighbor.path}\"+\"#{@direction_from_neighbor}\""
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

      # Terminate early if we've reached the goal
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
