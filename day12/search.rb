#!/usr/bin/env ruby

def test(label, expected, actual)
  if expected == actual
    puts "OK  : " + label
    # puts ""
  else
    puts "FAIL: #{label} expected #{expected} but was #{actual}"
    # puts ""
  end
end

CACHE = {}

def search(s, criteria, indent = 0)
  puts "#{'  ' * indent}search(\"#{s}\", #{criteria})"

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
  puts "#{'  ' * indent}search(\"#{s}\", #{criteria}) --> #{count}"
  count
end

# test "empty string", 0, search("", [1])
# test "all '.' string", 0, search("...", [1])
# test "specific", 1, search("#", [1])
# test "with leading/trailing '.'", 1, search("..#..", [1])
# test "open", 1, search("?", [1])
# test "specific", 1, search("?#?", [1])
# test "two wildcards", 2, search("??", [1])
#
# test "two in four", 3, search("????", [2])
# test "two in four w/ anchor", 2, search("?#??", [2])
#
# test "contiguous", 1, search(".#####.", [5])
# test "criteria too small", 0, search(".#####.", [4])
# test "criteria too big", 0, search(".#####.", [6])
#
# test "???.###", 1, search("???.###", [1, 1, 3])
# test ".??..??...?##.", 4, search(".??..??...?##.", [1, 1, 3])
# test "?#?#?#?#?#?#?#?", 1, search("?#?#?#?#?#?#?#?", [1, 3, 1, 6])
# test "????.#...#...", 1, search("????.#...#...", [4, 1, 1])
# test "????.######..#####.", 4, search("????.######..#####.", [1, 6, 5])
# test "?###????????", 10, search("?###????????", [3, 2, 1])
#
# test "???.###????.###????.###????.###????.###", 1, search("???.###????.###????.###????.###????.###", [1, 1, 3, 1, 1, 3, 1, 1, 3, 1, 1, 3, 1, 1, 3])
# test ".??..??...?##.?.??..??...?##.?.??..??...?##.?.??..??...?##.?.??..??...?##.", 16_384, search(".??..??...?##.?.??..??...?##.?.??..??...?##.?.??..??...?##.?.??..??...?##.", [1, 1, 3, 1, 1, 3, 1, 1, 3, 1, 1, 3, 1, 1, 3])
# test "?#?#?#?#?#?#?#???#?#?#?#?#?#?#???#?#?#?#?#?#?#???#?#?#?#?#?#?#???#?#?#?#?#?#?#?", 1, search("?#?#?#?#?#?#?#???#?#?#?#?#?#?#???#?#?#?#?#?#?#???#?#?#?#?#?#?#???#?#?#?#?#?#?#?", [1, 3, 1, 6, 1, 3, 1, 6, 1, 3, 1, 6, 1, 3, 1, 6, 1, 3, 1, 6])
# test "????.#...#...?????.#...#...?????.#...#...?????.#...#...?????.#...#...", 16, search("????.#...#...?????.#...#...?????.#...#...?????.#...#...?????.#...#...", [4, 1, 1, 4, 1, 1, 4, 1, 1, 4, 1, 1, 4, 1, 1])
# test "????.######..#####.?????.######..#####.?????.######..#####.?????.######..#####.?????.######..#####.", 2_500, search("????.######..#####.?????.######..#####.?????.######..#####.?????.######..#####.?????.######..#####.", [1, 6, 5, 1, 6, 5, 1, 6, 5, 1, 6, 5, 1, 6, 5])
# test "?###??????????###??????????###??????????###??????????###????????", 506_250, search("?###??????????###??????????###??????????###??????????###????????", [3, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2, 1, 3, 2, 1])
#
# test ".?.??..??...?##.", 8, search(".?.??..??...?##.", [1, 1, 3])
# test "..??...?##.", 1, search("..??...?##.", [3])

# test "?#???.#??#?????.?", 12, search("?#???.#??#?????.?", [3, 1, 3, 1, 1])
# test "?.?", 2, search("?.?", [1])

test "?.#??#??.??????.???.#??#??.??????.???.#??#??.??????.???.#??#??.??????.???.#??#??.??????.?", -1, search("?.#??#??.??????.???.#??#??.??????.???.#??#??.??????.???.#??#??.??????.???.#??#??.??????.?", [6, 1, 1, 1, 6, 1, 1, 1, 6, 1, 1, 1, 6, 1, 1, 1, 6, 1, 1, 1])
