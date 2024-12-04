# Day 18

I'm trying this a year later, as I'm waiting for the next entry in the next
Advent of Code.

## Puzzle 1

First, I create 2D coordinates by following directions and creating waypoints
along the way.  These waypoints draw a path that ends the same place it started.

A first naive implementation worked well on the sample, but crashed on the real
input.  The sample works well if you start at the origin `(0, 0)` and follow
directions from there.  In the sample, all coordinates stay positive and I can
use them in an array of arrays.  In the real input, we start by doing left, in
the realm of negative coordinates, and I cannot use them as indices in arrays
anymore.

So, I figure out the top left corner of the coordinate system using
`path.map(&:x).min` and `path.map(&:y).min`, and translate everything to the
positive quadrant.

Now, I need to figure out what's inside the path from what's outside of it.
The shape from the real input is very convoluted.

- I tried counting crossing trenches from the left edge, but there were too many 
  odd cases.
- I tried marking the outside, starting from the outer edge and working my way
  in, but there are shadow areas that would require multiple passes.
- I tried marking the outside again, but then marking all neighbors as well.
  This one used recursion to follow outside cells and quickly blew up the stack.

In the end, I was able to get the multi-pass version to get me the correct
answer.  It only took 48 passes before it had marked all the outside and could
calculate the area inside the path.

I discarded the color information for Puzzle 1.

## Puzzle 2

The coordinate space is just insane.  The x-axis is `0..19005278` and the y-axis
is `0..11776214`.  That's a map of 223,810,251,638,985 cells, at least 203 PB.
The graphic approach I took in Puzzle 1 will not work here.
