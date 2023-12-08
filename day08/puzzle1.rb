#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample1a.txt") # Answer: 2
# lines = File.readlines("sample2b.txt") # Answer: 6
lines = File.readlines("input.txt") # Answer: 17873

map = lines
  .map {|line| /(?<node>\w+)\s*=\s*\((?<left>\w+),\s*(?<right>\w+)\)/.match(line)}
  .filter {|m| m}
  .reduce({}) do |map, m|
    map[m[:node]] = {
      L: m[:left],
      R: m[:right],
    }
    map
  end

puts "Map"
puts "---"
puts map

instructions = lines.first.chomp.split('').map(&:to_sym)

puts ""
puts "Instructions"
puts "------------"
puts instructions

puts ""
puts "Navigation"
puts "----------"

current_node = 'AAA'
instructions.cycle.each_with_index do |instruction, i|
  next_node = map[current_node][instruction]
  puts "#{i}: #{current_node} + #{instruction} --> #{next_node}"
  current_node = next_node
  if current_node == 'ZZZ'
    puts ""
    puts "Answer"
    puts "------"
    puts i + 1
    break
  end
end
