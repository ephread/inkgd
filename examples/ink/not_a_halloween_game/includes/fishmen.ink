

== fishman1
#showdialog
Fishbert: Hey, do you mind if we hang around for a while?
+ [Why not?] -> freindly
+ Go [Away!] back to the depths from whence you came!
    -> hostile

= freindly
Fishbert: Radical! Thanks dude.
Fishbert: Hey is that Loretta witch bothering you?
+ Very Much
+ Yes
+ Wow is she ever 
+ Who isn't bothered by her?
-
Fishbert: That's what I thought. She's been a pain in our fins:
Fishbert: Do this, destroy that, come on land. Wow, demanding much?
Fishbert: We'll take care of her for ya.
(destroy hotel cutscene) #hidedialog #cutscene:destroy_hotel  #contshowdialog:5
#fadetoblack
-> freindly_consequence

= freindly_consequence
#music:stranded
Bob: You don't mind if I crash on your couch for a while?
+ No not at all
    Bob: Great. All my stuff was in that hotel, but at least I'm free of that witch.
    And the town is safe.
    (Good End)
+ Wow, I don't really have a big apartment... 
    Don't be a jerk, player 
    -> freindly_consequence
    -
- -> credits

= hostile
#music:stranded
Fishbert: Wow, what a jerk.
(destroy town cutscene) #hidedialog #cutscene:destroy_town  #contshowdialog:7
Bob: Let's get out of this town! #showdialog #fadetoblack
I guess we'll grab the last boat out of here and part ways...
(Bad End)
-> credits