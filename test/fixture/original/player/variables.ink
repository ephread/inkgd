VAR aBoolean = false
VAR aString = "Hello"
VAR anInteger = 3
VAR aFloat = 4.3
VAR aDivert = -> aKnot

-> aKnot

=== aKnot ===

Hello World!

+ Choice 1
    Goodbye
+ Choice 2
    ~ aBoolean = true
    ~ aString = "Goodbye"
    ~ anInteger = 0
    ~ aFloat = 1.2
    ~ aDivert = -> otherKnot
    Goodbye

- -> aDivert

-> DONE

=== otherKnot ===

~ aBoolean = false
~ aString = "Why?"
~ anInteger = 6
~ aFloat = 8.5
~ aDivert = -> aKnot

Other Knot

-> DONE