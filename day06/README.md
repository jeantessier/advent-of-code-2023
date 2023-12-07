# Day 6

The distance covered in races follow a quadratic function.  For a race of `n`
milliseconds, if you hold the buttons for `x` milliseconds, your boat will go a
distance of `(n-x) * x` millimeters.

    f(x) = (n-x) * x
         = -1 * x**2 + n * x

If we are looking to beat a distance `d`, we look for `f(x) > d`.

    f(x) > d => f(x) - d > 0
             => -1 * x**2 + n * x - d > 0

This is the quadratic function `ax^2 + bx + c` where:

    a is -1
    b is n (the time limit for the race)
    c is -d (the distance record to beat)

We can find the roots of this quadratic function using the quadratic formula:

    -b +/- sqrt(b^2 - 4ac)
    ----------------------
            2a

We need to beat the record, so we can find the two integers that are greater
than each roots and count the integers in that range.
