# Day 11

In Part 1, silly me actually expanded the map for account for empty rows and
columns.  The distance between any pair of galaxies was just the cartesian
distance.

I could compare every galaxy to every galaxy.  This would include calculating
the distance of a galaxy to itself, but that's 0 and it does not affect the
answer in the end.  It does mean that for galaxies A and B, I calculated the
distances A-to-B and B-to-A.  So, I had to divide the final tally by 2 to remove
these duplicate distances.

In Part 2, I didn't even try to expand the map by millions of rows and columns.
I found the indices of the empty rows and the empty columns.  Then, as I
calculated the distance between any two galaxies, I created `row_range` and
`col_range` based on their coordinates, and added `EXPANSION_FACTOR` for each
empty row that was in `row_range` and each empty column that was in `col_range`.
With this setup, I was able to validate the test data by changing the expansion
factor to 2 or 10 or 100.  When I was happy that it worked correctly on the
sample, I set the expansion factor to 1,000,000 and got the answer on the first
try.
