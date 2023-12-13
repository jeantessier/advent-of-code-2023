# Day 12

For Part 1, I every possible combination of arrangements based on wildcards and
matched them against regexes representing the groups.  Brute force, but worked
with the puzzle input in ~18 seconds.

This wouldn't do for Part 2.  The combinatorial explosion of the expanded
arrangements and groups ruled out my initial approach.  I worked through the
groups, trying to match the first one to the head of the arrangement and
recursively matching the other groups to the rest of the string, then trying
again one character further in the arrangement, and so on.

I got it to return the correct answer with the sample input.  I also ran it
against the Part 1 problem.  This pointed out some needed minor adjustments.  It
was much faster.  But still a slug when applied to the Part 2 problem.

I looked at the trace of an example and noticed **a lot** of repeat processing.
I put in a cache and it ran in 4 seconds.  I should have caught that earlier.

I initially wrote some tests for the `#search` function using a bespoke test
function.  After I was done with the puzzle, I migrated these tests to RSpec.
You can run them with:

```bash
./bin/rspec search_tests.rb
```

Or see the full list of tests with:

```bash
./bin/rspec --format documentation search_tests.rb
```

> You may need to install RSpec with:
> 
> ```bash
> bundle install
> bundle binstubs --all
> ```
