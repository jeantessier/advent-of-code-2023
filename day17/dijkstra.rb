module Dijkstra
  class Candidate
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

  def self.dijkstra(x_bounds, y_bounds, cost_function, x0: nil, y0: nil)
    x0 ||= x_bounds.max
    y0 ||= y_bounds.max

    result_map = Array.new(x_bounds.size) do
      Array.new(y_bounds.size, Float::INFINITY)
    end

    heap = x_bounds.flat_map do |x|
      y_bounds.map do |y|
        Candidate.new(x, y)
      end
    end

    heap.find {|c| c.x == x0 and c.y == y0}.distance = 0

    until heap.empty?
      candidate = heap.sort!.shift

      result_map[candidate.x][candidate.y] = candidate.distance

      candidate_cost = cost_function.call(candidate.x, candidate.y)
      neighbor_distance_through_candidate = candidate.distance + candidate_cost

      if x_bounds.include?(candidate.x - 1) # :up
        neighbor = heap.find {|c| c.x == candidate.x - 1 and c.y == candidate.y}
        if neighbor
          neighbor.distance = neighbor_distance_through_candidate if neighbor_distance_through_candidate < neighbor.distance
        end
      end

      if y_bounds.include?(candidate.y + 1) # :right
        neighbor = heap.find {|c| c.x == candidate.x and c.y == candidate.y + 1}
        if neighbor
          neighbor.distance = neighbor_distance_through_candidate if neighbor_distance_through_candidate < neighbor.distance
        end
      end

      if x_bounds.include?(candidate.x + 1) # :down
        neighbor = heap.find {|c| c.x == candidate.x + 1 and c.y == candidate.y}
        if neighbor
          neighbor.distance = neighbor_distance_through_candidate if neighbor_distance_through_candidate < neighbor.distance
        end
      end

      if y_bounds.include?(candidate.y - 1) # :left
        neighbor = heap.find {|c| c.x == candidate.x and c.y == candidate.y - 1}
        if neighbor
          neighbor.distance = neighbor_distance_through_candidate if neighbor_distance_through_candidate < neighbor.distance
        end
      end
    end

    result_map
  end
end
