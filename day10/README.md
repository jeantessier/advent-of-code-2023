# Day 10

For Part 1, I first tried to follow the pipe using recursion.  It exhausted the
stack.  I replaced the recursion with a `while` loop and that did the trick.  It
felt a little dirty to use a `while` loop.

For Part 2, I first cleaned the map of everything that was not part of the pipe.
Then, I realized pretty quickly that when moving from the edge of the map to a
piece of open terrain, each time I crossed the pipe I flipped between enclosed
and not enclosed.  So, it was just a matter of counting how many times I crossed
the pipe for any given piece of open terrain.  I went horizontally at first and
counted `|` characters.  But I had to account for segments of the pipe going
that went horizontally for a bit, too.  Ignoring `-` segments, I just looked for
`/F-*J/` and `/L-*7/` patterns in addition to `|`.  If the number was odd, the
piece of open terrain was enclosed.

If checking horizontally, count `/F-*J/`, `/L-*7/` patterns, and `|` characters
between a given position and the left or right edge of the map.

If checking vertically, count `/F\|*J/`, `/7\|*L/` patterns, and `-` characters
between a given position and the top or bottom edge of the map.

I stored the map as a list of rows, so it was easier for me to check
horizontally.
