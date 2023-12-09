#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample.txt") # Answer: 114 (18 + 28 + 68)
lines = File.readlines("input.txt") # Answer: 1868368343

def expand_history(history, indent_level = 0)
  puts ("  " * indent_level) + history.to_s

  if history.all?(&:zero?)
    result = history + [0]
    puts ("  " * indent_level) + "--> #{result}"
    return result
  end

  diffs = []
  history.reduce {|previous_value, next_value| diffs << next_value - previous_value; next_value}
  expanded_diffs = expand_history diffs, indent_level + 1

  result = history + [history.last + expanded_diffs.last]
  puts ("  " * indent_level) + "--> #{result}"
  return result
end

puts "Computing"
puts "---------"

next_values = lines
                .map(&:split)
                .map {|text_values| text_values.map(&:to_i)}
                .map {|history| expand_history(history)}
                .map(&:last)

puts ""
puts "Next Values"
puts "-----------"
puts next_values.to_s

puts ""
puts "Answer"
puts "------"
puts next_values.sum
