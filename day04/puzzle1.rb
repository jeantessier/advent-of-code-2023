#!/usr/bin/env ruby

# lines = File.readlines("sample1.txt") # Answer: 13
lines = File.readlines("input1.txt") # Answer: 6306

cards = lines.map do |line|
  /Card \d+:\s*(?<winning>.+)\s*\|\s*(?<yours>.+)/.match(line)
end.filter do |m|
  m
end.map do |m|
  # Parse all numbers
  {
    winning_numbers: m[:winning].split.map {|n| n.to_i},
    your_numbers: m[:yours].split.map {|n| n.to_i},
  }
end.map do |card|
  # Find matching numbers
  card[:winning_numbers] & card[:your_numbers]
end.map do |intersection|
  # Number of matching numbers
  intersection.size
end.filter do |number_of_matches|
  number_of_matches > 0
end.map do |number_of_matches|
  2 ** (number_of_matches - 1)
end

puts "Cards"
puts "-----"
puts cards

puts ""
puts "Answer"
puts "------"
puts cards.sum
