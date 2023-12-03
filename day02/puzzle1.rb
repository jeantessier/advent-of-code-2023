#!/usr/bin/env ruby

# lines = File.readlines("puzzle1.sample_input.txt") # Answer: 8
lines = File.readlines("puzzle1.input.txt") # Answer: 2913

games = lines.map do |line|
  /Game (\d+): (.*)/.match(line)
end.filter do |m|
  m
end.map do |m|
  {
    game: m[1].to_i,
    hands: m[2].split(";").map do |hand|
      result = {}
      result.default = 0

      hand.split(",").reduce(result) do |memo, obj|
        match = /(\d+) (\w+)/.match(obj)
        if match
          memo[match[2].to_sym] += match[1].to_i
        end
        memo
      end
      
      result
    end
  }
end.each do |game|
  keys = game[:hands].reduce({}) {|memo, obj| memo.merge(obj)}.keys

  game[:max] = {}
  game[:max].default = 0

  keys.reduce(game[:max]) do |memo, key|
    memo[key] = game[:hands].map {|h| h[key]}.max
    memo
  end
end

puts "Games"
puts "-----"
puts games

target = {
  red: 12,
  green: 13,
  blue: 14,
}

possible_games = games.filter do |game|
  target.keys.all? {|k| game[:max][k] <= target[k]}
end

puts ""
puts "Possible Games"
puts "--------------"
puts possible_games

puts ""
puts "Answer"
puts "------"
puts possible_games.map {|g| g[:game]}.sum
