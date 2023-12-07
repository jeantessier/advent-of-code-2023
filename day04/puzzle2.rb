#!/usr/bin/env ruby

# lines = File.readlines("sample.txt") # Answer: 30
lines = File.readlines("input.txt") # Answer: 8477787

cards = lines.map do |line|
  /Card1\s+(?<card>\d+):\s*(?<winning>.+)\s*\|\s*(?<yours>.+)/.match(line)
end.filter do |m|
  m
end.map do |m|
  # Parse all numbers
  {
    card: m[:card].to_i,
    winning_numbers: m[:winning].split.map {|n| n.to_i},
    your_numbers: m[:yours].split.map {|n| n.to_i},
  }
end.map do |card|
  # Find matching numbers
  card[:intersection] = card[:winning_numbers] & card[:your_numbers]
  card
end.map do |card|
  # Number of matching numbers
  card[:number_of_matches] = card[:intersection].size
  card
end

puts "Cards"
puts "-----"
puts cards

def count_wins(cards, card, index, indent_level)
  result = 1
  puts "#{"  " * indent_level}Processing #{index} card #{card[:card]} with #{card[:number_of_matches]} match(es)"
  if card[:number_of_matches] > 0
    ((card[:card])...(card[:card] + card[:number_of_matches])).each do |i|
      result += count_wins(cards, cards[i], i + 1, indent_level + 1)
    end
  end
  result
end

puts ""
puts "Processing"
puts "----------"

wins = cards.map {|c| count_wins(cards, c, c[:card], 0)}
# wins = []

puts ""
puts "Wins"
puts "----"
puts wins

puts ""
puts "Answer"
puts "------"
puts wins.sum
