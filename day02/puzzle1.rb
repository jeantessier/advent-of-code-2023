#!/usr/bin/env ruby

# lines = File.readlines("puzzle1.sample_input.txt") # Answer: 8
lines = File.readlines("puzzle1.input.txt") # Answer: 2913

games = lines.map do |line|
  m = /Game (\d+): (.*)/.match(line)
  if m
    {
      game: m[1].to_i,
      hands: m[2].split(";").map do |hand|
        m_red = /(\d+) red/.match(hand)
        m_green = /(\d+) green/.match(hand)
        m_blue = /(\d+) blue/.match(hand)
        {
          red: m_red ? m_red[1].to_i : 0,
          green: m_green ? m_green[1].to_i : 0,
          blue: m_blue ? m_blue[1].to_i : 0,
        }
      end
    }
  else
    nil
  end
end.filter do |game|
  game
end.each do |game|
  game[:max] = {
    red: game[:hands].map {|h| h[:red]}.max,
    green: game[:hands].map {|h| h[:green]}.max,
    blue: game[:hands].map {|h| h[:blue]}.max,
  }
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
  game[:max][:red] <= target[:red] &&
    game[:max][:green] <= target[:green] &&
    game[:max][:blue] <= target[:blue]
end

puts ""
puts "Possible Games"
puts "--------------"
puts possible_games

puts ""
puts "Answer"
puts "------"
puts possible_games.map {|g| g[:game]}.sum
