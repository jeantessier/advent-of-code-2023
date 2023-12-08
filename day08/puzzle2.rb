#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample2.txt") # Answer: 6
lines = File.readlines("input.txt") # Answer: 34002592904266863793513273

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

starting_nodes = map.keys.select {|node| node =~ /..A/}

puts ""
puts "Starting Nodes"
puts "--------------"
puts starting_nodes

def navigate(map, instructions, starting_node)
  current_node = starting_node
  answer = 0
  instructions.cycle.each_with_index do |instruction, i|
    next_node = map[current_node][instruction]
    # puts "#{i}: #{current_node} + #{instruction} --> #{next_node}"
    current_node = next_node
    if current_node =~ /..Z/
      # puts ""
      # puts "Answer"
      # puts "------"
      answer = i + 1
      puts "#{starting_node} --> #{current_node}: #{answer}"
      break
    end
  end

  answer
end

puts ""
puts "Navigations"
puts "-----------"
cycle_lengths = starting_nodes.collect do |node|
  navigate(map, instructions, node)
end

puts ""
puts "Cycle Lengths"
puts "-------------"
puts cycle_lengths

puts ""
puts "Answer"
puts "------"
puts cycle_lengths.reduce(:*)
