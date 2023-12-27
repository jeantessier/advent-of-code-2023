#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample.txt") # Answer: 46 (in 51 ms)
lines = File.readlines("input.txt") # Answer: 7608 (in 92 ms)

class Beam
  attr_reader :from, :to

  def initialize(from, to)
    @from = from
    @to = to
  end

  def next_coordinates(x, y)
    case to
    when :rightward then {x: x, y: y + 1, direction: to}
    when :downward then {x: x + 1, y: y, direction: to}
    when :leftward then {x: x, y: y - 1, direction: to}
    when :upward then {x: x - 1, y: y, direction: to}
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
    results = case from
              when :rightward then add_rightward_beam
              when :downward then add_downward_beam
              when :leftward then add_leftward_beam
              when :upward then add_upward_beam
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

  def to_s
    return cell if cell != '.' or beams.empty?
    return beams.size.to_s if beams.size > 2

    case beams.first.to
    when :rightward then ">"
    when :upward then "^"
    when :leftward then "<"
    when :downward then "v"
    else
      raise "Unknown direction \"#{from}\""
    end
  end

  private

  def add_rightward_beam
    case cell
    when '/'
      [
        Beam.new(:rightward, :upward),
      ]
    when '\\'
      [
        Beam.new(:rightward, :downward),
      ]
    when '|'
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
    when '/'
      [
        Beam.new(:downward, :leftward),
      ]
    when '\\'
      [
        Beam.new(:downward, :rightward),
      ]
    when '-'
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
    when '/'
      [
        Beam.new(:leftward, :downward),
      ]
    when '\\'
      [
        Beam.new(:leftward, :upward),
      ]
    when '|'
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
    when '/'
      [
        Beam.new(:upward, :rightward),
      ]
    when '\\'
      [
        Beam.new(:upward, :leftward),
      ]
    when '-'
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

puts ""
puts "Pre-Energized Grid"
puts "------------------"
print_energized(grid)

pre_answer = grid.sum do |row|
  row.filter(&:energized?).count
end

puts ""
puts "Pre-Answer"
puts "----------"
puts pre_answer

beams = [
  {x: 0, y: 0, direction: :rightward}
]

x_bounds = 0...(grid.size)
y_bounds = 0...(grid.first.size)

until beams.empty?
  # puts beams.to_s
  beam = beams.shift
  resulting_beams = grid[beam[:x]][beam[:y]].add_beam beam[:direction]
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

puts ""
puts "Grid"
puts "----"
print_grid(grid)

puts ""
puts "Energized Grid"
puts "--------------"
print_energized(grid)

answer = grid.sum do |row|
  row.filter(&:energized?).count
end

puts ""
puts "Answer"
puts "------"
puts answer
