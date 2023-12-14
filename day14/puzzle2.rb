#!/usr/bin/env ruby

# lines = readlines
# lines = File.readlines("sample.txt") # Answer: 64 (in 101 ms)
lines = File.readlines("input.txt") # Answer: 99875 (in 1,663 ms)

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

def tilt_north(map)
  1.upto(map.size - 1).each do |i|
    0.upto(map.first.size - 1).each do |j|
      if map[i][j] == 'O' and map[i - 1][j] == '.'
        # puts "round rock at [#{i}, #{j}]"
        new_i = i - 1
        while new_i > 0 and map[new_i - 1][j] == '.'
          new_i -= 1
        end
        # puts "  rolls to [#{new_i}, #{j}]"
        map[new_i][j] = 'O'
        map[i][j] = '.'
      end
    end
  end
end

def tilt_west(map)
  0.upto(map.size - 1).each do |i|
    1.upto(map.first.size - 1).each do |j|
      if map[i][j] == 'O' and map[i][j - 1] == '.'
        # puts "round rock at [#{i}, #{j}]"
        new_j = j - 1
        while new_j > 0 and map[i][new_j - 1] == '.'
          new_j -= 1
        end
        # puts "  rolls to [#{i}, #{new_j}]"
        map[i][new_j] = 'O'
        map[i][j] = '.'
      end
    end
  end
end

def tilt_south(map)
  southern_limit = map.size - 1

  (map.size - 2).downto(0).each do |i|
    0.upto(map.first.size - 1).each do |j|
      if map[i][j] == 'O' and map[i + 1][j] == '.'
        # puts "round rock at [#{i}, #{j}]"
        new_i = i + 1
        while new_i < southern_limit and map[new_i + 1][j] == '.'
          new_i += 1
        end
        # puts "  rolls to [#{new_i}, #{j}]"
        map[new_i][j] = 'O'
        map[i][j] = '.'
      end
    end
  end
end

def tilt_east(map)
  eastern_limit = map.first.size - 1

  0.upto(map.size - 1).each do |i|
    (map.first.size - 2).downto(0).each do |j|
      if map[i][j] == 'O' and map[i][j + 1] == '.'
        # puts "round rock at [#{i}, #{j}]"
        new_j = j + 1
        while new_j < eastern_limit and map[i][new_j + 1] == '.'
          new_j += 1
        end
        # puts "  rolls to [#{i}, #{new_j}]"
        map[i][new_j] = 'O'
        map[i][j] = '.'
      end
    end
  end
end

def cycle(map)
  tilt_north map
  tilt_west map
  tilt_south map
  tilt_east map
end

def weigh(map)
  counts = map.map do |row|
    row.filter {|c| c == 'O'}.count
  end

  weights = []
  counts.reverse.each_with_index do |count, i|
    weights << count * (i + 1)
  end

  weights.sum
end

# NUM_CYCLES = 1
# NUM_CYCLES = 3
NUM_CYCLES = 250
# NUM_CYCLES = 1_000
# NUM_CYCLES = 1_000_000
# NUM_CYCLES = 1_000_000_000

weights = [weigh(map)]

1.upto(NUM_CYCLES).each do |_|
  cycle map
  weights << weigh(map)
end

def period?(nums, period, limit = 3)
  (nums.size - (limit * period.size)).step(nums.size - period.size, period.size).all? do |n|
    nums[n, period.size] == period
  end
end

def find_period(nums)
  period_length = 1
  period = nums[nums.size - period_length, period_length]

  puts period.to_s
  until (period_length > nums.size / 4) or period?(nums, period)
    period_length += 1
    period = nums[nums.size - period_length, period_length]
    puts period.to_s
  end

  raise "Not periodic (yet)!!" unless period?(nums, period)

  period
end

def find_periodicity(nums)
  period = find_period(nums)

  head = 0
  until nums[head, period.size] == period
    head += 1
  end

  {
    head: nums[0...head],
    period: period,
    head_size: head,
    period_size: period.size,
  }
end

periodicity = find_periodicity(weights)

puts ""
puts "periodicity"
puts "-----------"
puts periodicity

TARGET_NUM_CYCLES = 1_000_000_000

index_in_period = (TARGET_NUM_CYCLES - periodicity[:head_size]) % periodicity[:period_size]

puts ""
puts "Index in Period"
puts "---------------"
puts "cycles: #{TARGET_NUM_CYCLES}"
puts "index: #{index_in_period}"

puts ""
puts "Answer"
puts "------"
puts periodicity[:period][index_in_period]
