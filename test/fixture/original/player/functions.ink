EXTERNAL external_function(count)

-> start

=== function external_function(count) ===
    ~ return count + 3

=== function the_function(count) ===
    Hello World!
    ~ return count + 4

=== start ===
The count is {external_function(4)}
-> END

