# Day 13

I gathered some stats about the input: 100 patterns, none bigger than 100 x 100.
I should be able to brute force my way through.

Finding horizontal mirrors was simple enough: compare groups of lines.  Finding
vertical mirrors was a little more tricky.  I had to build regexes to tease out
possible mirror positions and find cases where all rows matched a given regex.

Part 1 showed that patterns had at most one horizontal and at most one vertical
mirror each.  I didn't check for "both" or "neither" cases.

For Part 2, I generated all possible variations of each pattern.  I had to
reread the problem a few times to understand they only wanted the **new**
mirrors.  I still double-checked that all variations of a pattern that
introduced a new mirror for that pattern all introduced the same new mirror.  It
looks like each pattern either had one new horizontal mirror or one new vertical
mirror.  I didn't see any "both" nor "neither".
