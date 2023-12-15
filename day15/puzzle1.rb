#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample.txt") # Answer: 1320 (in 45 ms)
lines = File.readlines("input.txt") # Answer: 498538 (in 220 ms)

steps = lines
  .map(&:chomp)
  .flat_map {|line| line.split(',')}

puts "Steps"
puts "-----"
steps.each do |step|
  puts "#{step} (#{step.ascii_only? ? "ascii-only" : "NOT ascii-only"})"
end

hashes = steps.map do |step|
  step.bytes.reduce(0) do |memo, b|
    memo += b
    memo *= 17
    memo %= 256
  end
end

puts ""
puts "Hashes"
puts "------"
puts hashes

puts ""
puts "Answer"
puts "------"
puts hashes.sum
