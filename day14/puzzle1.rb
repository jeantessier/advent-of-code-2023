#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample.txt") # Answer: 136 (in 57 ms)
lines = File.readlines("input.txt") # Answer: 109833 (in 149 ms)

map = lines
        .map(&:chomp)
        .map do |row|
          row.split('')
        end

puts "Map"
puts "---"
map.each do |row|
  puts row.join
end

tilted_map = map.collect {|row| row.clone}

(1...(tilted_map.size)).each do |i|
  (0...(tilted_map.first.size)).each do |j|
    if tilted_map[i][j] == 'O'
      puts "round rock at [#{i}, #{j}]"
      new_i = i
      while new_i > 0 and tilted_map[new_i - 1][j] == '.'
        new_i -= 1
      end
      if i != new_i
        puts "  rolls to [#{new_i}, #{j}]"
        tilted_map[new_i][j] = 'O'
        tilted_map[i][j] = '.'
      end
    end
  end
end

puts ""
puts "Tilted Map"
puts "----------"
tilted_map.each do |row|
  puts row.join
end

counts = tilted_map.map do |row|
  row.filter {|c| c == 'O'}.count
end

puts ""
puts "Counts"
puts "------"
puts counts

weights = []
counts.reverse.each_with_index do |count, i|
  weights << count * (i + 1)
end

puts ""
puts "Weights"
puts "-------"
puts weights

puts ""
puts "Answer"
puts "------"
puts weights.sum
