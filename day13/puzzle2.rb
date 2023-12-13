#!/usr/bin/env ruby

lines = readlines
# lines = File.readlines("sample.txt") # Answer: 400 (in 62 ms)
# lines = File.readlines("input.txt") # Answer: 30442 (in 1,656 ms)

patterns = []

current_pattern = []
patterns << current_pattern

lines
  .map(&:chomp)
  .each do |line|
    if line.empty?
      current_pattern = []
      patterns << current_pattern
    else
      current_pattern << line
    end
  end

puts "Num Patterns"
puts "------------"
puts patterns.size

puts ""
puts "Patterns"
puts "--------"
# puts patterns.to_s
patterns.each do |pattern|
  puts "#{pattern.size} x #{pattern.first.size} = #{pattern.size * pattern.first.size}"
end

def find_horizontal_mirrors(pattern)
  (0...(pattern.size - 1)).filter do |i|
    (1..([i + 1, pattern.size - i - 1].min)).all? do |n|
      pattern[i - n + 1] == pattern[i + n]
    end
  end.map do |i|
    i + 1
  end
end

def find_vertical_mirrors(pattern)
  (0...(pattern.first.size - 1)).filter do |j|
    num_matching_columns = [j + 1, pattern.first.size - j - 1].min
    regex = "^"
    (j + 1 - num_matching_columns).times {|_| regex << "."} if j >= num_matching_columns
    num_matching_columns.times { |_| regex << "(.)" }
    num_matching_columns.times { |n| regex << "\\#{num_matching_columns - n}" }
    pattern.all? {|line| Regexp.new(regex).match(line)}
  end.map do |j|
    j + 1
  end
end

def find_mirrors(pattern)
  {
    horizontal_mirrors: find_horizontal_mirrors(pattern).flatten.uniq,
    vertical_mirrors: find_vertical_mirrors(pattern).flatten.uniq,
  }
end

def build_variations(pattern)
  variations = []
  (0...(pattern.size)).each do |i|
    (0...(pattern.first.size)).each do |j|
      variation = pattern.map {|row| row.clone}
      variation[i][j] = variation[i][j] == '.' ? '#' : '.'
      variations << variation
    end
  end
  variations
end

def find_new_mirrors(pattern)
  original_mirrors = find_mirrors(pattern)

  puts ""
  pattern.each {|r| puts r}
  puts "original mirrors: #{original_mirrors}"

  all_new_mirrors = build_variations(pattern).map do |variation|
    variation_mirrors = find_mirrors(variation)

    new_mirrors = {
      horizontal_mirrors: variation_mirrors[:horizontal_mirrors].reject {|m| original_mirrors[:horizontal_mirrors].include? m},
      vertical_mirrors: variation_mirrors[:vertical_mirrors].reject {|m| original_mirrors[:vertical_mirrors].include? m},
    }

    unless variation_mirrors[:horizontal_mirrors].empty? and variation_mirrors[:vertical_mirrors].empty?
      variation.each {|r| puts r}
      puts new_mirrors.to_s
    end

    new_mirrors
  end.reject do |new_mirrors|
    new_mirrors[:horizontal_mirrors].empty? and new_mirrors[:vertical_mirrors].empty?
  end

  {
    horizontal_mirrors: all_new_mirrors.map {|m| m[:horizontal_mirrors]}.flatten.uniq,
    vertical_mirrors: all_new_mirrors.map {|m| m[:vertical_mirrors]}.flatten.uniq,
  }
end

new_mirrors = patterns
                .map do |pattern|
                  find_new_mirrors(pattern)
                end.reject do |new_mirrors|
                  new_mirrors[:horizontal_mirrors].empty? and new_mirrors[:vertical_mirrors].empty?
                end

puts ""
puts "New Mirrors"
puts "-----------"
new_mirrors.each do |mirrors|
  puts mirrors.to_s
end

puts ""
puts "Answer"
puts "------"
puts 100 * new_mirrors.map {|m| m[:horizontal_mirrors]}.flatten.sum + new_mirrors.flatten.map {|m| m[:vertical_mirrors]}.flatten.sum
