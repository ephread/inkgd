

== totem1
#showdialog
{ 
    - bob.chase: -> talk_to
    - else:
        That's strange, I wonder what this thing is? 
        -> explore_map
}

= talk_to
#showdialog
{ 
    - totem2:
        {totem2.defeat: Hey now, if you thought the other one was hard, watch out for me! Dare you? | Scared of us? Want to try me? }
    - else:
        {totem1.wrong: Hahaha back for more?} Do you dare disturb me?
}
+ [Sure do] 
+ [No, sorry, nevermind] -> explore_map
-

The key to my defeat are these riddles 3:

Susan and Terence are dead on the ground. They are naked and wet, but there are no cuts or bruises on them. It is stormy tonight. How did they die?
* Struck by lightning -> wrong
* Poisoned -> wrong
* Drowned -> wrong
+ They're fish
-
{{~Great job!|Very good.|Not much of a challenge}|You knew that one.}

It is a small treasure chest found within sands, what lies inside?
* Dubloons -> wrong
+ A pearl
* Sand dollar -> wrong
* My uncle’s wallet -> wrong
-
{{~Great job!|Very good.|Not much of a challenge}|You knew that one.}

You grow it real young. The witch has a big one. It’s a cavernous place, but I’d not be without one. What is it? 
* Ears -> wrong
* Garden -> wrong
* Puppy -> wrong
+ Nose
-
{{~Great job!|Very good.|Not much of a challenge}|You knew that one.}

-> defeat

= defeat
No! How could you! #defeat:totem1 
{totem2.defeat: -> bob.last_totem }

-> explore_map

= wrong
Go away kid, come back when you're serious about word-play and lateral thinking.

-> explore_map