VAR aBoolean = false
VAR aString = "Hello"
VAR anInteger = 3
VAR aFloat = 4.3
VAR aDivert = -> aKnot

-> aKnot

=== aKnot ===
aBoolean = true
aString = "Bye"
anInteger = 2
aFloat = 1.2
aDivert = -> otherKnot

-> aDivert

=== otherKnot ===
aBoolean = true
aString = "Bye"
anInteger = 2
aFloat = 1.2
aDivert = -> aKnot

-> DONE