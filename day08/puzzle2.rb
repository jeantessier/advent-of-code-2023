#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample2.txt") # Answer: 6
lines = File.readlines("input.txt") # Answer:

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

current_nodes = map.keys.select {|node| node =~ /..A/}

puts ""
puts "Starting Nodes"
puts "--------------"
puts current_nodes

puts ""
puts "Navigation"
puts "----------"

instructions.cycle.each_with_index do |instruction, i|
  next_nodes = current_nodes.collect {|node| map[node][instruction]}
  puts "#{i}: #{current_nodes} + #{instruction} --> #{next_nodes}"
  current_nodes = next_nodes
  if current_nodes.all? {|node| node =~ /..Z/}
    puts ""
    puts "Answer"
    puts "------"
    puts i + 1
    break
  end
end
