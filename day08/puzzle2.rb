#!/usr/bin/env ruby

require 'prime'

# lines = readlines
# lines = File.readlines("sample2.txt") # Answer: 6
lines = File.readlines("input.txt") # Answer: 15746133679061

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

factorized_cycle_lengths = cycle_lengths.map {|cycle_length| cycle_length.prime_division}

puts ""
puts "Factorized Cycle Lengths"
puts "------------------------"
factorized_cycle_lengths.each do |primes|
  puts primes.to_s
end

histo = {}
histo.default_proc = lambda {|hash, key| hash[key] = []}
factorized_cycle_lengths.reduce(histo) do |memo, factors|
  factors.each do |pair|
    memo[pair[0]] << pair[1]
  end
  memo
end

puts ""
puts "Histo"
puts "-----"
puts histo

common_factors = histo.select do |factor, counts|
  counts.size == factorized_cycle_lengths.size
end.map do |factor, counts|
  [factor, counts.min]
end.to_h

common_factors.default = 0

puts ""
puts "Common Factors"
puts "--------------"
puts common_factors.to_s

remaining_factors = factorized_cycle_lengths.map do |factors|
  factors.map do |pair|
    pair[0] ** (pair[1] - common_factors[pair[0]])
  end
end.flatten

puts ""
puts "Remaining Factors"
puts "-----------------"
puts remaining_factors.to_s

puts ""
puts "Answer"
puts "------"
puts (common_factors.map {|factor, power| factor ** power} + remaining_factors).reduce(:*)
