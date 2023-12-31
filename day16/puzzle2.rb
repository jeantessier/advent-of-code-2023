#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample.txt") # Answer: 51 (in 67 ms)
lines = File.readlines("input.txt") # Answer: 8221 (in 8,261 ms)

class Beam
  attr_reader :from, :to, :wavelength

  def initialize(from, to, wavelength)
    @from = from
    @to = to
    @wavelength = wavelength
  end

  def next_coordinates(x, y)
    case to
    when :rightward then {x: x, y: y + 1, direction: to, wavelength: wavelength}
    when :downward then {x: x + 1, y: y, direction: to, wavelength: wavelength}
    when :leftward then {x: x, y: y - 1, direction: to, wavelength: wavelength}
    when :upward then {x: x - 1, y: y, direction: to, wavelength: wavelength}
    else
      raise "Unknown direction \"#{from}\""
    end
  end

  def ==(other)
    from == other.from and to == other.to and wavelength == other.wavelength
  end
end

class Cell
  attr_reader :cell, :beams

  def initialize(c)
    @cell = c
    @beams = {}
    @beams.default_proc = lambda {|hash, wavelength| hash[wavelength] = []}
  end

  def add_beam(from, wavelength)
    results = case from
              when :rightward then add_rightward_beam(wavelength)
              when :downward then add_downward_beam(wavelength)
              when :leftward then add_leftward_beam(wavelength)
              when :upward then add_upward_beam(wavelength)
              else
                raise "Unknown direction \"#{from}\""
              end

    results = results.reject do |beam|
      # puts "  *** beams.include? beam ==> #{beams}.include? #{beam} ==> #{beams.include?(beam) ? 'REJECTED' : 'OK'}"
      beams[wavelength].include? beam
    end

    results.each {|beam| beams[wavelength] << beam}

    results
  end

  def energized?(wavelength)
    not beams[wavelength].empty?
  end

  def to_s(wavelength)
    return cell if cell != '.' or beams[wavelength].empty?
    return beams[wavelength].size.to_s if beams[wavelength].size > 2

    case beams[wavelength].first.to
    when :rightward then ">"
    when :upward then "^"
    when :leftward then "<"
    when :downward then "v"
    else
      raise "Unknown direction \"#{from}\""
    end
  end

  private

  def add_rightward_beam(wavelength)
    case cell
    when '/'
      [
        Beam.new(:rightward, :upward, wavelength),
      ]
    when '\\'
      [
        Beam.new(:rightward, :downward, wavelength),
      ]
    when '|'
      [
        Beam.new(:rightward, :upward, wavelength),
        Beam.new(:rightward, :downward, wavelength),
      ]
    else
      [
        Beam.new(:rightward, :rightward, wavelength),
      ]
    end
  end

  def add_downward_beam(wavelength)
    case cell
    when '/'
      [
        Beam.new(:downward, :leftward, wavelength),
      ]
    when '\\'
      [
        Beam.new(:downward, :rightward, wavelength),
      ]
    when '-'
      [
        Beam.new(:downward, :leftward, wavelength),
        Beam.new(:downward, :rightward, wavelength),
      ]
    else
      [
        Beam.new(:downward, :downward, wavelength),
      ]
    end
  end

  def add_leftward_beam(wavelength)
    case cell
    when '/'
      [
        Beam.new(:leftward, :downward, wavelength),
      ]
    when '\\'
      [
        Beam.new(:leftward, :upward, wavelength),
      ]
    when '|'
      [
        Beam.new(:leftward, :upward, wavelength),
        Beam.new(:leftward, :downward, wavelength),
      ]
    else
      [
        Beam.new(:leftward, :leftward, wavelength),
      ]
    end
  end

  def add_upward_beam(wavelength)
    case cell
    when '/'
      [
        Beam.new(:upward, :rightward, wavelength),
      ]
    when '\\'
      [
        Beam.new(:upward, :leftward, wavelength),
      ]
    when '-'
      [
        Beam.new(:upward, :leftward, wavelength),
        Beam.new(:upward, :rightward, wavelength),
      ]
    else
      [
        Beam.new(:upward, :upward, wavelength),
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

def print_grid(grid, wavelength)
  grid.each do |row|
    puts row.map {|cell| cell.to_s(wavelength)}.join
  end
end

puts "Grid"
puts "----"
print_grid(grid, 0)

# Start all possible starting posistions, each with its own "wavelength".
beams = []

x_bounds = 0...(grid.size)
y_bounds = 0...(grid.first.size)

x_bounds.each do |x|
  beams << {x: x, y: 0, direction: :rightward, wavelength: "#{x},0,r"}
  beams << {x: x, y: y_bounds.max, direction: :leftward, wavelength: "#{x},#{y_bounds.max},l"}
end

y_bounds.each do |y|
  beams << {x: 0, y: y, direction: :downward, wavelength: "0,#{y},d"}
  beams << {x: x_bounds.max, y: y, direction: :upward, wavelength: "#{x_bounds.max},#{y},u"}
end

# Run all the beams in parallel
until beams.empty?
  # puts beams.to_s
  beam = beams.shift
  resulting_beams = grid[beam[:x]][beam[:y]].add_beam(beam[:direction], beam[:wavelength])
  # puts "    beam: #{beam}"
  # puts "    resulting: #{resulting_beams}"
  resulting_beams.each do |resulting_beam|
    candidate = resulting_beam.next_coordinates(beam[:x], beam[:y])
    beams << candidate if (x_bounds).include?(candidate[:x]) and y_bounds.include?(candidate[:y])
  end
  # puts ""
  # print_grid(grid)
  # sleep 1
  # puts ""
end

def get_energy_level(grid, wavelength)
  grid.sum do |row|
    row.filter {|cell| cell.energized?(wavelength)}.count
  end
end

def get_energy_levels(grid)
  answers = {}

  x_bounds = 0...(grid.size)
  y_bounds = 0...(grid.first.size)

  x_bounds.each do |x|
    answers["#{x},0,r"] = get_energy_level(grid, "#{x},0,r")
    answers["#{x},#{y_bounds.max},l"] = get_energy_level(grid, "#{x},#{y_bounds.max},l")
  end

  y_bounds.each do |y|
    answers["0,#{y},d"] = get_energy_level(grid, "0,#{y},d")
    answers["#{x_bounds.max},#{y},u"] = get_energy_level(grid, "#{x_bounds.max},#{y},u")
  end

  answers
end

def print_energized(grid, wavelength)
  grid.each do |row|
    puts row.map {|cell| cell.energized?(wavelength) ? "#" : "."}.join
  end
end

energy_levels = get_energy_levels(grid)

max_energized = energy_levels.values.max
max_wavelength = energy_levels.rassoc(max_energized)[0]

puts ""
puts "Grid"
puts "----"
print_grid(grid, max_wavelength)

puts ""
puts "Energized Grid"
puts "--------------"
print_energized(grid, max_wavelength)

answer = max_energized

puts ""
puts "Answer"
puts "------"
puts answer, max_wavelength
