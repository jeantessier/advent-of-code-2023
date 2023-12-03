#!/usr/bin/env ruby

# lines = File.readlines("sample1.txt") # Answer: 142
lines = File.readlines("input.txt") # Answer: 53974

calibration_values = lines.map do |line|
  m1 = /(\d)/.match(line)
  m2 = /.*(\d)/.match(line)
  (m1[1].to_i * 10) + m2[1].to_i
end

puts "calibration_values: #{calibration_values}"
puts "sum: #{calibration_values.sum}"
