#!/usr/bin/env ruby

#
# Prints my stats as a CSV
#
#     ./stats.rb > stats.csv
#

overall_stats = '''
10   19049  14908  ******
9   52273    769  *********
8   55152  11519  ***********
7   63682   5719  ***********
6   82682   1363  **************
5   65278  25622  **************
4  108276  14385  ********************
3  109751  16353  ********************
2  167050   7509  ****************************
1  199347  63091  *****************************************
'''.lines
   .map(&:chomp)
   .reject {|line| line.empty?}
   .map(&:split)
   .map {|row| row[0..2]}
   .map {|row| row.map(&:to_i)}
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

personal_times = '''
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
   .reject {|line| line.empty?}
   .map(&:split)
   .map {|row| [row[0], row[2], row[5]]}
   .map {|row| row.map(&:to_i)}
   .map do |row|
      day = row[0]
      my_first_puzzle_rank = row[1]
      total_first_puzzle = overall_stats[row[0]][:finished_first_puzzle]
      my_second_puzzle_rank = row[2]
      total_second_puzzle = overall_stats[row[0]][:finished_second_puzzle]
      [
        day,
        '',
        my_first_puzzle_rank,
        total_first_puzzle,
        (my_first_puzzle_rank.to_f / total_first_puzzle).round(3),
        '',
        my_second_puzzle_rank,
        total_second_puzzle,
        (my_second_puzzle_rank.to_f / total_second_puzzle).round(3),
      ]
   end

puts "Day,,Part 1 Rank,Part 1 Total,Part 1 Percentile,,Part 2 Rank,Part 2 Total,Part 2 Percentile"
personal_times.each do |row|
  puts row.join(',')
end
