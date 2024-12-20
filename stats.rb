#!/usr/bin/env ruby

#
# Prints my stats as a CSV.
#
#     ./stats.rb > stats.csv
# or
#     ./stats.rb | tee stats.csv
#
# It can fetch the overall stats from adventofcode.com, since they are public
# data.  But getting personal times requires authentication.  I don't know how
# to do that, so I copy my stats in this script as they become available.
#

require 'net/http'

STATS_REGEX = %r{<a href="/\d+/day/\d+">\s*(?<day>\d+)\s+<span class="stats-both">\s*(?<both>\d+)</span>\s*<span class="stats-firstonly">\s*(?<firstonly>\d+)</span>}

uri = URI.parse('https://adventofcode.com/2023/stats')
response = Net::HTTP.get_response(uri)
overall_stats = response.body
                        .lines
                        .map { |line| STATS_REGEX.match(line) }.compact
                        .map { |match| match[1..] }
                        .map { |row| row.map(&:to_i) }
                        .reduce([]) do |memo, row|
                          day = row[0]
                          first_and_second_puzzles = row[1]
                          first_puzzle_only = row[2]
                          memo[day] = {
                            finished_first_puzzle: first_and_second_puzzles + first_puzzle_only,
                            finished_second_puzzle: first_and_second_puzzles,
                          }
                          memo
                        end

# https://adventofcode.com/2023/leaderboard/self
personal_times = '''
 18       >24h   31968      0          -       -      -
 16   01:34:54    5101      0   02:34:10    5977      0
 15   00:38:27    7039      0   01:18:24    6049      0
 14   00:48:40    6186      0   02:43:15    6018      0
 13   02:17:16    7779      0   04:40:18    9029      0
 12   01:16:31    5123      0   06:16:55    5574      0
 11   00:51:00    6277      0   01:19:12    6548      0
 10   02:39:27    9273      0   04:15:31    5685      0
  9   01:34:30   10693      0   01:39:37   10290      0
  8   00:42:08    9644      0   02:37:09   10514      0
  7   02:32:10   13683      0   03:04:53   11794      0
  6   02:06:53   17724      0   02:18:10   17369      0
  5   01:53:44   12749      0   05:50:22   11895      0
  4   01:17:34   16043      0   02:29:14   16723      0
  3   02:16:06   12883      0   03:21:56   13028      0
  2   16:54:40   86360      0   21:24:11   91148      0
  1       >24h  149845      0       >24h  108713      0
'''.lines
   .map(&:chomp)
   .reject { |line| line.empty? }
   .map(&:split)
   .map { |row| [row[0], row[2], row[5]] }
   .map { |row| row.map(&:to_i) }
   .map do |day, my_first_puzzle_rank, my_second_puzzle_rank|
     total_first_puzzle = overall_stats[day][:finished_first_puzzle]
     total_second_puzzle = overall_stats[day][:finished_second_puzzle]
     [
       day,
       '',
       my_first_puzzle_rank.positive? ? my_first_puzzle_rank : '',
       total_first_puzzle,
       my_first_puzzle_rank.positive? ? ((1.0 - (my_first_puzzle_rank.to_f / total_first_puzzle)) * 100).to_i : '0',
       '',
       my_second_puzzle_rank.positive? ? my_second_puzzle_rank : '',
       total_second_puzzle,
       my_second_puzzle_rank.positive? ? ((1.0 - (my_second_puzzle_rank.to_f / total_second_puzzle)) * 100).to_i : '0',
     ]
   end

File.open('stats.csv', 'w', 0644) do |f|
  f.puts 'Day,,Part 1 Rank,Part 1 Total,Part 1 Percentile,,Part 2 Rank,Part 2 Total,Part 2 Percentile'
  personal_times.each do |row|
    f.puts row.join(',')
  end
end

File.open('stats.md', 'w', 0644) do |f|
  f.puts '| Day |  | Part 1 Rank | Part 1 Total | Part 1 Percentile |  | Part 2 Rank | Part 2 Total | Part 2 Percentile |'
  f.puts '|:---:|--|:-----------:|:------------:|:-----------------:|--|:-----------:|:------------:|:-----------------:|'
  personal_times.each do |row|
    row[0] = format('[%d](day%02d)', row[0], row[0])
    f.puts '| ' + row.join(' | ') + ' |'
  end
end
