#!/usr/bin/env ruby

lines = File.readlines("sample2.txt") # Answer: 281
# lines = File.readlines("input.txt") # Answer: 52840

word_to_i = {
  one: 1,
  two: 2,
  three: 3,
  four: 4,
  five: 5,
  six: 6,
  seven: 7,
  eight: 8,
  nine: 9,
}
word_to_i.default = 0

calibration_values = lines.map do |line|
  m1 = /(\d|#{word_to_i.keys.join('|')})/.match(line)
  m2 = /.*(\d|#{word_to_i.keys.join('|')})/.match(line)
  puts "m1[1]: #{m1[1]}, m2[1]: #{m2[1]}"
  i1 = m1[1].to_i
  i2 = m2[1].to_i
  puts "i1: #{i1}, i2: #{i2}"
  w1 = word_to_i[m1[1].to_sym]
  w2 = word_to_i[m2[1].to_sym]
  puts "w1: #{w1}, w2: #{w2}"
  d1 = [i1, w1].max
  d2 = [i2, w2].max
  puts "d1: #{d1}, d2: #{d2}"
  
  (d1 * 10) + d2
end

puts "calibration_values: #{calibration_values}"
puts "sum: #{calibration_values.sum}"
