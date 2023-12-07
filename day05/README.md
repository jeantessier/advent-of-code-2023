# Day 05

My initial, na&iuml;ve approach was to build conversion tables for each
conversion as a `Hash` with a default function that's the identity function.
This worked well with the training sample, but the real data had _massive_
ranges and it took too long to fill the conversion tables, let alone doing any
work on the problem itself.

My second approach was to store the conversion rules.  These hashes had an input
range for a key and a conversion function for a value.  With these, I was able
to work through the small range of initial data in Part 1.

Part 2 has _massive_ ranges of initial data, so I had to change my approach
again.  Since all ranges are contiguous and in increasing order, I could take an
input range and map it wholesale.  I had to take care of the input range spanned
more than one conversion rule and break it up accordingly.

For example:

```
input:  |----------------------------------------|
rules:       |---|       |-----------|        |-------|
result: |----|---|-------|-----------|--------|--|
```

> An initial range spans three conversion rules, with identity for the gaps.
> Converting this one input range results in 6 resulting ranges in the
> destination conversion.

I start with a initial set of ranges and each time I apply a conversion, this
set of ranges is transformed into another set of ranges.  There may be more
ranges in the new set, but the number of keys covered by all the ranges remains
the same.

Rinse, lathe, repeat.

Once I have the final set of ranges in the `location` space, I can take the
smallest starting point from these ranges and that's my answer.

Execution time (in Ruby): `150 ms`
