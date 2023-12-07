#!/usr/bin/env ruby

# lines = File.readlines("sample.txt") # Answer: 288
lines = File.readlines("input.txt") # Answer: 588588

times = lines
          .grep(/Time/)
          .map {|line| line.split}
          .flatten
          .filter {|s| s =~ /\d+/}
          .map {|s| s.to_i}

distances = lines
          .grep(/Distance/)
          .map {|line| line.split}
          .flatten
          .filter {|s| s =~ /\d+/}
          .map {|s| s.to_i}

races = times
          .zip(distances)
          .map {|a| {time: a[0], distance: a[1]}}

puts "Races"
puts "-----"
puts races

def quadratic_roots(a:, b:, c:)
  [
    ((-1 * b + Math.sqrt(b**2 - 4*a*c)) / 2*a),
    ((-1 * b - Math.sqrt(b**2 - 4*a*c)) / 2*a),
  ]
end

def count_ways_to_win_race(time:, distance:)
  roots = quadratic_roots(a: -1, b: time, c: -distance)

  # Raise lowest boundary if root is an integer
  lowest_boundary = roots.min.ceil
  lowest_boundary += 1 if (roots.min - lowest_boundary).zero?

  # Lower highest boundary if root is an integer
  highest_boundary = roots.max.floor
  highest_boundary -= 1 if (roots.max - highest_boundary).zero?

  (lowest_boundary..highest_boundary).size
end

ways = races.map do |race|
  count_ways_to_win_race time: race[:time], distance: race[:distance]
end

puts ""
puts "Ways"
puts "----"
puts ways

puts ""
puts "Answer"
puts "------"
puts ways.reduce(:*)
