#!/usr/bin/env ruby

require './hand2'

# lines = readlines
# lines = File.readlines("sample.txt") # Answer: 5905
lines = File.readlines("input.txt") # Answer: 252137472

hands = lines
          .map {|line| /(?<cards>.*)\s+(?<bid>\d+)/.match(line)}
          .filter {|m| m}
          .map {|m| Hand2.new m[:cards], m[:bid].to_i}

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
