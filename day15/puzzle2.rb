#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample.txt") # Answer: 145 (in 57 ms)
lines = File.readlines("input.txt") # Answer: 286278 (in 152 ms)

steps = lines
  .map(&:chomp)
  .flat_map {|line| line.split(',')}

puts "Steps (#{steps.size})"
puts "-----------"
steps.each do |step|
  puts "#{step} (#{step.ascii_only? ? "ascii-only" : "NOT ascii-only"})"
end

class String
  def reindeer_hash
    bytes.reduce(0) do |memo, b|
      memo += b
      memo *= 17
      memo %= 256
    end
  end
end

boxes = {}
boxes.default_proc = lambda {|hash, key| hash[key] = []}

steps.each do |step|
  case step
  when /(\w+)-/
    label = $1
    hash = label.reindeer_hash
    box = boxes[hash]
    box.delete_if {|lens| lens[:label] == label}
  when /(\w+)=(\d+)/
    label = $1
    focal_length = $2.to_i
    new_lens = {label: label, focal_length: focal_length}
    hash = label.reindeer_hash
    box = boxes[hash]
    if (pos = box.find_index {|lens| lens[:label] == label})
      box[pos] = new_lens
    else
      box << new_lens
    end
  end
end

puts ""
puts "Boxes"
puts "-----"
boxes.each do |num, box|
  puts "Box #{num}: #{box.map {|lens| "[#{lens[:label]} #{lens[:focal_length]}]"}.join(" ")}"
end

focusing_powers = boxes.flat_map do |num, box|
  results = []
  box.each_with_index do |lens, i|
    results << (1 + num) * (i + 1) * lens[:focal_length]
  end
  results
end

puts ""
puts "Focusing Powers"
puts "---------------"
puts focusing_powers

puts ""
puts "Answer"
puts "------"
puts focusing_powers.sum
