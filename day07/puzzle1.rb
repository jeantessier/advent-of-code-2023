#!/usr/bin/env ruby

require './hand'

# lines = readlines # Answer:
# lines = File.readlines("sample1.txt") # Answer: 6440
lines = File.readlines("input1.txt") # Answer: 246441954

hands = lines
          .map {|line| /(?<cards>.*)\s+(?<bid>\d+)/.match(line)}
          .filter {|m| m}
          .map {|m| Hand.new m[:cards], m[:bid].to_i}

puts "Hands"
puts "-----"
puts hands

ranked_hands = hands.sort

puts ""
puts "Ranked Hands"
puts "------------"
puts ranked_hands

ranked_hands.each_index {|i| ranked_hands[i].rank = i + 1}

puts ""
puts "Winnings"
puts "--------"
puts ranked_hands

puts ""
puts "Answer"
puts "------"
puts ranked_hands.map {|h| h.winnings}.sum
