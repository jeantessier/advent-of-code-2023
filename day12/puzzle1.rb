#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample.txt") # Answer: 21
lines = File.readlines("input.txt") # Answer: 7260 (in 18,699 ms)

def compute_regex(num_pattern)
  pattern = num_pattern
              .split(',')
              .map(&:to_i)
              .map {|n| '#' * n}
              .join('\\.+')
  Regexp.new("^\\.*" + pattern + "\\.*$")
end

class Generator
  include Enumerable

  attr_reader :pattern, :variation

  def initialize(pattern)
    @pattern = pattern
    @variation = pattern.split('').filter {|c| c == '?'}.map {|_| false}
  end

  def rotate(v)
    return v if v.empty?

    v[0] ? ([false] + rotate(v[1..])) : ([true] + v[1..])
  end

  def each
    begin
      # puts @variation.to_s
      current_variation = @variation.clone
      current_string = pattern.split('').map do |c|
        if c == '?'
          (current_variation.shift ? '.' : '#')
        else
          c
        end
      end.join
      @variation = rotate(@variation)
      yield current_string
    end until @variation.none?
  end
end

puts "Generator Test"
puts "--------------"
g = Generator.new '???.###'
g.each do |s|
  puts s
end

counts = lines.map do |line|
  line.split
end.map do |patterns|
  [patterns[0], compute_regex(patterns[1])]
end.map do |patterns|
  pattern = patterns[0]
  regex = patterns[1]

  g = Generator.new pattern
  g.filter do |s|
    m = regex.match(s)
    # puts "#{regex}.match(\"#{s}\"): #{m}"
    m
  end.count
end

puts ""
puts "Counts"
puts "------"
puts counts.to_s

puts ""
puts "Answer"
puts "------"
puts counts.sum
