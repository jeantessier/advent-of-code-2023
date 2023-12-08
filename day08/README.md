# Day 08

Part 1 was straightforward, but I was afraid my simple solution might not
terminate.

That was the case for Part 2.  Instead of working through all paths in parallel
until they all terminate, I had to work each one individually and then look for
commonalities.

I kept running each one 5 times past its terminal node to the next one, to look
for patterns.  I was lucky that they each returned to the same exact terminal
node in exactly as many steps.  Once I had a cycle length for each path, I
multiplied them together and got my first answer for Part 2.  It was too large,
though.

All the path lengths are not strictly prime to each other.  They have one or
more common factors that I would need to identify so I could remove them.
Ruby's `prime` library to the rescue!!  (But only after I had scratched my head
for some time trying to remember how to factorize.)
Each path length was a prime multiple of `293`.

    AAA --> ZZZ: 17873 = 61 x 293
    QRA --> XVZ: 19631 = 67 x 293
    KQA --> QQZ: 17287 = 59 x 293
    DFA --> VGZ: 12599 = 43 x 293
    DBA --> PPZ: 21389 = 73 x 293
    HJA --> QFZ: 20803 = 71 x 293

The answer is `61 x 67 x 59 x 43 x 73 x 71 x 293`.

I calculated it using a calculator and submitted the answer.  Then, I spent some
more time automating the common factor extraction.
