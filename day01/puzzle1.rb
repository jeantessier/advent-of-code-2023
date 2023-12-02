#!/usr/bin/env ruby

lines = File.readlines("input.txt")

calibration_values = lines.map do |line|
  m1 = /(\d)/.match(line)
  m2 = /.*(\d)/.match(line)
  (m1[1].to_i * 10) + m2[1].to_i
end

puts "calibration_values: #{calibration_values}"
puts "sum: #{calibration_values.sum}"
