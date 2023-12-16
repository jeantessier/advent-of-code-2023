#!/usr/bin/env ruby

lines = readlines
# lines = File.readlines("sample.txt") # Answer: 51 (in 42 ms)
# lines = File.readlines("input.txt") # Answer: 8221 (in 3,758 ms)

class Beam
  attr_reader :from, :to

  def initialize(from, to)
    @from = from
    @to = to
  end

  def next_coordinates(x, y)
    case to
    in :rightward
      {x: x, y: y + 1, direction: to}
    in :downward
      {x: x + 1, y: y, direction: to}
    in :leftward
      {x: x, y: y - 1, direction: to}
    in :upward
      {x: x - 1, y: y, direction: to}
    else
      raise "Unknown direction \"#{from}\""
    end
  end

  def ==(other)
    from == other.from and to == other.to
  end
end

class Cell
  attr_reader :cell, :beams

  def initialize(c)
    @cell = c
    @beams = []
  end

  def add_beam(from)
    results = []

    case from
    in :rightward
      results = add_rightward_beam
    in :downward
      results = add_downward_beam
    in :leftward
      results = add_leftward_beam
    in :upward
      results = add_upward_beam
    else
      raise "Unknown direction \"#{from}\""
    end

    results = results.reject do |beam|
      # puts "  *** beams.include? beam ==> #{beams}.include? #{beam} ==> #{beams.include?(beam) ? 'REJECTED' : 'OK'}"
      beams.include? beam
    end

    results.each {|beam| beams << beam}

    results
  end

  def energized?
    not beams.empty?
  end

  def reset!
    beams.clear
  end

  def to_s
    return cell if cell != '.' or beams.empty?
    return beams.size.to_s if beams.size > 2

    case beams.first.to
    in :rightward
      ">"
    in :upward
      "^"
    in :leftward
      "<"
    in :downward
      "v"
    else
      raise "Unknown direction \"#{from}\""
    end
  end

  private

  def add_rightward_beam
    case cell
    in '/'
      [
        Beam.new(:rightward, :upward),
      ]
    in '\\'
      [
        Beam.new(:rightward, :downward),
      ]
    in '|'
      [
        Beam.new(:rightward, :upward),
        Beam.new(:rightward, :downward),
      ]
    else
      [
        Beam.new(:rightward, :rightward),
      ]
    end
  end

  def add_downward_beam
    case cell
    in '/'
      [
        Beam.new(:downward, :leftward),
      ]
    in '\\'
      [
        Beam.new(:downward, :rightward),
      ]
    in '-'
      [
        Beam.new(:downward, :leftward),
        Beam.new(:downward, :rightward),
      ]
    else
      [
        Beam.new(:downward, :downward),
      ]
    end
  end

  def add_leftward_beam
    case cell
    in '/'
      [
        Beam.new(:leftward, :downward),
      ]
    in '\\'
      [
        Beam.new(:leftward, :upward),
      ]
    in '|'
      [
        Beam.new(:leftward, :upward),
        Beam.new(:leftward, :downward),
      ]
    else
      [
        Beam.new(:leftward, :leftward),
      ]
    end
  end

  def add_upward_beam
    case cell
    in '/'
      [
        Beam.new(:upward, :rightward),
      ]
    in '\\'
      [
        Beam.new(:upward, :leftward),
      ]
    in '-'
      [
        Beam.new(:upward, :leftward),
        Beam.new(:upward, :rightward),
      ]
    else
      [
        Beam.new(:upward, :upward),
      ]
    end
  end
end

grid = lines
         .map(&:chomp)
         .map do |line|
           line.split('').map do |c|
             Cell.new c
           end
         end

def print_grid(grid)
  grid.each do |row|
    puts row.map(&:to_s).join
  end
end

puts "Grid"
puts "----"
print_grid(grid)

def print_energized(grid)
  grid.each do |row|
    puts row.map {|cell| cell.energized? ? "#" : "."}.join
  end
end

def get_answer(grid)
  grid.sum do |row|
    row.filter(&:energized?).count
  end
end

def reset(grid)
  grid.each do |row|
    row.each(&:reset!)
  end
end

def run_simulation(grid, x_bounds, y_bounds, starting_beam)
  beams = [starting_beam]

  until beams.empty?
    beam = beams.shift
    resulting_beams = grid[beam[:x]][beam[:y]].add_beam beam[:direction]
    resulting_beams.each do |resulting_beam|
      candidate = resulting_beam.next_coordinates(beam[:x], beam[:y])
      beams << candidate if (x_bounds).include?(candidate[:x]) and y_bounds.include?(candidate[:y])
    end
  end
end

energy_levels = {}
energy_levels.default_proc = lambda {|hash, key| hash[key] = []}

x_bounds = 0...(grid.size)
y_bounds = 0...(grid.first.size)

x_bounds.each do |x|
  starting_beam = { x: x, y: 0, direction: :rightward }
  reset(grid)
  run_simulation(grid, x_bounds, y_bounds, starting_beam)
  energy_levels[get_answer(grid)] << starting_beam
end

x_bounds.each do |x|
  starting_beam = {x: x, y: y_bounds.max, direction: :leftward}
  reset(grid)
  run_simulation(grid, x_bounds, y_bounds, starting_beam)
  energy_levels[get_answer(grid)] << starting_beam
end

y_bounds.each do |y|
  starting_beam = {x: 0, y: y, direction: :downward}
  reset(grid)
  run_simulation(grid, x_bounds, y_bounds, starting_beam)
  energy_levels[get_answer(grid)] << starting_beam
end

y_bounds.each do |y|
  starting_beam = {x: x_bounds.max, y: y, direction: :upward}
  reset(grid)
  run_simulation(grid, x_bounds, y_bounds, starting_beam)
  energy_levels[get_answer(grid)] << starting_beam
end

puts ""
puts "Energy Level Histogram"
puts "----------------------"
energy_levels.sort.each do |energy_level, starting_beams|
  puts sprintf("%3d: %s", energy_level, "*" * starting_beams.size)
end

max_energy_level = energy_levels.keys.max

puts ""
puts "Answer"
puts "------"
puts max_energy_level
puts energy_levels[max_energy_level]

reset(grid)
run_simulation(grid, x_bounds, y_bounds, energy_levels[max_energy_level].first)

puts ""
puts "Grid"
puts "----"
print_grid(grid)

puts ""
puts "Energized Grid"
puts "--------------"
print_energized(grid)

puts ""
puts "Answer"
puts "------"
puts get_answer(grid)
