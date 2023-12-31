# Day 16

For Part 1, I build a simulator that maintains a list of beams in progress.  It
picks a beam from the list, figures out where it will go next, adds it to the
grid and adds zero, one, or two next cells to the list of beams in progress.
Each cell remembers what beams are traversing it.  It will not add the same beam
direction twice, so beams stop moving when they double upon themselves or run
off the edge of the grid.

For Part 2, I debated resetting the grid between each starting position.  This
seemed tedious.  I figured I could track light beams from different starting
positions by giving them different "wavelengths" and making sure two beams with
different wavelengths didn't interfere with one another.  This way, I could run
the simulation only once with all starting positions at the same time.

Each cell in the grid maintains a list of beams going through it.  Each beam has
itw own wavelength.  Each operation filters that list by a given wavelength each
time it is called.  This means we do **a lot** of filtering.

Part 2 ran in 2 minutes and 1 second.

It might be faster to track each wavelength separately, in a hash of arrays in
each cell, so we wouldn't have to do so much filtering.  It ran in 8,261 ms.
That's a 15x improvement.

It's possible it could be even faster to simply reset the grid between each
starting position.  I tried it in `puzzle2_lazy.rb`.  It even shows a histogram
of how may starting positions result in a give number of energized cells.  It
ran in 3,758 ms.  That's a further 2x improvement.
