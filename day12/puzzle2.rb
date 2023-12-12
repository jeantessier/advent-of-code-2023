#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample.txt") # Answer: 525152 (in 72 ms) (21 when folded, in 46 ms)
lines = File.readlines("input.txt") # Answer: 1909291258644 (in 4,843 ms)

records = lines.map do |line|
  line.split
end

puts "Records"
puts "-------"
records.each do |record|
  puts record.to_s
end

# unfolded_records = records.clone
unfolded_records = records.map do |folded_patterns|
  [
    Array.new(5, folded_patterns[0]).join('?'),
    Array.new(5, folded_patterns[1]).join(','),
  ]
end

puts ""
puts "Unfolded Records"
puts "----------------"
unfolded_records.each do |records|
  puts records.to_s
end

parsed_criteria = unfolded_records.map do |records|
  [
    records[0],
    records[1].split(',').map(&:to_i),
  ]
end

puts ""
puts "Parsed criteria"
puts "----------------"
parsed_criteria.each do |records|
  puts records.to_s
end

CACHE = {}

def search(s, criteria, indent = 0)
  # puts "#{'  ' * indent}search(\"#{s}\", #{criteria})"

  cache_key = "\"#{s}\", #{criteria}"
  return CACHE[cache_key] if CACHE[cache_key]

  (cons, *cdr) = criteria

  text = s.gsub(/^\.+/, '').gsub(/\.+$/, '')

  count = 0

  if cdr.empty?

    count = (0..(text.size - cons)).filter do |i|
      /^(\?|\.){#{i}}(#|\?){#{cons}}(\?|\.)*$/.match(text)
    end.count

  else

    (0..(text.size - cons - cdr.sum - cdr.size)).filter do |i|
      /^(\?|\.){#{i}}(#|\?){#{cons}}(\?|\.)/.match(text)
    end.map do |offset|
      count += search(text[(offset + cons + 1)..], cdr, indent + 1)
    end

  end

  CACHE[cache_key] = count
  # puts "#{'  ' * indent}search(\"#{s}\", #{criteria}) --> #{count}"
  count
end

puts ""
puts "Searching"
puts "---------"

how_far = 0
counts = parsed_criteria.map do |records|
  puts how_far += 1
  search(records[0], records[1])
end

puts ""
puts "Counts"
puts "------"
puts counts.to_s

puts ""
puts "Answer"
puts "------"
puts counts.sum
