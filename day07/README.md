# Day 07

I split the logic into `Hand` and `Card` Ruby classes.  This way, I can specify
the ordering of cards in the `Card` class and determine the type of hand in the
`Hand` class.

Part 2 changes both the card ordering and the determination of the type of hand.
So, I had to change both the `Hand` and `Card` classes.  I guess I could have
used the Strategy pattern and externalized card ordering and how to calculate
the type of hand.  That might have been over-engineering.
