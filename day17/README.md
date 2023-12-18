# Day 17

Part 1 won over me.  I struggled with it all through the night and the better
part of the next day.  No matter what I tried, I couldn't get it to go anywhere
near a solution.  I read on Dijkstra.  I read comments from other people who
hinted that they found solutions.  But it kept eluding me.

Jean has a problem. Jean used regular expressions.  Now, Jean has two problems.
I recorded the path that the algorithm was exploring as strings of `d` (down),
`u` (up), `r` (right), and `l` (left).  When looking for where I could go next
from a given position, I used regex agaisnt the tail of that string.  For
example, if I'm considering goind _down_, I want to make sure I don't already
have three `d`'s in a row.  The regex for this is `/ddd$/`, where the `$` stands
for the end of the string.  As an optimization, I also want to make sure I'm not
backtracking from having just gone up.  The regex for this is `/u$/`.

I'm smart, so I combined them into `/(ddd)|u$/` to check them together in a
single call.  I read it as "ends either in `ddd` or `u`."  But I was wrong.  It
actually reads as "either contains `ddd` or ends in `u`."

The correct regex is `/((ddd)|u)$/`.  Times four for the others directions.

With this simple fix, I was able to run against the sample input successfully in
under 700 milliseconds.  The real input will take a few hours to work through.

I tried switching to a `Heap` (from the
[`rb_heap`](https://rubygems.org/gems/rb_heap) gem) to store candidates instead
of sorting an array every time.  It accelerated the run against the sample data
from 682 ms down to 462 ms.  I suspect `Array#sort` is `O(n log n)` or worse.
The `Heap` should be able to inser in `O(log n)` and keep its contents sorted.

I need to use Bundle to run the puzzle.

```bash
bundle install # first time only
bundle exec ./puzzle1.rb
```
