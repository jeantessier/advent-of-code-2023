#!/usr/bin/env ruby

# lines = File.readlines("sample1.txt") # Answer: 288
lines = File.readlines("input1.txt") # Answer:

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

#
# Races for a quadratic function.
# For a race of 'n' milliseconds,
# if you hold the buttons for 'x' milliseconds,
# your boat will go a distance of (n-x) * x millimeters.
#
# Or f(x) = (n-x) * x
#         = -1 * x**2 - n * x
#
# If we are looking to beat a distance 'd',
# we look for f(d) > d.
#
# f(x) > d => f(x) - d > 0
#          => -1 * x**2 - n * x - d > 0
#
# This is the quadratic function ax^2 + bx + c
# where:
#        a = -1
#        b = n (the time limit for the race)
#        c = -d (the distance record to beat)
#
# We can find the roots of this quadratic function
# using the quadratic formula:
#
#       -b +/- sqrt(b^2 - 4ac)
#       ----------------------
#                2a
#
# We need to beat the record, so we can find the two
# integers that are greater than each roots and count
# the integers in that range.
#

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
puts ways.reduce(1) {|memo, n| memo * n}
