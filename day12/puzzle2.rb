#!/usr/bin/env ruby

require './search'

# EXPANSION_FACTOR = 1
EXPANSION_FACTOR = 5

# lines = readlines
# lines = File.readlines("sample.txt") # Answer: 525152 (in 70 ms) (21 when folded, in 58 ms)
lines = File.readlines("input.txt") # Answer: 1909291258644 (in 4,843 ms) (7260 when folded, in 200 ms)

records = lines.map do |line|
  line.split
end

puts "Records"
puts "-------"
records.each do |record|
  puts record.to_s
end

# unfolded_records = records.clone
unfolded_records = records.map do |folded_patterns|
  [
    Array.new(EXPANSION_FACTOR, folded_patterns[0]).join('?'),
    Array.new(EXPANSION_FACTOR, folded_patterns[1]).join(','),
  ]
end

puts ""
puts "Unfolded Records"
puts "----------------"
unfolded_records.each do |records|
  puts records.to_s
end

parsed_criteria = unfolded_records.map do |records|
  [
    records[0],
    records[1].split(',').map(&:to_i),
  ]
end

puts ""
puts "Parsed criteria"
puts "----------------"
parsed_criteria.each do |records|
  puts records.to_s
end

puts ""
puts "Searching"
puts "---------"

how_far = 0
counts = parsed_criteria.map do |records|
  puts how_far += 1
  search(records[0], records[1])
end

puts ""
puts "Counts"
puts "------"
puts counts.to_s

puts ""
puts "Answer"
puts "------"
puts counts.sum
