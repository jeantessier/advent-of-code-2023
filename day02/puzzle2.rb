#!/usr/bin/env ruby

# lines = File.readlines("sample.txt") # Answer: 2286
lines = File.readlines("input.txt") # Answer: 55593

games = lines.map do |line|
  /Game (\d+): (.*)/.match(line)
end.filter do |m|
  m
end.map do |m|
  # Parse each game into its subsets
  {
    game: m[1].to_i,
    subsets: m[2].split(";").map do |subset|
      result = {}
      result.default = 0

      subset.split(",").reduce(result) do |memo, obj|
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
  # Find the maximum of each color seen during this game
  keys = game[:subsets].reduce({}) {|memo, obj| memo.merge(obj)}.keys

  game[:max] = {}
  game[:max].default = 0

  keys.reduce(game[:max]) do |memo, key|
    memo[key] = game[:subsets].map {|h| h[key]}.max
    memo
  end

  game[:power] = game[:max].values.reduce(1) {|memo, v| memo * v}
end

puts "Games"
puts "-----"
puts games

puts ""
puts "Answer"
puts "------"
puts games.map {|g| g[:power]}.sum
