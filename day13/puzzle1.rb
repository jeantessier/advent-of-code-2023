#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample.txt") # Answer: 405 (in 46 ms)
lines = File.readlines("input.txt") # Answer: 35538 (in 50 ms)

patterns = []

current_pattern = []
patterns << current_pattern

lines
  .map(&:chomp)
  .each do |line|
    if line.empty?
      current_pattern = []
      patterns << current_pattern
    else
      current_pattern << line
    end
  end

puts "Num Patterns"
puts "------------"
puts patterns.size

puts ""
puts "Patterns"
puts "--------"
# puts patterns.to_s
patterns.each do |pattern|
  puts "#{pattern.size} x #{pattern.first.size}"
end

def find_horizontal_mirrors(pattern)
  (0...(pattern.size - 1)).filter do |i|
    (1..([i + 1, pattern.size - i - 1].min)).all? do |n|
      pattern[i - n + 1] == pattern[i + n]
    end
  end.map do |i|
    i + 1
  end
end

horizontal_mirrors = patterns
                       .map do |pattern|
                         find_horizontal_mirrors(pattern)
                       end

puts ""
puts "Horizontal Mirrors"
puts "------------------"
# puts horizontal_mirrors.to_s
horizontal_mirrors.each do |mirrors|
  puts mirrors.to_s
end

def find_vertical_mirrors(pattern)
  (0...(pattern.first.size - 1)).filter do |j|
    num_matching_columns = [j + 1, pattern.first.size - j - 1].min
    regex = "^"
    (j + 1 - num_matching_columns).times {|_| regex << "."} if j >= num_matching_columns
    num_matching_columns.times { |_| regex << "(.)" }
    num_matching_columns.times { |n| regex << "\\#{num_matching_columns - n}" }
    pattern.all? {|line| Regexp.new(regex).match(line)}
  end.map do |j|
    j + 1
  end
end

vertical_mirrors = patterns
                     .map do |pattern|
                       find_vertical_mirrors(pattern)
                     end

puts ""
puts "Vertical Mirrors"
puts "----------------"
# puts vertical_mirrors.to_s
vertical_mirrors.each do |mirrors|
  puts mirrors.to_s
end

puts ""
puts "Answer"
puts "------"
puts 100 * horizontal_mirrors.flatten.sum + vertical_mirrors.flatten.sum
