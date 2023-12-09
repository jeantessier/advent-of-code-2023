# Day 09

A nice easy one.  After parsing each "history", I can use `#reduce` to calculate
the next level and recursively call myself on it.  The recursion ends when the
input is all zeroes, at which point it simply adds one more zero.  As the
recursion unwinds, I compute the next value in Part 1 or the previous value in
Part 2.  At the end, I can extract the last values (Part 1) or first values
(Part 2) and sum them up.
