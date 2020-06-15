// Character variables. We track just two, using a +/- scale
VAR forceful = 0
VAR evasive = 0


// Inventory Items
VAR teacup = false
VAR gotcomponent = false


// Story states: these can be done using read counts of knots; or functions that collect up more complex logic; or variables
VAR drugged = false
VAR hooper_mentioned = false

VAR losttemper = false
VAR admitblackmail = false

// what kind of clue did we pass to Hooper?
CONST NONE = 0
CONST STRAIGHT = 1
CONST CHESS = 2
CONST CROSSWORD = 3
VAR hooperClueType = NONE

VAR hooperConfessed = false

CONST SHOE = 1
CONST BUCKET = 2
VAR smashingWindowItem = NONE

VAR notraitor = false
VAR revealedhooperasculprit = false
VAR smashedglass = false
VAR muddyshoes = false

VAR framedhooper = false

// What did you do with the component?
VAR putcomponentintent = false
VAR throwncomponentaway = false
VAR piecereturned = false
VAR longgrasshooperframe = false


// DEBUG mode adds a few shortcuts - remember to set to false in release!
VAR DEBUG = false

-> start

/*--------------------------------------------------------------------------------

	Start the story!

--------------------------------------------------------------------------------*/

=== start ===

//  Intro
	- 	They are keeping me waiting.
		*	Hut 14[]. The door was locked after I sat down.
		I don't even have a pen to do any work. There's a copy of the morning's intercept in my pocket, but staring at the jumbled letters will only drive me mad.
		I am not a machine, whatever they say about me.
		-> END