#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample.txt") # Answer: 2 (-3 + 0 + 5)
lines = File.readlines("input.txt") # Answer: 1022

def expand_history(history, indent_level = 0)
  puts ("  " * indent_level) + history.to_s

  if history.all?(&:zero?)
    result = [0] + history
    puts ("  " * indent_level) + "--> #{result}"
    return result
  end

  diffs = []
  history.reduce {|previous_value, next_value| diffs << next_value - previous_value; next_value}
  expanded_diffs = expand_history diffs, indent_level + 1

  result = [history.first - expanded_diffs.first] + history
  puts ("  " * indent_level) + "--> #{result}"
  return result
end

puts "Computing"
puts "---------"

previous_values = lines
                .map(&:split)
                .map {|text_values| text_values.map(&:to_i)}
                .map {|history| expand_history(history)}
                .map(&:first)

puts ""
puts "Previous Values"
puts "---------------"
puts previous_values.to_s

puts ""
puts "Answer"
puts "------"
puts previous_values.sum
