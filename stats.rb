#!/usr/bin/env ruby

#
# Prints my stats as a CSV
#
#     ./stats.rb > stats.csv
#

overall_stats = '''
25   12028   3257  ***
24   13453   5325  ***
23   16186   3117  ***
22   17425   1070  ****
21   15838  10767  ****
20   20059   4654  ****
19   24443   7588  ****
18   26806   5132  *****
17   26023   1212  *****
16   37801   1141  ******
15   43521   4651  *******
14   38879   8059  ******
13   40639   5616  ******
12   33339  15201  ******
11   60912   2637  *********
10   51338  18330  **********
 9   81271   1484  ***********
 8   78560  15963  ************
 7   86822   8062  ************
 6  109642   2230  **************
 5   85087  33494  ***************
 4  138805  19486  ********************
 3  139538  22313  ********************
 2  212558  10995  ****************************
 1  251147  86222  *****************************************
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
        ((1.0 - (my_first_puzzle_rank.to_f / total_first_puzzle)) * 100).to_i,
        '',
        my_second_puzzle_rank,
        total_second_puzzle,
        ((1.0 - (my_second_puzzle_rank.to_f / total_second_puzzle)) * 100).to_i,
      ]
   end

puts "Day,,Part 1 Rank,Part 1 Total,Part 1 Percentile,,Part 2 Rank,Part 2 Total,Part 2 Percentile"
personal_times.each do |row|
  puts row.join(',')
end
