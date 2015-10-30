; ===========================
; ===========================
; ===== CHREST Tileword =====
; ===========================
; ===========================
; by Martyn Lloyd-Kelly
;
; - Thinking unit times have not been implemented since problem-solving and pattern-recognition times do the job.
;   However, it may be worth reconsidering this if the complexity of a thought process needs to be accurately
;   modelled.  In this case, the problem-solving and pattern-recognition times for a CHREST turtle could act as
;   "base" times and the added time spent deliberating is added to the base time.
;
;TODO: Set this up "chrest-turtles-act" that not planning agents act in the way they did for ICAART paper (remember 
;      to check that the code that caused the bug last time has been fixed).
;TODO: Since CHREST turtle's problem-solving is now very simple, it may choose to move-randomly but only because a
;      tile can not be seen.  Therefore, it would be beneficial to some extent for the turtle to associate actions
;      and visions whereas at the moment, it can not.
;TODO: Extract test procedures into Netlogo extension.
;TODO: Implement 'action-performance-time' usage.  Currently, actions have no time-cost associated with performance.
;TODO: Should generating the current visual pattern incur a time cost (could be used to manipulate "talent")?
;TODO: Extract action-pattern creation into independent procedures so code is DRY.
;TODO: Ensure that all procedures have a description.
;TODO: Save any code fragments that are run more than once in a procedure for the purposes of outputting something to
;      a debug message as well as to do something in the procedure since this will speed-up execution time slightly.
;TODO: Remove most of the hard-coded global variable values.  A lot of them should be able to be specified by the user.
;TODO: Implement functionality to restrict users from specifying certain global/turtle variable values at start of sim.
;      e.g. the "generate-action-using-heuristics" turtle variable should only be set programatically, not by the user.
;CONSID: Implement areas that are "sticky", "normal" or "smooth".  These areas should cause tile movement to be slowed-down
;        or sped-up.  Adds another degree of planning that may be interesting when performing experiments with the 
;        visual-spatial field.

;******************************************;
;******************************************;
;********* EXTENSION DECLARATIONS *********;
;******************************************;
;******************************************;

extensions [
  chrest
  extras
  pathdir 
  string 
]

;**************************************;
;**************************************;
;********* BREED DECLARATIONS *********;
;**************************************;
;**************************************;

breed [ chrest-turtles ]
breed [ tiles ]
breed [ holes ]

;*****************************************;
;*****************************************;
;********* VARIABLE DECLARATIONS *********;
;*****************************************;
;*****************************************;

globals [
  blind-patch-token              ;Stores the string used to denote a blind patch in a CHREST turtle's visual-spatial field.
  breeds                         ;Stores the names of turtle breeds (not automatically updated).
  current-game-time              ;Stores the length of time (in milliseconds) that the non-training game has run for.
  current-repeat-number          ;Stores the current repeat number.
  current-scenario-number        ;Stores the current scenario number.
  current-training-time          ;Stores the length of time (in milliseconds) that the training game has run for.
  debug-indent-level             ;Stores the current indent level (3 spaces per indent) for debug messages.
  debug-message-output-file      ;Stores the location where debug messages should be written to.
  directory-separator            ;Stores the directory separator for the operating system the model is being run on.
  empty-patch-token              ;Stores the string used to indicate an empty patch (patch that contains no visible turtles) in scene instances.
  hole-born-every                ;Stores the length of time (in milliseconds) that must pass before a hole may possibly be created.
  hole-birth-prob                ;Stores the probability that a hole will be created on each tick in the game.
  hole-lifespan                  ;Stores the length of time (in milliseconds) that a hole lives for after creation. 
  hole-token                     ;Stores the string used to indicate a hole in scene instances.
  move-token                     ;Stores the string used to indicate that the calling turtle should move in a direction in action-patterns.
  movement-headings              ;Stores headings that agents can move along.
  move-around-tile-token         ;Stores the string used to indicate that the calling turtle moved around a tile in action-patterns.
  move-to-tile-token             ;Stores the string used to indicate that the calling turtle moved to a tile in action-patterns.
  ;output-interval                ;Stores the interval of time that must pass before data is output to the model's output area.
  possible-actions               ;Stores a list of action identifier strings.  If adding a new action, include its identifier in this list.
  problem-solving-token          ;Stores the string used to indicate that a turtle used problem-solving to select an action.
  push-tile-token                ;Stores the string used to indicate that the calling turtle pushed a tile in action-patterns.
  reward-value                   ;Stores the value awarded to turtles when they push a tile into a hole.
  save-interface?                ;Stores a boolean value that indicates whether the user wishes to save an image of the interface when running the model.
  save-output-data?              ;Stores a boolean value that indicates whether the user wishes to save output data when running the model.
  save-training-data?            ;Stores a boolean value that indicates whether or not data should be saved when training completes.
  save-world-data?               ;Stores a boolean value that indicates whether the user wishes to save world data when running the model.
  opponent-token                 ;Stores the string used to indicate an opponent in scene instances.
  procedure-not-applicable-token ;Stores the string used to indicate that the procedure called during deliberation is not applicable given the current observable environment.
  self-token                     ;Stores the string used to indicate the turtle that generates a scene instance.
  setup-and-results-directory    ;Stores the directory that simulation setups are to be input from and results are to be output to.
  testing?                       ;Stores a boolean value that indicates whether the model is being executed in a training context or not.
  testing-debug-messages         ;Stores a string composed of all debug messages output when tests are run.
  test-info                      ;Stores a list delineating the type of test, name of the test and number of the named test being run/last run.
  tile-born-every                ;Stores the length of time (in milliseconds) that must pass before a tile may possibly be created.
  tile-birth-prob                ;Stores the probability that a tile will be created on each tick in the game.
  tile-lifespan                  ;Stores the length of time (in milliseconds) that a tile lives for after creation.
  tile-token                     ;Stores the string used to indicate a tile in scene instances.
  training?                      ;Stores boolean true or false: true if the game is a training game, false if not (true by default).
  unknown-patch-token            ;Stores the string used to indicate an unknown patch (patch whose object status is unknown) for Scene instances created from a CHREST turtle's VisualSpatialField instance.
]
     
chrest-turtles-own [ 
  action-performance-time                               ;Stores the length of time (in milliseconds) that it takes to perform an action.
  action-selection-procedure                            ;Stores the name of the action-selection procedure that should be used to select an action after pattern-recognition.
  add-link-time                                         ;Stores the length of time (in milliseconds) that it takes to add a link between two nodes in LTM.
  can-plan?                                             ;Stores a boolean value that indicates whether the turtle is capable of planning or not.
  chrest-instance                                       ;Stores an instance of the CHREST architecture.
  closest-tile                                          ;Stores an agentset consisting of the closest tile to the calling turtle when the 'next-to-tile' procedure is called.
  construct-visual-spatial-field?                       ;Stores a boolean value that indicates whether the turtle should instantiate a new visual-spatial field.
  current-scene                                         ;Stores an instance of jchrest.lib.Scene that represents the current scene.  Used by CHREST Netlogo extension.
  current-search-iteration                              ;Stores the number of search iterations the turtle has made in the current planning cycle.
  current-visual-pattern                                ;Stores the current visual pattern that has been generated as a string.
  deliberation-finished-time                            ;Stores the time (in milliseconds) that the CHREST turtle will finish deliberation on the current plan. Controls plan execution.
  discount-rate                                         ;Stores the discount rate used for the "profit-sharing-with-discount-rate" reinforcement learning algorithm.
  discrimination-time                                   ;Stores the length of time (in milliseconds) that it takes to discriminate a new node in LTM of the CHREST architecture.
  episodic-memory                                       ;Stores visual patterns generated, action patterns performed in response to that visual pattern, the time the action was performed and whether problem-solving was used to determine the action in a FIFO list data structure.
  familiarisation-time                                  ;Stores the length of time (in milliseconds) that it takes to familiarise a node in the LTM of the CHREST architecture.
  frequency-of-problem-solving                          ;Stores the total number of times problem-solving has been used to generate an action for the CHREST turtle.
  frequency-of-random-behaviour                         ;Stores the total number of times random action generation has been used to generate an action for the CHREST turtle.
  frequency-of-pattern-recognitions                     ;Stores the total number of times pattern recognition has been used to generate an action for the CHREST turtle.
  generate-plan?                                        ;Stores a boolean value that indicates whether the turtle should generate a plan.
  max-length-of-episodic-memory                         ;Stores the maximum length of the turtle's "episodic-memory" list.  
  max-search-iteration                                  ;Stores the maximum number of search iterations the turtle can make in any planning cycle.
  next-action-to-perform                                ;Stores the action-pattern that the turtle is to perform next.
  number-fixations                                      ;Stores the number of fixations the turtle should perform when learning/scanning the current scene.  Used by CHREST Netlogo extension. 
  pattern-recognition?                                  ;Stores a boolean value that indicates whether pattern-recognition can be used or not.
  plan                                                  ;Stores a series of moves generated using the current state of the visual-spatial field and heuristics that should be executed by the CHREST turtle.
  play-time                                             ;Stores the length of time (in milliseconds) that the turtle plays for after training.
  reinforce-actions?                                    ;Stores a boolean value that indicates whether CHREST turtles should reinforce links between visual patterns and actions.
  reinforce-problem-solving?                            ;Stores a boolean value that indicates whether CHREST turtles should reinforce links between visual patterns and use of problem-solving.
  reinforcement-learning-theory                         ;Stores the name of the reinforcement learning theory the CHREST turtle will use.
  score                                                 ;Stores the score of the agent (the number of holes that have been filled by the turtle).
  sight-radius                                          ;Stores the number of patches north, east, south and west that the turtle can see.
  sight-radius-colour                                   ;Stores the colour that the patches a CHREST turtle can see will be set to (used for debugging). 
  time-spent-deliberating-on-plan                       ;Stores the total amount of time spent deliberating on the current plan.
  time-taken-to-act-randomly                            ;Stores the length of time (in milliseconds) that it takes to select an action to perform randomly.
  time-taken-to-use-pattern-recognition                 ;Stores the length of time (in milliseconds) that it takes to perform pattern-recognition.
  time-to-perform-next-action                           ;Stores the time that the action-pattern stored in the "next-action-to-perform" turtle variable should be performed.
  time-taken-to-problem-solve                           ;Stores the length of time (in milliseconds) that it takes to select an action to perform using problem-solving.
  total-deliberation-time                               ;Stores the total time that it has taken for a CHREST turtle to select actions that should be performed.
  training-time                                         ;Stores the length of time (in milliseconds) that the turtle can train for.
  visual-spatial-field-access-time                      ;Stores the length of time (in milliseconds) that it takes to access the visual-spatial field.
  visual-spatial-field-empty-square-placement-time      ;Stores the length of time (in milliseconds) that it takes to place an empty square in the visual-spatial field during its construction.
  visual-spatial-field-object-movement-time             ;Stores the length of time (in milliseconds) that it takes to move an object in the visual-spatial field.
  visual-spatial-field-object-placement-time            ;Stores the length of time (in milliseconds) that it takes to place an object in the visual-spatial field during its construction.
  visual-spatial-field-recognised-object-lifespan       ;Stores the length of time (in milliseconds) that recognised objects "live" for in the visual-spatial field after having attention focused on them.
  visual-spatial-field-unrecognised-object-lifespan     ;Stores the length of time (in milliseconds) that unrecognised objects "live" for in the visual-spatial field after having attention focused on them.
  who-of-tile-last-pushed-in-plan                       ;Stores the who of the tile last pushed during planning.  Allows the turtle to "fixate" on this tile so that, if multiple tiles can be seen, 
                                                        ;planning will end when this tile is pushed out of the visual-spatial field or pushed into a hole.  Also, allows for preicise reversals of 
                                                        ;visual-spatial field moves that result in invalid visual-spatial field states.
]
    
tiles-own [ 
  time-to-live    ;Stores the time (in milliseconds) that a tile has left before it dies.
]
     
holes-own [ 
  time-to-live    ;Stores the time (in milliseconds) that a hole has left before it dies.
]

;******************************;
;******************************;
;********* PROCEDURES *********;
;******************************;
;******************************;
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "ADD-EPISODE-TO-EPISODIC-MEMORY" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;CHREST turtle-only procedure.
;
;Adds an episode to the calling turtle's "episodic-memory" list.  If the length of "episodic-memory" is
;at its maximum, the first (oldest) episode is removed and the new item added to the back of the list. 
;If the length of the "episodic-memory" list is less than the maximum length then the new item is added 
;to the back of the list.
;
;         Name              Data Type                  Description
;         ----              ---------                  -----------
;@param   visual-chunk      jchrest.lib.ListPattern    The visual part of the episode.
;@param   action-chunk      jchrest.lib.ListPattern    The action part of the episode.
;@param   pattern-rec-used  Boolean                    Whether action-chunk was generated using
;                                                      pattern-recognition or not.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to add-episode-to-episodic-memory [visual-chunk action-chunk pattern-rec-used]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'add-episode-to-episodic-memory' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  if(breed = chrest-turtles)[
  
    let rlt ("null")
    if(breed = chrest-turtles)[
      set rlt (chrest:get-reinforcement-learning-theory)
    ]
    
    output-debug-message (word "Checking to see if my reinforcement learning theory is set to 'null' (" rlt ").  If so, I won't continue with this procedure...") (who)
    if(rlt != "null")[
      
      output-debug-message (word "Before modification my 'episodic-memory' is set to: '" episodic-memory "'." ) (who)
      output-debug-message (word "Checking to see if the length of my 'episodic-memory' (" length episodic-memory ") is greater than or equal to the value specified for the 'max-length-of-episodic-memory' variable (" max-length-of-episodic-memory ")...") (who)
      if( (length (episodic-memory)) >= max-length-of-episodic-memory )[
        output-debug-message ("The length of the 'episodic-memory' list is greater than or equal to the value specified for the 'max-length-of-episodic-memory' variable...") (who)
        set episodic-memory (but-first episodic-memory)
        output-debug-message (word "After removing the first (oldest) item, my 'episodic-memory' is set to: '" episodic-memory "'." ) (who)
      ]
      
      let episode (list (visual-chunk) (action-chunk) (report-current-time) (pattern-rec-used))
      output-debug-message (word "Appending " (list (chrest:ListPattern.get-as-string (visual-chunk)) (chrest:ListPattern.get-as-string (action-chunk)) (report-current-time) (pattern-rec-used)) " as an episode to my 'episodic-memory'...") (who)
      set episodic-memory (lput (episode) (episodic-memory))
      output-debug-message (word "Final state of 'episodic-memory': '" episodic-memory "'.") (who)
    ]
  ]
  
  set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "AGE" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Decreases the "time-to-live" variable for all tiles and holes by the
;value specified in the "time-increment" variable. If a tile/hole's 
;"time-to-live" variable is <= 0 after the decrement, the tile/hole 
;dies.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to age
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'age' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  ask tiles [
    set time-to-live ( precision (time-to-live - 1) (1) )
    if(time-to-live <= 0)[
      die
    ]
  ]
  
  ask holes [
    set time-to-live ( precision (time-to-live - 1) (1) )
    if(time-to-live <= 0)[
      die
    ]
  ]
  
  set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "ALTER-HEADING-RANDOMLY-BY-ADDING-OR-SUBTRACTING-90" PROCEDURE ;;; - MAY NO LONGER BE NEEDED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Alters the value of the heading passed by non-deterministically adding 
;;or subtracting 90.  So, if the heading indicates:
;; - North (0): resultant heading will be west (270) or east (90).
;; - East (90): resultant heading will be north (0) or south (180).
;; - South (180): resultant heading will be east (90) or west (270).
;; - West (270): resultant heading will be south (180) or north (0).
;;
;;         Name              Data Type     Description
;;         ----              ---------     -----------
;;@param   current-heading   Number        The heading to be altered.
;;@return  -                 Number        The altered heading (see description above).
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to-report alter-heading-randomly-by-adding-or-subtracting-90 [current-heading]
;  set debug-indent-level (debug-indent-level + 1)
;  output-debug-message ("EXECUTING THE 'alter-heading-randomly-by-adding-or-subtracting-90' PROCEDURE...") ("")
;  set debug-indent-level (debug-indent-level + 1)
;  
;  output-debug-message (word "The heading to alter is: '" current-heading "'.") (who)
;  ifelse( (random 2) = 0)[
;    output-debug-message ("Altering current heading by adding 90.") (who)
;    set current-heading ( current-heading + 90 )
;  ]
;  [ 
;    output-debug-message ("Altering current heading by subtracting 90.") (who)
;    set current-heading ( current-heading - 90 )
;  ]
;  
;  output-debug-message (word "The heading after alteration is now set to: '" current-heading "'.") (who)
;  set debug-indent-level (debug-indent-level - 2)
;  report ( rectify-heading (current-heading) )
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "ANY-TILES-ON-PATCH-AHEAD?" PROCEDURE ;;; - THIS COULD BE REMOVED!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Reports boolean true or false depending upon whether or not there is a tile
;;on the patch immediately ahead of the calling turtle along its current heading.
;;
;;         Name              Data Type     Description
;;         ----              ---------     -----------
;;@returns -                 Boolean       True if there is a turtle whose 'breed'
;;                                         variable value is equal to 'tiles' on 
;;                                         the patch immediately ahead of the 
;;                                         calling turtle along its current heading.
;;                                         False is reported if not.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to-report any-tiles-on-patch-ahead?
;  set debug-indent-level (debug-indent-level + 1)
;  output-debug-message ("EXECUTING THE 'any-tiles-on-patch-ahead?' PROCEDURE...") ("")
;  set debug-indent-level (debug-indent-level + 1)
;  
;  output-debug-message(word "Checking to see if there are any tiles on the patch immediately ahead with heading: " heading "...") (who)
;  ifelse(any? tiles-on patch-at-heading-and-distance (heading) (1))[
;    output-debug-message(word "There are tiles on the patch immediately ahead with heading: " heading ".  Reporting true...") (who)
;    set debug-indent-level (debug-indent-level - 2)
;    report true
;  ]
;  [
;    output-debug-message(word "There aren't any tiles on the patch immediately ahead with heading: " heading ".  Reporting false...") (who)
;    set debug-indent-level (debug-indent-level - 2)
;    report false
;  ] 
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "CHECK-BOOLEAN-VARIABLES" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Checks that the turtle variable specified for the calling turtle has a
;boolean value set.  If this is not the case, an error is generated.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@param   turtle-id         Number        The value of the calling turtle's "who" turtle variable.
;@param   variable-name     String        The name of the calling turtle's variable to check.
;@param   variable-value    -             The value of the calling turtle's variable to check.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to check-boolean-variables [turtle-id variable-name variable-value]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'check-boolean-variables' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  output-debug-message (word "THE 'turtle-id' VARIABLE IS SET TO: '" "'.") ("")
  output-debug-message (word "THE 'variable-name' VARIABLE IS SET TO: '" variable-name "'.") ("")
  output-debug-message (word "THE 'variable-value' VARIABLE IS SET TO: '" variable-value "'.") ("")
  
  ;================================;
  ;== SET ERROR MESSAGE PREAMBLE ==;
  ;================================;
  
  output-debug-message ("SETTING THE 'error-message-preamble' VARIABLE...") ("")
  let error-message-preamble ""
  ifelse(turtle-id = "")[
    set error-message-preamble (word "The global '" variable-name "' variable value ")
  ]
  [
    set error-message-preamble (word "Turtle " turtle-id "'s '" variable-name "' variable value ")
  ]
  output-debug-message (word "THE 'error-message-preamble' VARIABLE IS SET TO: '" error-message-preamble "'.") ("")
  
  ;=============================================;
  ;== CHECK THAT VARIABLE HAS A BOOLEAN VALUE ==;
  ;=============================================;
  
  output-debug-message (word "CHECKING TO SEE IF '" variable-name "' HAS A BOOLEAN VALUE...") ("")
  if(not runresult (word "is-boolean? " variable-name ))[
    error (word error-message-preamble "does not have a boolean value (" variable-value ").  Please rectify.")
  ]
  output-debug-message (word "'" variable-name "' HAS A BOOLEAN VALUE...") ("")
  
  set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "CHECK-FOR-SCENARIO-REPEAT-DIRECTORY" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Checks that there is the following structure in the directory specified by the 
;value of the "setup-and-results-directory" variable if the "current-scenario-number" 
;and "current-repeat-number" variable values are set to 1, for example:
;
; - setup-and-results-directory
;   L Scenario1
;     L Repeat1
;
;If the directory structure specified does not exist then an error is thrown
;to alert the user.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to check-for-scenario-repeat-directory
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'check-for-scenario-repeat-directory' PROCEDURE") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  let directory-to-check (word setup-and-results-directory "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number)
  output-debug-message (word "CHECKING TO SEE IF THE FOLLOWING DIRECTORY STRUCTURE EXISTS: " directory-to-check) ("")
  if(not file-exists? (directory-to-check) )[
    set debug-indent-level (debug-indent-level - 2)
    error (word "File " setup-and-results-directory "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number " does not exist.")
  ]
  
  set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "CHECK-FOR-SUBSTRING-IN-STRING-AND-REPORT-OCCURRENCES" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Enables a calling turtle to check for the existence of a substring (needle) 
;specified in a string (haystack) and reports how many times the needle has
;been found in the haystack.  This is achieved by checking to see if the 
;needle is in the haystack, if it is, the number of occurrences is increased
;by 1.  The haystack then has everything up until the end of the needle removed
;and this modified haystack is then checked for the needle again until the needle
;is no longer present in the haystack.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@param   needle            String        The substring to be searched for.
;@param   haystack          String        The string to search in for the substring.
;@returns -                 Number        The number of occurrences of needle in haystack.
;
;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>  
to-report check-for-substring-in-string-and-report-occurrences [needle haystack]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'check-for-substring-in-string-and-report-occurrences' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message (word "CHECKING '" haystack "' FOR '" needle "'...") ("")
  
  let copy-of-haystack (haystack)
  let number-of-occurrences 0
  let length-of-needle length needle
  
  while[position needle copy-of-haystack != false][
    set number-of-occurrences (number-of-occurrences + 1)
    let position-to-cut-from (position needle copy-of-haystack) + length-of-needle  
    set copy-of-haystack (substring (copy-of-haystack) (position-to-cut-from) (length copy-of-haystack))
    
    output-debug-message (word "FOUND '" needle "'.  THE LOCAL 'number-of-occurrences' VARIABLE NOW EQUALS: " number-of-occurrences ".") ("")
    output-debug-message (word "After removing '" needle "' from the haystack, the haystack is now equal to: '" copy-of-haystack "'.") ("")
    output-debug-message (word "CHECKING '" copy-of-haystack "' FOR '" needle "'...") ("")  
  ]
  output-debug-message(word "'" needle "' OCCURS IN '" haystack "' " number-of-occurrences " TIMES.") ("")
  
  set debug-indent-level (debug-indent-level - 2)
  report number-of-occurrences
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "CHECK-NUMBER-VARIABLES" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Runs checks on global and turtle specific number variables to ensure
;that they have been set correctly.  The following checks are performed:
;
; 1. Is the variable's value of a "number" data type?
; 2. If the variable's value should/shouldn't be an integer i.e is it 
;    formatted correctly? Integer should contain a negation sign 
;    (optional) and any quantity without a decimal point and mantissa.
;    Non-integers should include a negation sign (optional), any 
;    quantity before a decimal point and a mantissa.
; 3. Is the variable's value greater than the specified minimum value?
; 4. Is the variable's value less than or equal to the specified maximum
;    value?
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@params  turtle-id         Number/String Set to an empty string if the 
;                                         variable is a global variable 
;                                         and the turtle's "who" variable
;                                         value if it is a turtle variable.  
;                                         This parameter controls the preamble
;                                         to error messages displayed by this
;                                         procedure. 
;@params  variable-name     String        The name of the variable whose
;                                         value is to be checked.
;@params  variable-value    Number        The value that is to be checked.
;@params  integer?          Boolean       Set to true if the variable 
;                                         should be formatted as an integer
;                                         and false if not.
;@params  min-value         Number        The minimum value that the 
;                                         variable value being checked 
;                                         should be greater than.
;@params  max-value         Number        The maximum value that the variable
;                                         value being checked should be less
;                                         than or equal to.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to check-number-variables [turtle-id variable-name variable-value integer? min-value max-value]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'check-number-variables' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  output-debug-message (word "THE 'turtle-id' VARIABLE IS SET TO: '" "'.") ("")
  output-debug-message (word "THE 'variable-name' VARIABLE IS SET TO: '" variable-name "'.") ("")
  output-debug-message (word "THE 'variable-value' VARIABLE IS SET TO: '" variable-value "'.") ("")
  output-debug-message (word "THE 'integer?' VARIABLE IS SET TO: '" integer? "'.") ("")
  output-debug-message (word "THE 'min-value' VARIABLE IS SET TO: '" min-value "'.") ("")
  output-debug-message (word "THE 'max-value' VARIABLE IS SET TO: '" max-value "'.") ("")
  
  ;================================;
  ;== SET ERROR MESSAGE PREAMBLE ==;
  ;================================;
  
  output-debug-message ("SETTING THE 'error-message-preamble' VARIABLE...") ("")
  let error-message-preamble ""
  ifelse(turtle-id = "")[
    set error-message-preamble (word "The global '" variable-name "' variable value ")
  ]
  [
    set error-message-preamble (word "Turtle " turtle-id "'s '" variable-name "' variable value ")
  ]
  output-debug-message (word "THE 'error-message-preamble' VARIABLE IS SET TO: '" error-message-preamble "'.") ("")
  
  ;=====================================;
  ;== CHECK THAT VARIABLE IS A NUMBER ==;
  ;=====================================;
  
  output-debug-message (word "CHECKING TO SEE IF '" variable-name "' IS A NUMBER...") ("")
  if(not runresult (word "is-number? " variable-name ))[
    error (word error-message-preamble "is not a number (" variable-value ").  Please rectify so that it is.")
  ]
  output-debug-message (word "'" variable-name "' IS A NUMBER...") ("")
  
  ;====================================================;
  ;== CHECK VARIABLE'S FORMATTING (INTEGER OR FLOAT) ==;
  ;====================================================;
  
  output-debug-message (word "CHECKING THAT '" variable-name "' IS FORMATTED AS AN INTEGER IF IT IS INTENDED TO BE...") ("")
  if( (integer?) and (not string:rex-match ("-?[0-9]+") (word variable-value) ) )[
    error (word error-message-preamble "is not formatted as an integer (" variable-value ") i.e. optional negation sign followed by numbers.  Please rectify.")
  ]
  output-debug-message (word "'" variable-name "' IS CORRECTLY FORMATTED AS AN INTEGER.") ("")
  
  ;===============================================================;
  ;== CHECK IF VARIABLE IS GREATER THAN THE MIN VALUE SPECIFIED ==;
  ;===============================================================;
  
  output-debug-message (word "CHECKING TO SEE IF '" variable-name "' IS >= " min-value "...") ("")
  if( (min-value != false) )[
    if(not runresult (word variable-value " >= " min-value))[
      error (word error-message-preamble "is not > " min-value " (" variable-value ").  Please rectify.")
    ]
  ]
  
  ;======================================================================;
  ;== CHECK THAT VARIABLE VALUE IS LESS THAN OR EQUAL TO ITS MAX VALUE ==;
  ;======================================================================;
  
  output-debug-message (word "CHECKING TO SEE IF '" variable-name "' IS <= " max-value "...") ("")
  if( (max-value != false) )[
    if(not runresult (word variable-value " <= " max-value ))[
      error (word error-message-preamble "is not <= " max-value " (" variable-value ").  Please rectify." )
    ]
  ]
  
  set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "CHECK-VARIABLE-VALUES" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Checks to see if all variable values are valid according to
;the rules set-up for each data type in a respective procedure.
;
;Global variables are checked first then turtle variables in the
;following order:
; - Number variables.
; - Boolean variables
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to check-variable-values
  
  ;======================;
  ;== GLOBAL VARIABLES ==;
  ;======================;
  
  ;Number type variables
  let number-global-variable-names-min-and-max-values (list 
    ( list ("hole-birth-prob") (false) (0.0) (1.0) )
    ( list ("hole-born-every") (false) (0.0) (false) )
    ( list ("hole-lifespan") (false) (0.0) (false) )
    ( list ("reward-value") (false) (0.0) (false) )
    ( list ("tile-birth-prob") (false) (0.0) (1.0) )
    ( list ("tile-born-every") (false) (0.0) (false) )
    ( list ("tile-lifespan") (false) (0.0) (false) )
  )
  
  foreach(number-global-variable-names-min-and-max-values)[
    check-number-variables ("") (item (0) (?)) (runresult (item (0) (?))) (item (1) (?)) (item (2) (?)) (item (3) (?))
  ]
  
  ;Boolean type variables
  
  ;=============================;
  ;== CHREST-TURTLE VARIABLES ==;
  ;=============================;
  
  ask chrest-turtles[
    
    let max-time ( max (list (play-time) (training-time)) )
    
    ;Number type variables.
    let number-type-chrest-turtle-variables (list
      ( list ("action-performance-time") (false) (false) (false) )
      ( list ("add-link-time") (false) (0.0) (max-time) )
      ( list ("discount-rate") (false) (0.0) (1.0) ) 
      ( list ("discrimination-time") (false) (0.0) (max-time) )
      ( list ("familiarisation-time") (false) (0.0) (max-time) )
      ( list ("max-length-of-episodic-memory") (true) (1) (false) )
      ( list ("max-search-iteration") (true) (1) (false) )
      ( list ("number-fixations") (true) (1) (false) )
      ( list ("play-time") (false) (0.0) (false) )
      ( list ("sight-radius") (true) (1) (max-pxcor) )
      ( list ("sight-radius") (true) (1) (max-pycor) )
      ( list ("time-taken-to-act-randomly") (false) (0.0) (max-time) )
      ( list ("time-taken-to-use-pattern-recognition") (false) (0.0) (max-time) )
      ( list ("time-taken-to-problem-solve") (false) (0.0) (max-time) )
      ( list ("training-time") (false) (0.0) (false) )
      ( list ("visual-spatial-field-empty-square-placement-time") (true) (0.0) (false) )
      ( list ("visual-spatial-field-object-movement-time") (true) (1) (false) )
      ( list ("visual-spatial-field-object-placement-time") (true) (1) (false) )
      ( list ("visual-spatial-field-recognised-object-lifespan") (true) (false) (false) )
      ( list ("visual-spatial-field-unrecognised-object-lifespan") (true) (false) (false) )
    )
    
    foreach(number-type-chrest-turtle-variables)[
      check-number-variables (who) (item (0) (?)) (runresult (item (0) (?))) (item (1) (?)) (item (2) (?)) (item (3) (?))
    ]
    
    ;Boolean type variables
    let boolean-type-chrest-turtle-variables (list
      ( list ("generate-plan?") )
      ( list ("pattern-recognition?") )
      ( list ("reinforce-actions?") )
      ( list ("reinforce-problem-solving?") )
    )
    
    foreach(boolean-type-chrest-turtle-variables)[
      check-boolean-variables (who) (item (0) (?)) (runresult (item (0) (?)))
    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "CHREST-TURTLES-ACT" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Procedure that is run by every CHREST turtle to "act" on a cycle of play.  The procedure
;each CHREST turtle follows is described below:
;
;1. CHREST turtle determines if it is hidden and if its attention is free:
;   1.1. If not hidden and its attention is free, the turtle determines if its current plan is 
;        empty.
;      1.1.1. Turtle's current plan is empty so a new plan should be generated; entails
;             construction of a new visual-spatial field.
;      1.1.2. Turtles current plan is not empty so it should try to perform the next action 
;             in the plan.
;   1.2. If hidden or its attention is not free the turtle does not do anything.
;2. CHREST turtle updates its plots.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to chrest-turtles-act
  output-debug-message ("EXECUTING THE 'chrest-turtles-act' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  ask chrest-turtles [
   output-debug-message (word "Checking to see if I'm hidden (" hidden? ").  If 'false' I should do something in this round, if 'true' I should do nothing...") (who)
   if( not hidden? )[
     output-debug-message (word "Since 'hidden?' is 'false' I should do something...") (who)
     
     ;=====================;
     ;== TURTLE CAN PLAN ==;
     ;=====================;
     if(can-plan?)[
       output-debug-message (word "Checking to see if my 'generate-plan?' turtle variable is set to true, if so, I should plan if not, I should execute the next action in my plan...") (who)
       ifelse(generate-plan?)[
         output-debug-message (word "My 'generate-plan?' turtle variable is set to 'true' so I should plan...") (who)
         generate-plan
       ]
       [
         output-debug-message (word "My 'generate-plan?' turtle variable is set to 'false' so I should execute the next action in my 'plan' turtle variable...") (who)
         execute-next-planned-action
       ]
     ]
     ;=========================;
     ;== TURTLE CAN NOT PLAN ==;
     ;=========================;
     
     output-debug-message ("Updating my plots...") (who)
     update-plot-no-x-axis-value ("Scores") (score)
     update-plot-no-x-axis-value ("Total Deliberation Time") (total-deliberation-time)
     update-plot-no-x-axis-value ("Num Visual-Action Links") (chrest:get-ltm-modality-num-action-links "visual")
     update-plot-with-x-axis-value ("Random Behaviour Frequency") (who) (frequency-of-random-behaviour) 
     update-plot-with-x-axis-value ("Problem-Solving Frequency") (who) (frequency-of-problem-solving)
     update-plot-with-x-axis-value ("Pattern-Recognition Frequency") (who) (frequency-of-pattern-recognitions)
     update-plot-no-x-axis-value ("Visual STM Size") (chrest:get-stm-modality-size "visual")
     update-plot-no-x-axis-value ("Visual LTM Size") (chrest:get-ltm-modality-size "visual")
     update-plot-no-x-axis-value ("Visual LTM Avg. Depth")(chrest:get-ltm-modality-avg-depth "visual")
     update-plot-no-x-axis-value ("Action STM Size") (chrest:get-stm-modality-size "action")
     update-plot-no-x-axis-value ("Action LTM Size") (chrest:get-ltm-modality-size "action")
     update-plot-no-x-axis-value ("Action LTM Avg. Depth") (chrest:get-ltm-modality-avg-depth "action")
   ]
 ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "CLOSEST-OBJECT-IN-SET-TO-SPECIFIED-OBJECT-AND-MANHATTAN-DISTANCE" PROCEDURE ;;; - MAY NO LONGER BE NECESSARY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Determines the manhattan distance from each element in the object set specified 
;;to the object specified.  If only one object in the set specified is closest then
;;this object is reported otherwise, one of the objects in the set with the shortest
;;manhattan distance is randomly reported.  The manhattan distance of this object
;;is also reported. 
;;
;;         Name              Data Type     Description
;;         ----              ---------     -----------
;;@param   object-from       String        The location of the object that is to be used as the 
;;                                         source point of the manhattan distance calculations.
;;                                         String should be formatted as the string representation
;;                                         of a CHREST-compatible "ItemSquarePattern" instance.
;;@param   objects-to        List          A list of strings representing the locations of the
;;                                         objects that are to be used as the terminal points 
;;                                         in the manhattan distance calculations. Strings should 
;;                                         be formatted as the string representation of a 
;;                                         CHREST-compatible "ItemSquarePattern" instance, i.e.
;;                                         "[object-id xcor ycor]"
;;@return  -                 List          Two elements:
;;                                         1) The location of the object from the set of terminal 
;;                                            locations specified that has the shortest manhattan 
;;                                            distance from the source object.
;;                                         2) The manhattan distance between the source and reported
;;                                            terminal object.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
;to-report closest-object-in-set-to-specified-object-and-manhattan-distance [object-from objects-to]
;  set debug-indent-level (debug-indent-level + 1)
;  output-debug-message ("EXECUTING THE 'closest-object-in-set-to-specified-object' PROCEDURE...") ("")
;  set debug-indent-level (debug-indent-level + 1)
;  
;  output-debug-message (word "Calculating the manhattan distance of each item in (" objects-to ") relative to the specified object (" object-from ")...") (who)
;  let manhattan-distances []
;  
;  let object-from-xcor ( chrest:ItemSquarePattern.get-column (object-from) )
;  let object-from-ycor ( chrest:ItemSquarePattern.get-row (object-from) )
;  
;  foreach(objects-to)[
;    let abs-num-patches-between-objects-along-xcor ( abs( (chrest:ItemSquarePattern.get-column (?)) - object-from-xcor) )
;    let abs-num-patches-between-objects-along-ycor ( abs( (chrest:ItemSquarePattern.get-row (?)) - object-from-ycor) )
;    output-debug-message (word "The absolute distance between " ? " and " object-from " is " abs-num-patches-between-objects-along-xcor " patches along the x-axis and " abs-num-patches-between-objects-along-ycor " patches along the y-axis.") (who) 
;    
;    let manhattan-distance (abs-num-patches-between-objects-along-xcor + abs-num-patches-between-objects-along-ycor)
;    output-debug-message (word "The manhattan distance between " ? " and " object-from " is: " manhattan-distance ".  Adding it to the local 'manhattan-distances' list...") (who)
;    set manhattan-distances ( lput (manhattan-distance) (manhattan-distances) )
;    output-debug-message (word "The 'manhattan-distances' list is now equal to: '" manhattan-distances "'...") (who)
;  ]
;  
;  let min-manhattan-distance ( min (manhattan-distances) )
;  let i (0)
;  let positions-of-objects-with-min-manhattan-distance-from-specified-object []
;  foreach(manhattan-distances)[
;    output-debug-message (word "Checking to see if the manhattan distance " ? " is equal to the minimum manhattan distance calculated: " min-manhattan-distance "...") (who)
;    if(? = min-manhattan-distance)[
;      output-debug-message (word "This manhattan distance (" ? ") is equal to the minimum manhattan distance specified so the position of this manhattan distance in 'manhattan-distances' (" i ") will be added to the local 'positions-of-objects-with-min-manhattan-distance-from-specified-object' variable...") (who)
;      set positions-of-objects-with-min-manhattan-distance-from-specified-object (lput (i) (positions-of-objects-with-min-manhattan-distance-from-specified-object))
;    ]
;    set i (i + 1)
;  ]
;  
;  output-debug-message (word "Selecting one of the elements in 'positions-of-objects-with-min-manhattan-distance-from-specified-object' (" positions-of-objects-with-min-manhattan-distance-from-specified-object ") to define the object to return in the local 'objects-to' variable (" objects-to ") as the closest object to '" object-from "'") (who)
;  let closest-object ( item (one-of (positions-of-objects-with-min-manhattan-distance-from-specified-object)) (objects-to) )
;  output-debug-message (word "The closest object to " object-from " from " objects-to " has been set to " closest-object ".  Reporting this along with the minimum manhattan distance calculated (" min-manhattan-distance ") as a list ..." ) (who)
;  set debug-indent-level (debug-indent-level - 2)
;  report (list (closest-object) (min-manhattan-distance) )
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "CONSTRUCT-VISUAL-SPATIAL-FIELD" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Constructs a visual-spatial field for the calling turtle with data concerning what turtles can be
;seen in its currently observable environment (if the calling turtle has a CHREST instance).
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to construct-visual-spatial-field
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'construct-visual-spatial-field' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  if( breed = chrest-turtles )[
    output-debug-message ("THE CALLING TURTLE'S BREED IS EQUAL TO 'chrest-turtles' SO THE PROCEDURE WILL CONTINUE...") ("")
    
    output-debug-message (word "Creating the scene that will be used to construct the visual-spatial field...") (who)
    let scene (chrest:scene.new (get-observable-environment) (""))
    
    output-debug-message (word "Constructing the visual-spatial field...") (who)
    chrest:VisualSpatialField.new
     (scene) 
     (visual-spatial-field-object-placement-time)
     (visual-spatial-field-empty-square-placement-time)
     (visual-spatial-field-access-time) 
     (visual-spatial-field-object-movement-time)
     (visual-spatial-field-recognised-object-lifespan)
     (visual-spatial-field-unrecognised-object-lifespan)
     (number-fixations)
     (report-current-time)
     (false)
     (false)
     
     set construct-visual-spatial-field? (false)
     output-debug-message (word "Since I'm constructing a visual-spatial field I'll set the 'construct-visual-spatial-field?' turtle variable to boolean false so that I can plan and not repeatedly construct a visual-spatial field every time 'generate-plan' is called.") (who)
  ]
  
  set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "CONVERT-MILLISECONDS-TO-SECONDS" PROCEDURE ;;; - MAY NO LONGER BE NEEDED SINCE TIME IS ALL IN MS NOW: CHECK IF THIS IS OK WITH FERNAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Primarily used to convert CHREST architecture times in CHREST turtles 
;;into Netlogo model time.
;;
;;         Name              Data Type     Description
;;         ----              ---------     -----------
;;@param   milliseconds      Number        A measure of time in milliseconds.
;;@returns -                 Number        The value of "milliseconds" in seconds with one 
;;                                         significant figure.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to-report convert-milliseconds-to-seconds [milliseconds]
;  report (precision (milliseconds / 1000) (1))
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "CONVERT-SECONDS-TO-MILLISECONDS" PROCEDURE ;;; - MAY NO LONGER BE NEEDED SINCE TIME IS ALL IN MS NOW: CHECK IF THIS IS OK WITH FERNAND
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Primarily used to enable the CHREST architectures in CHREST turtles 
;;to be able to perform their operations based upon the time kept by 
;;this Netlogo model.
;;
;;         Name              Data Type     Description
;;         ----              ---------     -----------
;;@param   seconds           Number        A measure of time in seconds.
;;@returns -                 Number        The value of "seconds" in milliseconds with no 
;;                                         significant figures.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to-report convert-seconds-to-milliseconds [seconds]
;  report (precision (seconds * 1000) (0))
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "CREATE-NEW-TILES-AND-HOLES" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Used to determine whether new tiles and holes should be created in the 
;simulation environment.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to create-new-tiles-and-holes
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'create-new-tiles-and-holes' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("CHECKING GAME CONTEXT (TRAINING OR NON-TRAINING)...") ("")
  
  no-display
  
  if(remainder (report-current-time) (tile-born-every) = 0)[
    output-debug-message ("A NEW TILE SHOULD BE GIVEN THE CHANCE TO BE CREATED NOW.") ("")
    
    if(random-float 1.0 < tile-birth-prob) [
      output-debug-message ("A NEW TILE WILL BE CREATED AND PLACED RANDOMLY IN THE ENVIRONMENT...") ("")
      create-tiles 1 [
        set heading 0
        set time-to-live tile-lifespan
        set color yellow
        place-randomly
      ]
    ]
  ]
  
  output-debug-message (word "REMAINDER OF DIVIDING '" current-game-time "' BY '" hole-born-every "' IS: '" remainder current-game-time hole-born-every "'.") ("")
  
  if(remainder (report-current-time) (hole-born-every) = 0)[
    output-debug-message ("A NEW HOLE SHOULD BE GIVEN THE CHANCE TO BE CREATED NOW.") ("")
    
    if(random-float 1.0 < hole-birth-prob) [
      output-debug-message ("A NEW HOLE WILL BE CREATED AND PLACED RANDOMLY IN THE ENVIRONMENT...") ("")
      create-holes 1 [
        set heading 0
        set time-to-live hole-lifespan
        set color blue
        place-randomly
      ]
    ]
  ]

  display
  set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "DELIBERATE" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Enables a calling turtle to deliberate about what action to perform next given the scene passed.  
;Depending on the breed of the turtle the deliberation procedure may differ.
;
;         Name              Data Type          Description
;         ----              ---------          -----------
;@param   scene             List               The scene to be deliberated with as a list of lists.
;                                              Each inner list should represent a patch in the model 
;                                              and should contain 4 values:
;
;                                              1) The xcor of the patch from the turtle deliberating.
;                                              2) The ycor of the patch from the turtle deliberating.
;                                              3) The who or unique identifier of a turtle/object on the patch.
;                                              4) The class or breed of the turtle/object on the patch.
;
;                                              For a turtle with who = 0 that can see the following (turtles
;                                              are denoted by their who value with the first letter of their breed 
;                                              in parenthesis expect for turtle 0 who's parenthesised value is "S" 
;                                              which stands for "self") the following list should be generated and
;                                              passed:
;                                              
;                                                |------|------|------|
;                                              2 | 5(H) | 2(H) | 8(T) |
;                                                |------|------|------|
;                                              1 | 4(O) | 0(S) | 7(H) |
;                                                |------|------|------|
;                                              0 | 3(T) | 1(T) | 6(O) |
;                                                |------|------|------|
;                                                   0      1      2     MODEL COORDINATES
;                                              
;                                              [
;                                                [-1 1 5 "hole"]     [0 1 2 "hole"]  [1 1 8 "tile"]
;                                                [-1 0 4 "opponent"] [0 0 0 "self"]  [1 0 7 "hole"]
;                                                [-1 -1 3 "tile"]    [0 -1 1 "tile"] [1 -1 6 "opponent"]
;                                              ]
;
;                                              Note that there is no strict ordering of inner-lists with respect to
;                                              what the turtle can actually see, i.e. the patches could be coded
;                                              in a random order rather than from west -> east and north -> south as
;                                              above.
;.
;@return  -                 List               A three element list:
;                                              1) The action to be performed as a 3 element list
;                                                 containing the action identifier, heading and
;                                                 patches that the turtle should move.
;                                              2) The time taken to complete deliberation.
;                                              3) Whether pattern-recognition was used or not (will
;                                                 be set to false for non-CHREST turtles).
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk> 
to-report deliberate [scene]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'deliberate' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  output-debug-message (word "The scene I'll deliberate with: " scene) (who)
  output-debug-message ("Creating four local variables: 'action', 'time-taken-to-deliberate', 'used-pattern-recognition' and 'patches-looked-at'...") (who)
  output-debug-message ("The 'action' variable will be populated with a 3 element list representing the action decided upon, the heading I should adopt when performing the action and how many patches the object to be actioned should be shifted along the heading specified...") (who) 
  output-debug-message ("The 'time-taken-to-deliberate' variable will store the length of time taken to deliberate...") (who)
  output-debug-message ("The 'used-pattern-recognition' variable controls whether problem-solving will be used (if set to false then problem-solving will be used).  Should only be set to true if I'm a CHREST turtle and I select an action using pattern-recogniition. Setting value to 'false' since this is a fresh deliberation...") (who)
  output-debug-message ("The 'patches-looked-at' variable will store what patches are looked at for problem-solving.  Should contain values representing the number of patches along the x and y axis that the patch looked at is from the deliberating turtle...") (who)
  
  let action ("")
  let time-taken-to-deliberate (0)
  let used-pattern-recognition (false)
  let patches-looked-at []
  
  ;===================================;
  ;== CHECK BREED OF CALLING TURTLE ==;
  ;===================================;
  
  output-debug-message ("Checking my breed to deliberate accordingly...") (who)
  if(breed = chrest-turtles)[
    output-debug-message ("I am a chrest-turtle so I will deliberate accordingly...") (who)
    
    output-debug-message ("Setting a local 'scene-scanned-during-pattern-recognition' variable to 'false'.  This is used if I use problem-solving to determine if I have already scanned the scene during pattern-recognition since I should only scan the scene once and pattern-recognition may result in problem-solving...") (who)
    let scanned-scene-during-pattern-recognition (false)
    
    let chrest-scene (chrest:Scene.new (scene) (""))

    ;=========================;
    ;== PATTERN-RECOGNITION ==;
    ;=========================;

    output-debug-message (word "If 'scene' isn't empty and I can use pattern-recognition (" pattern-recognition? "), I'll use pattern-recognition to select an action to perform...") (who)
    if( pattern-recognition? and (not empty? scene) )[
      
      output-debug-message (word "My 'pattern-recognition?' variable is set to 'true' and 'scene' isn't empty so I'll get any action-patterns associated with chunks I recognise in the scene, along with their optimality ratings...") (who)
      let action-chunks-and-weights-associated-with-recognised-visual-chunks []
      
      output-debug-message (word "My visual STM will be cleared before the scene is scanned so that any visual chunks recognised definitely originate from the scene passed.") (who)
      let recognised-scene (chrest:scan-scene(chrest-scene) (number-fixations) (true) (report-current-time) (false))
      output-debug-message (word "Setting the local 'scanned-scene-during-pattern-recognition' variable to true.") (who)
      set scanned-scene-during-pattern-recognition (true)
      
      let visual-stm (chrest:get-stm-contents-by-modality ("visual"))
      output-debug-message (word "I've recognised the following visual chunks: " (map ([ chrest:ListPattern.get-as-string (chrest:Node.get-image (?)) ]) (visual-stm))) (who)

      foreach(visual-stm)[
        let visual-chunk ( chrest:Node.get-image (?) )
        
        output-debug-message (word "Getting any actions and optimality ratings associated with the recognised visual chunk: " ( chrest:ListPattern.get-as-string (visual-chunk) ) "..." ) (who)
        let associated-action-chunks-and-weights (chrest:recognise-list-pattern-and-return-nodes-with-modality (visual-chunk) ("action") (report-current-time))
        
        output-debug-message (word "Associated actions and optimality ratings: " map ([ ( list (chrest:ListPattern.get-as-string (chrest:Node.get-image (item (0) (?)))) (item (1) (?)) ) ]) (associated-action-chunks-and-weights) ".") (who)
        
        if(not empty? associated-action-chunks-and-weights)[ 
          output-debug-message (word "There are actions associated with the visual chunk in question.  Adding them to the list of actions associated with recognised visual chunks...") (who)
          set action-chunks-and-weights-associated-with-recognised-visual-chunks (lput (associated-action-chunks-and-weights) (action-chunks-and-weights-associated-with-recognised-visual-chunks))
        ]
      ]
      
      output-debug-message (word "Checking to see if the list of actions associated with recognised visual chunks is empty.  If the list is empty, pattern-recognition is impossible so I won't continue to do so...") (who)
      if(not empty? action-chunks-and-weights-associated-with-recognised-visual-chunks)[
        output-debug-message (word "The list of actions isn't empty so I'll continue pattern-recognition...") (who)
        
        output-debug-message (word "Selecting an action to perform from the list of actions associated with the chunks recognised using the specified action-selection procedure (" action-selection-procedure ")...") (who)        
        let action-chunk ( runresult (word action-selection-procedure "( action-chunks-and-weights-associated-with-recognised-visual-chunks )" ) )

        output-debug-message (word "Checking to see if the action returned is a list(" is-list? action-chunk "), if it is then I won't continue with pattern-recognition...") (who)
        if( not is-list? action-chunk )[
          
          output-debug-message (word "The action returned is not a list.  Checking to see if it indicates that I should use problem-solving to deliberate further, if not, I'll set my 'used-pattern-recognition' variable to 'true'...") (who)
          set action (item (0) (chrest:ListPattern.get-as-netlogo-list (chrest:Node.get-image (action-chunk))))
          
          set action (list
            (chrest:ItemSquarePattern.get-item (action))
            (chrest:ItemSquarePattern.get-column (action))
            (chrest:ItemSquarePattern.get-row (action))
          )
          
          if( (item (0) (action)) != (problem-solving-token))[
            output-debug-message ("Action indicates that I shouldn't use problem-solving so I'll set the local 'used-pattern-recognition' variable to 'true'...") (who)
            set used-pattern-recognition (true)
          ]
          
          output-debug-message (word "Since I have used pattern-recognition I'll set the local 'time-taken-to-deliberate' variable to my 'time-taken-to-use-pattern-recognition' value (" time-taken-to-problem-solve ")...") (who)
          set time-taken-to-deliberate (time-taken-to-deliberate + time-taken-to-use-pattern-recognition)
          output-debug-message (word "My 'time-taken-to-deliberate' variable is now equal to: " time-taken-to-deliberate "...") (who)
          
          output-debug-message (word "Since I generated an action using pattern recognition, I will increment my 'frequency-of-pattern-recognitions' variable (" frequency-of-pattern-recognitions ") by 1...") (who)
          set frequency-of-pattern-recognitions (frequency-of-pattern-recognitions + 1)
          output-debug-message (word "My 'frequency-of-pattern-recognitions' variable is now equal to: " frequency-of-pattern-recognitions "...") (who)
        ]
      ]
    ]
    
    ;==========================================;
    ;== SET-UP VARIABLES FOR PROBLEM-SOLVING ==;
    ;==========================================;
    
    output-debug-message (word "Checking to see if the local 'used-pattern-recognition' variable value (" used-pattern-recognition ") is set to 'false'.  If so, I'll attempt to generate an action using problem-solving...") (who)
    if(not used-pattern-recognition)[
      output-debug-message (word "I didn't generate an action using pattern-recognition so I'll use problem-solving instead...") (who)
      
      output-debug-message ("Checking if I have already scanned the scene using pattern-recognition...") (who)
      if(not scanned-scene-during-pattern-recognition)[
        output-debug-message ("I've not already scanned the scene using pattern-recognition, scanning now but ignoring the scene returned...") (who)
        let scanned-scene (chrest:scan-scene (chrest-scene) (number-fixations) (true) (report-current-time) (false))
      ]
      
      let fixations (chrest:Perceiver.get-fixations)
      output-debug-message (word "I've looked at the following squares: " ( map ([ (list (chrest:Perceiver.get-fixation-xcor (?) - (sight-radius)) (chrest:Perceiver.get-fixation-ycor (?) - (sight-radius))) ]) (patches-looked-at) )) (who)
      output-debug-message ("Adding these patches to the 'patches-looked-at' data structure...") (who)
      
      foreach(fixations)[
        let patch-looked-at-xcor (chrest:Perceiver.get-fixation-xcor (?) - (sight-radius))
        let patch-looked-at-ycor (chrest:Perceiver.get-fixation-ycor (?) - (sight-radius))
        set patches-looked-at (lput 
          (list (patch-looked-at-xcor) (patch-looked-at-ycor)) 
          (patches-looked-at)
        )
      ]
      
      output-debug-message (word "Since I am generating an action using problem-solving, I will increment my 'frequency-of-problem-solving' variable (" frequency-of-problem-solving ") by 1...") (who)
      set frequency-of-problem-solving (frequency-of-problem-solving + 1)
      output-debug-message (word "My 'frequency-of-problem-solving' variable is now equal to: " frequency-of-problem-solving "...") (who)
    ]
  ]
  
  ;=====================;
  ;== PROBLEM-SOLVING ==;
  ;=====================;
  
  if(not used-pattern-recognition)[
    output-debug-message ("Using problem-solving to deliberate...") (who)
    output-debug-message (word "Checking to see if I've seen any tiles on the patches looked at: " patches-looked-at) (who)
    
    let patches-seen-with-tiles-on []
        
    foreach(patches-looked-at)[
      let patch-looked-at (?)
      let patch-looked-at-xcor (item (0) (patch-looked-at))
      let patch-looked-at-ycor (item (1) (patch-looked-at))
      output-debug-message (word "Checking patch that is " (list (patch-looked-at-xcor) "patches along the x-axis and " (patch-looked-at-ycor)) "patches along the y-axis from myself in the scene passed to this procedure for tiles...") (who)
    
      foreach(scene)[
        if( (item (0) (?) = patch-looked-at-xcor) and (item (1) (?) = patch-looked-at-ycor) and (item (3) (?) = tile-token) )[
          set patches-seen-with-tiles-on (lput (patch-looked-at) (patches-seen-with-tiles-on)) 
        ]
      ]
    ]
    output-debug-message (word "Patches I've seen with tiles on are: " patches-seen-with-tiles-on ) (who)
    
    ifelse( not empty? patches-seen-with-tiles-on )[
      output-debug-message ("Since I saw one or more tiles, I'll generate an appropriate action...") (who)
      let patch-with-tile-on (one-of (patches-seen-with-tiles-on))
      set action ( generate-action-when-tile-can-be-seen 
        (item (0) (patch-with-tile-on)) 
        (item (1) (patch-with-tile-on)) 
      )
    ]
    [
      output-debug-message ("I didn't see any tiles, I'll try to select a random heading to move 1 patch forward along...") (who)
      set action ( list (move-token) (one-of (movement-headings)) (1) )
    ]
      
    ;================================================;
    ;== UPDATE PROBLEM-SOLVING TRACKING VARIABLES  ==;
    ;================================================;
      
    output-debug-message (word "Since I have used problem solving I'll set the local 'time-taken-to-deliberate' variable to my 'time-taken-to-problem-solve-variable' value (" time-taken-to-problem-solve ")...") (who)
    set time-taken-to-deliberate (time-taken-to-deliberate + time-taken-to-problem-solve)
    output-debug-message (word "My 'time-taken-to-deliberate' variable is now equal to: " time-taken-to-deliberate "...") (who)
  ]
  
  output-debug-message (word "Incrementing my 'total-deliberation-time' variable (" total-deliberation-time " by the value of the local 'time-taken-to-deliberate' variable (" time-taken-to-deliberate ")...") (who)
  set total-deliberation-time (total-deliberation-time + time-taken-to-deliberate)
  output-debug-message (word "My 'total-deliberation-time' variable is now equal to: " total-deliberation-time "...") (who)
  
  ;====================================;
  ;== EXTRACT INFORMATION AND REPORT ==;
  ;====================================;
  
  output-debug-message (word "Reporting the action to perform (" action "), the time-taken to decide upon this action (" time-taken-to-deliberate ") and the value of 'used-pattern-recognition' (" used-pattern-recognition ") as a list...") (who)
  let action-and-time-taken-to-generate-and-pattern-recognition-use ( list 
    (action) 
    (time-taken-to-deliberate)
    (used-pattern-recognition)
  )
  
  set debug-indent-level (debug-indent-level - 2)
  report action-and-time-taken-to-generate-and-pattern-recognition-use
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "EXECUTE-NEXT-PLANNED-ACTION" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;CHREST turtle only procedure.
;
;Executes the first action in the calling turtle's 'plan' variable if:
; 1. The 'plan' variable is not empty
; 2. The current model time is greater than or equal to the calling turtle's
;    'deliberation-finished-time' variable value.
;
;If execution of the first action in the calling turtle's 'plan' variable
;fails then a new plan will be constructed on the calling turtle's next 
;play cycle.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
to execute-next-planned-action
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'execute-next-planned-action' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  if(breed = chrest-turtles)[
    output-debug-message ( word "Checking to see if my 'plan' turtle variable is empty (contents: '" plan "')...") (who)
    if( not (empty? (plan)) )[
      
      output-debug-message ( word "My 'plan' turtle variable isn't empty so I'll check to see if I am still deliberating i.e. is the current time (" report-current-time ") greater or equal to than the value of my 'deliberation-finished-time' turtle variable (" deliberation-finished-time ")...") (who)
      if(report-current-time >= deliberation-finished-time)[
        
        output-debug-message (word "Setting a local 'action-performed-successfully' variable to boolean false.  This will be used to determine what to do after the action has been executed..." ) (who)
        let action-performed-successfully (false)
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;; GET AND PREPARE OBSERVABLE ENVIRONMENT ;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        output-debug-message (word "Getting what I can currently see so that this information can be passed to the procedure that handles performing the planned action...") (who)
        let observable-environment (get-observable-environment)
        
        output-debug-message (word "Removing object ID's from what I can currently see since this information is not required by the action performance procedure...") (who)
        foreach (observable-environment)[
          let patch-info-with-object-id (?)
          let patch-info-without-object-id (remove-item (2) (patch-info-with-object-id))
          set observable-environment (replace-item 
            (position (patch-info-with-object-id) (observable-environment)) 
            (observable-environment) 
            (patch-info-without-object-id)
            )
        ]
        output-debug-message (word "What I can see after removing object ID's: " observable-environment) (who)
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;; PERFORM NEXT PLANNED ACTION ;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        output-debug-message ( word "The current model time is greater than or equal to the value of my 'deliberation-finished-time' turtle variable so I'll attempt to perform the first action in my 'plan' and set the result of this to a local 'result-of-performing-action' variable..." ) (who)
        let result-of-performing-action ( perform-action (first (plan)) (observable-environment) )
        
        output-debug-message ( word "Checking to see if the local 'result-of-performing-action' variable is a list or not.  If it is then the action performed must have been a 'push-tile' action so the first element of the list will be whether the action was performed successfully whilst the second element will indicate whether or not a hole was filled..." ) (who)
        ifelse( is-list? (result-of-performing-action) )[
          
          output-debug-message ( word "The local 'result-of-performing-action' variable is a list so I'll set the first element of this list to the local 'action-performed-successfully' variable..." ) (who)
          set action-performed-successfully ( item (0) (result-of-performing-action) )
        ]
        [
          output-debug-message ( word "The local 'result-of-performing-action' variable is not a list so I'll set the local 'action-performed-successfully' variable to its value..." ) (who)
          set action-performed-successfully (result-of-performing-action)
        ]
        
        output-debug-message ( word "Checking the value of the local 'action-performed-successfully' variable (" action-performed-successfully ")..." ) (who)
        ifelse( action-performed-successfully )[
          
          output-debug-message ( word "The local 'action-performed-successfully' variable value is set to 'true' so the action was performed successfully. remove the action from 'plan' and continue plan execution..." ) (who)
          set plan (remove-item (0) (plan))
          output-debug-message ( word "After removing the action from 'plan', this variable is now equal to: '" plan "'..." ) (who)
          
          output-debug-message ( word "Checking to see if the local 'result-of-performing-action' variable is a list.  If it is then the action performed must have been a 'push-tile' action so the first element of the list will be whether the action was performed successfully whilst the second element will indicate whether or not a hole was filled...") (who)
          if( is-list? (result-of-performing-action) ) [
            
            output-debug-message ( word "The local 'result-of-performing-action' variable is a list so I'll check the value of its second element (" item (1) (result-of-performing-action) ").  If this is 'true' I'll reinforce the episodes in my 'episodic-memory'..." ) (who)
            if( item (1) (result-of-performing-action) )[
              
              output-debug-message ( word "The second element of the local 'result-of-performing-action' variable is 'true' so I'll reinforce all episodes in my 'episodic-memory'..." ) (who)
              reinforce-visual-action-links
            ]
          ]
        ]
        [
          output-debug-message ( word "The action was not performed successfully so I should abandon this plan and construct a new one.  Setting my 'plan' turtle variable to an empty list..." ) (who)
          set plan []
          output-debug-message ( word "My 'plan' turtle variable is now set to '" plan "'..." ) (who)
        ]
      ]
    ]
    
    output-debug-message ("Checking to see if my 'plan' turtle variable is empty...") (who)
    if( empty? (plan) )[
      output-debug-message ( word "My 'plan' turtle variable is empty so I'll set my 'generate-plan?' turtle variable to 'true' and my 'construct-visual-spatial-field?' variable to 'true' so that I can re-plan correctly..." ) (who)
      set generate-plan? (true)
      set construct-visual-spatial-field? (true)
      output-debug-message ( word "My 'generate-plan?' turtle variable is now set to '" generate-plan? "' and my 'construct-visual-spatial-field?' variable is set to '" construct-visual-spatial-field? "'..." ) (who)
    ]
  ]
  
  set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "GENERATE-ACTION-WHEN-TILE-CAN-BE-SEEN" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Reports an action to perform relative to the location of a tile that has been "seen".
;
;This procedure is quite non-deterministic in order to ensure that the calling turtle
;is not too intelligent in how it behaves therefore, learning is valuable.  The following
;mapping illustrates what actions may be returned if the tile is adjacent to the calling
;turtle.
;
; Location of tile to calling turtle   Potential actions
; ----------------------------------   -----------------
; North                                ~ Move east around tile
;                                      ~ Move west around tile
;                                      ~ Push tile north
; East                                 ~ Move north around tile
;                                      ~ Move south around tile
;                                      ~ Push tile east
; South                                ~ Move east around tile
;                                      ~ Move west around tile
;                                      ~ Push tile south
; West                                 ~ Move north around tile
;                                      ~ Move south around tile
;                                      ~ Push tile west
;
;If the tile is not adjacent to the calling turtle, the turtle may move in whatever direction
;the tile is away from the calling turtle, i.e. if the tile is to the north the turtle 
;will move north.  Note that, if the tile is not immediately north, east, south or west
;of the calling turtle, it will have to select between two or more headings.  For example,
;if the tile is north-west of the turtle, the turtle may decide to move north or west.
;         
;         Name          Data Type                         Description
;         ----          ---------                         -----------
;@param   tile-xcor     Number                            The xcor of a tile relative to the calling
;                                                         turtle.
;@param   tile-ycor     Number                            The ycor of a tile relative to the calling
;                                                         turtle.
;@return  -             List                              An action that could be performed relative to
;                                                         the tile's location from the calling turtle 
;                                                         specified as a 3 element list.  Element contents
;                                                         are as follows:
;
;                                                         1) The action to perform.
;                                                         2) The heading to adopt when performing the action.
;                                                         3) The number of patches the objects actioned should
;                                                            be shifted when the object is performed.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk> 
to-report generate-action-when-tile-can-be-seen [tile-xcor tile-ycor]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'generate-action-when-tile-can-be-seen' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1) 
  
  let action ""
  output-debug-message (word "Determining if tile seen is adjacent to me (xcor = " tile-xcor ", ycor = " tile-ycor ")...") (who)
  
  ifelse(
    (tile-xcor = 0 and tile-ycor = 1) or ;North 
    (tile-xcor = 1 and tile-ycor = 0) or ;East
    (tile-xcor = 0 and tile-ycor = -1) or ;South
    (tile-xcor = -1 and tile-ycor = 0) ;West
  )[
    output-debug-message ("Tile seen is adjacent to me, determining what actions I could perform...") (who)
    
    let potential-actions []
    if(tile-xcor = 0 and tile-ycor = 1)[
      output-debug-message ("Tile is north of me so I could move east or west around it or push it north...") (who)
      set potential-actions (lput (list (move-around-tile-token) (90) (1)) (potential-actions))
      set potential-actions (lput (list (move-around-tile-token) (270) (1)) (potential-actions))
      set potential-actions (lput (list (push-tile-token) (0) (1)) (potential-actions))
    ]
    
    if(tile-xcor = 1 and tile-ycor = 0)[
      output-debug-message ("Tile is east of me so I could move north or south around it or push it east...") (who)
      set potential-actions (lput (list (move-around-tile-token) (0) (1)) (potential-actions))
      set potential-actions (lput (list (move-around-tile-token) (180) (1)) (potential-actions))
      set potential-actions (lput (list (push-tile-token) (90) (1)) (potential-actions))
    ]
    
    if(tile-xcor = 0 and tile-ycor = -1)[
      output-debug-message ("Tile is south of me so I could move east or west around it or push it south...") (who)
      set potential-actions (lput (list (move-around-tile-token) (90) (1)) (potential-actions))
      set potential-actions (lput (list (move-around-tile-token) (270) (1)) (potential-actions))
      set potential-actions (lput (list (push-tile-token) (180) (1)) (potential-actions))
    ]
    
    if(tile-xcor = -1 and tile-ycor = 0)[
      output-debug-message ("Tile is west of me so I could move north or south around it or push it west...") (who)
      set potential-actions (lput (list (move-around-tile-token) (0) (1)) (potential-actions))
      set potential-actions (lput (list (move-around-tile-token) (180) (1)) (potential-actions))
      set potential-actions (lput (list (push-tile-token) (270) (1)) (potential-actions))
    ]
    
    set action (one-of potential-actions)
  ]
  [
    output-debug-message ("Tile seen is not adjacent to me, determining what headings I could move in...") (who)
    let potential-headings []
    
    if(tile-ycor > 0)[
      output-debug-message ("Tile is north of me so I could move north...") (who)
      set potential-headings (lput (0) (potential-headings))
    ]
    
    if(tile-xcor > 0)[
      output-debug-message ("Tile is east of me so I could move east...") (who)
      set potential-headings (lput (90) (potential-headings))
    ]
    
    if(tile-ycor < 0)[
      output-debug-message ("Tile is south of me so I could move south...") (who)
      set potential-headings (lput (180) (potential-headings))
    ]
    
    if(tile-xcor < 0)[
      output-debug-message ("Tile is west of me so I could move west...") (who)
      set potential-headings (lput (270) (potential-headings))
    ]
    
    set action (list (move-to-tile-token) (one-of (potential-headings)) (1))
  ]
  
  output-debug-message (word "The action I'm going to perform is: " action) (who)
  set debug-indent-level (debug-indent-level - 2)
  report action
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "GENERATE-MOVE-TO-OR-PUSH-CLOSEST-TILE-ACTION" PROCEDURE ;;; - MAY NO LONGER BE NEEDED DUE TO SIMPLIFIED PROBLEM-SOLVING IN "deliberate" PROCEDURE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Generates a "push-tile" action pattern for the calling turtle that enables it to push 
;;the calling turtle's closest tile along the heading of the calling turtle after it has 
;;turned to face its closest tile.  Note that this procedure does not ensure that the 
;;turtle pushes its closest tile towards a hole.
;;
;;If the path of the calling turtle's closest tile along this heading is not clear, the 
;;calling turtle will alter its current heading by +/- 90 and a "move-around-tile" action 
;;pattern will be generated instead of a "push-tile" action pattern.  
;;
;;         Name              Data Type          Description
;;         ----              ---------          -----------
;;@param   scene             jchrest.lib.Scene  The scene to be evaluated.
;;@return  -                 String             The action to perform as an "item-square" 
;;                                              CHREST-compatible pattern.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to-report generate-move-to-or-push-closest-tile-action [scene]
;  set debug-indent-level (debug-indent-level + 1)
;  output-debug-message ("EXECUTING THE 'generate-move-to-or-push-closest-tile-action' PROCEDURE...") ("")
;  set debug-indent-level (debug-indent-level + 1)
;  
;  output-debug-message ("Three local variables will be instantiated: 'location-of-self', 'remain-stationary' and 'action-pattern'...") (who)
;  output-debug-message ("The local 'location-of-self' variable stores my location in the scene passed...") (who)
;  output-debug-message ("The local 'remain-stationary' variable stores a boolean value that indicates if the calling turtle should remain stationary...") (who)
;  output-debug-message ("The local 'action-pattern' variable stores the action generated by this procedure and will be reported...") (who)
;  let location-of-self ( item (0) (get-locations-of-object-in-scene (self-token) (scene)) )
;  let remain-stationary (false)
;  let action-pattern []
;  
;  output-debug-message ("Checking to see if I am currently surrounded...") (who)
;  ifelse(not surrounded? (scene) )[
;    
;    output-debug-message ("I'm not surrounded so I need to determine if I can see any tiles (the result of this check will be set to the local 'tile-locations' variable) since I may have invoked this function without consulting visual information...") (who)
;    let tile-locations ( get-locations-of-object-in-scene (tile-token) (scene) )
;    output-debug-message (word "The local 'tile-locations' variable is set to: '" tile-locations "'.  Checking to see if this is empty...") (who)
;    
;    ifelse(not empty? tile-locations)[
;      output-debug-message (word "The local 'tile-locations' variable is not empty so I will now set a local variable 'closest-tile-location-and-manhattan-distance' to the location of the tile in the scene passed with minimum manhattan distance from my location in scene and this manhattan distance...") (who)
;      
;      let closest-tile-location-and-manhattan-distance (closest-object-in-set-to-specified-object-and-manhattan-distance (location-of-self) (tile-locations))
;      let closest-tile-location ( item (0) (closest-tile-location-and-manhattan-distance) )
;      let closest-tile-distance ( item (1) (closest-tile-location-and-manhattan-distance) )
;      output-debug-message (word "The following tile has been determined to be the closest one to my location in the scene passed: " closest-tile-location "...") (who)
;      
;      output-debug-message (word "I'll calculate what heading I need to adopt to face the tile indicated in my 'closest-tile' variable and then rectify this heading to one of " movement-headings "...") (who)
;      let heading-to-face (rectify-heading( (heading-that-gives-shortest-distance-from-location-to-location (location-of-self) (closest-tile-location)) ))
;      
;      output-debug-message (word "The manhattan distance between this tile and my location in the scene passed is: " closest-tile-distance ".  Checking this distance to determine my next move...") (who)
;      
;      ifelse(closest-tile-distance > 1)[
;        output-debug-message ("My closest tile is more than 1 patch away so I need to move closer to it...") (who)
;        
;        ;Only need to check for visible opponents since if there were a tile adjacent to the calling
;        ;turtle, this would be the tile being pushed.  For example: there would never be a situation 
;        ;where the turtle decides to move north to be adjacent to a tile that is north-east of it and 
;        ;there is a tile immediately north of it which would need to be moved out of the way.  In this 
;        ;case, the tile to the north would be the one that would be pushed in the first place.
;        ;Also, holes do not need to be checked for since, if the calling turtle could see a tile and a
;        ;hole, this procedure wouldn't be run.
;        
;        ;let patch-ahead-contents ( item (0) ( string:rex-split ( get-object-and-patch-coordinates-ahead-of-location-in-scene (scene) (location-of-self) (heading-to-face) (1) ) (";") ) )
;        while[ patch-ahead-blocked? (scene) (heading-to-face) ][
;          output-debug-message (word "The patch ahead along heading '" heading-to-face "' is blocked so I'll alter this value by +/- 90 to try and find a free patch...") (who)
;          set heading-to-face ( alter-heading-randomly-by-adding-or-subtracting-90 (heading-to-face) )
;        ]
;        output-debug-message (word "The patch ahead with heading " heading-to-face " is free, so I'll move towards the tile there...") (who)
;        set action-pattern ( chrest:create-item-square-pattern (move-to-tile-token) (heading-to-face) (1) )
;      ]
;      [
;        output-debug-message ("My closest tile is 1 patch away from me so I'll attempt to push it if it isn't blocked (checking this now)...")(who)
;        
;        ifelse( patch-ahead-blocked? (scene) (heading-to-face) )[
;          output-debug-message (word "The tile I intend to push is blocked along the proposed heading (" heading-to-face ") so I'll have to move around the tile to try and push it from another direction...") (who)
;          
;          set heading-to-face (alter-heading-randomly-by-adding-or-subtracting-90 (heading-to-face))
;          output-debug-message (word "Checking to see if the patch immediately ahead along heading " heading-to-face " is clear: no opponents or holes or tiles that are blocked along this heading...") (who)
;          
;          let patch-ahead-contents ( item (0) ( string:rex-split ( get-object-and-patch-coordinates-ahead-of-location-in-scene (scene) (heading-to-face) (1) ) (";") ) )
;          let patch-ahead-of-patch-ahead-contents ( item (0) ( string:rex-split ( get-object-and-patch-coordinates-ahead-of-location-in-scene (scene) (heading-to-face) (2) ) (";") ) )
;          while[ patch-ahead-blocked? (scene) (heading-to-face) ][
;            output-debug-message (word "The patch ahead along heading '" heading-to-face "' is blocked so I'll alter this value by +/- 90 and check again...") (who)
;            set heading-to-face (alter-heading-randomly-by-adding-or-subtracting-90 (heading-to-face))
;          ]
;          output-debug-message (word "The patch ahead with heading " heading-to-face " is either free or has a tile that can be pushed on it.  Checking to see if I need to push a tile or not...") (who)
;          
;          set patch-ahead-contents ( get-object-and-patch-coordinates-ahead-of-location-in-scene (scene) (heading-to-face) (1) )
;          let patch-ahead-object ( item (0) (string:rex-split (patch-ahead-contents) (";")) )
;          
;          ifelse( patch-ahead-object = tile-token )[
;            output-debug-message (word "Since there is a tile on the patch adjacent to me along heading " heading-to-face", I'll push it out of the way..." ) (who)
;            set action-pattern ( chrest:create-item-square-pattern (push-tile-token) (heading-to-face) (1) )
;          ]
;          [
;            output-debug-message (word "There isn't a tile on the patch adjacent to me along heading " heading-to-face " so I'll move around the tile to try and push it from a heading where its not blocked...") (who)
;            set action-pattern ( chrest:create-item-square-pattern (move-around-tile-token) (heading-to-face) (1) )
;          ]
;        ]
;        [
;          output-debug-message (word "The tile I intend to push isn't blocked along heading '" heading-to-face "' so I'll push it...") (who)
;          set action-pattern ( chrest:create-item-square-pattern (push-tile-token) (heading-to-face) (1) )
;        ]
;      ]
;    ]
;    [
;      output-debug-message ("I can't see any tiles so my 'visually-informed-problem-solving?' turtle variable must be 'false' and I've run this procedure at random.  Returning a 'procedure-not-applicable' action-pattern...") (who)
;      set action-pattern (chrest:create-item-square-pattern (procedure-not-applicable-token) (0) (0)) 
;    ]
;  ]
;  [
;    output-debug-message ("Since I'm surrounded I'll set the local 'remain-stationary' variable to 'true'...") (who)
;    set remain-stationary (true)
;  ]
;  
;  output-debug-message (word "Checking the value of the local 'remain-stationary' variable, it its set to 'true' I should set the local 'action-pattern' variable to a 'remain-stationary' action pattern...") (who)
;  if(remain-stationary)[
;    output-debug-message (word "The local 'remain-stationary' variable is set to true so I should set the local 'action-pattern' variable to a 'remain-stationary' action pattern...") (who)
;    set action-pattern ( chrest:create-item-square-pattern (remain-stationary-token) (0) (0) )
;  ]
;  
;  output-debug-message (word "The local 'action-pattern' variable is set to '" action-pattern "'.  Reporting this...") (who)
;  set debug-indent-level (debug-indent-level - 2)
;  report (action-pattern)
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "GENERATE-PLAN" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;CHREST-turtle only procedure.
;
;Populates the calling turtle's 'plan' variable with actions patterns and the visual
;pattern expected when that action is to be performed.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to generate-plan
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'generate-plan' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  if(breed = chrest-turtles)[
  
    ;==========================;
    ;== ATTENTION FREE CHECK ==;
    ;==========================; 
    
    output-debug-message (word "Plan generation requires attention and I may be busy doing something else (attention free @ " chrest:get-attention-clock ", current time: " report-current-time ").") (who)
    if(chrest:get-attention-clock <= report-current-time)[
      
      output-debug-message(word "Attention is free, I can plan...") (who)
      
      ;=================================================;
      ;== CHECK FOR VISUAL-SPATIAL FIELD CONSTRUCTION ==;
      ;=================================================;
      
      ifelse(construct-visual-spatial-field?)[
        output-debug-message(word "My 'construct-visual-spatial-field?' variable is equal to 'true' so I'll construct a new visual-spatial field...") (who)
        construct-visual-spatial-field
      ]
      [
        output-debug-message (word "My 'construct-visual-spatial-field?' variable is equal to 'false' so I've already constructed a visual-spatial field for this planning cycle.  Generating a planned action...")  (who)
        
        ;========================================================;
        ;== CHECK FOR END PLAN GENERATION CONDITIONS BEING MET ==;
        ;========================================================;
        
        output-debug-message ("Checking to see if any plan generation conditions have been met...") (who)
        let end-plan-generation? (false)
        
        ;++++++++++++++++++++++++++++;
        ;++ CHECK SEARCH ITERATION ++;
        ;++++++++++++++++++++++++++++;
        
        if(current-search-iteration > max-search-iteration)[
          output-debug-message (word "I've reached my maximum search bound: my 'current-search-iteration' variable (" current-search-iteration ") is > my 'max-search-iteration' variable (" max-search-iteration ").  Ending plan generation...") (who)
          set end-plan-generation? (true)
        ]
        
        ;++++++++++++++++++++++++++++++++++++++++++++;
        ;++ CHECK FOR SELF ON VISUAL-SPATIAL FIELD ++;
        ;++++++++++++++++++++++++++++++++++++++++++++;
        
        if(not end-plan-generation?)[
          if( empty? chrest:VisualSpatialField.get-object-locations (report-current-time) (word who) (true) )[
            output-debug-message (word "I can't currently see myself in my visual-spatial field. Ending plan generation...")  (who)
            set end-plan-generation? true
          ]
        ]
        
        ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
        ;++ CHECK FOR TILE BEING PUSHED STILL EXISTING IN VISUAL-SPATIAL FIELD OR BEING PUSHED ONTO SAME COORDINATE AS HOLE ++;
        ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
        
        if(not end-plan-generation?)[
          
          output-debug-message (word "Checking to see if my last planned action pushed a tile out of my visual-spatial field in my last plan generation episode...")  (who)
          output-debug-message ("Checking to see if my 'plan' turtle variable is currently empty.  If not, I'll retrieve the last action in the plan...") (who)
          output-debug-message ("If the last action was to push a tile, I can no longer see the tile pushed in my visual-spatial field or the tile is on the same coordinates as a hole, I'll set the local 'end-plan-generation?' variable to 'true'") (who)
          output-debug-message ("If this isn't checked, further planning may occur which should not be done...") (who)
          if( (not empty? plan) and (not empty? who-of-tile-last-pushed-in-plan) )[
            
            output-debug-message (word "My plan isn't empty and I've been pushing a tile so I'll check to see if it still exists or has been pushed onto a hole") (who)
            output-debug-message ("Setting two local variables: 'last-action-in-plan-identifier' and 'last-action-in-plan-heading' to the relevant parts of the last action in my 'plan' turtle variable...") (who)
            let last-action-in-plan-info ( item (0) (last (plan)) )
            let last-action-in-plan-identifier ( chrest:ItemSquarePattern.get-item (last-action-in-plan-info) )
            let last-action-in-plan-heading ( chrest:ItemSquarePattern.get-column (last-action-in-plan-info) )
            output-debug-message ( word "The 'last-action-in-plan-identifier' and 'last-action-in-plan-heading' variables are now set to '" last-action-in-plan-identifier "' and '" last-action-in-plan-heading "'..." ) (who)
            
            if( last-action-in-plan-identifier = push-tile-token )[
              output-debug-message (word "My last planned action was to push a tile. I'll check to see if the pushed tile (who = " who-of-tile-last-pushed-in-plan ") still exists in my visual-spatial field") (who)
              
              let locations-of-tile-last-pushed (chrest:VisualSpatialField.get-object-locations (report-current-time) (who-of-tile-last-pushed-in-plan) (true))
              ifelse(empty? locations-of-tile-last-pushed)[
                output-debug-message (word "There is no tile with a 'who' value of " who-of-tile-last-pushed-in-plan " in my visual-spatial field so the 'end-plan-generation?' turtle variable should be set to true") (who)
                set end-plan-generation? (true)
              ]
              [
                let location-of-tile-last-pushed ( item (0) (locations-of-tile-last-pushed) )
                output-debug-message (word "There is a tile with a 'who' value of " who-of-tile-last-pushed-in-plan " on coordinates " location-of-tile-last-pushed " in my visual-spatial field so I'll check to see if there is also a hole on this location...")  (who)
                
                if(chrest:VisualSpatialField.is-object-on-square? (report-current-time) (hole-token) (item (0) (location-of-tile-last-pushed)) (item (1) (location-of-tile-last-pushed)) (false))[
                  output-debug-message (word "There is a hole on the same coordinates as the tile so the local 'end-plan-generation?' variable will be set to true...")  (who)
                  set end-plan-generation? (true)
                ]  
              ]
            ]
          ]
        ]
        
        ;=========================================;
        ;== GENERATE VISUAL-SPATIAL FIELD MOVES ==;
        ;=========================================;
        ifelse(not end-plan-generation?)[
          
          output-debug-message ("No end plan generation conditions met, generating next planned action...") (who)
          
          let action-to-perform ""
          let visual-spatial-field-moves ""
          let reverse-visual-spatial-field-move? (false)
          
          output-debug-message ("Resetting 'who-of-tile-last-pushed-in-plan'") (who)
          set who-of-tile-last-pushed-in-plan ("")
          
          ;Generate a new move and add it to the plan (at this point, the visual-spatial field will be OK to generate as a Scene since there will not be two objects on any visual-spatial coordinate)
          let visual-spatial-field-as-list-with-object-ids (chrest:ListPattern.get-as-netlogo-list
            (chrest:Scene.get-as-list-pattern
              (chrest:VisualSpatialField.get-as-scene 
                (report-current-time) 
                (false)
                ) 
              (true) ;Creator-relative coordinates
              (false) ;Object IDs
              )
            )
          
          let visual-spatial-field-as-list-with-object-classes (chrest:ListPattern.get-as-netlogo-list
            (chrest:Scene.get-as-list-pattern
              (chrest:VisualSpatialField.get-as-scene 
                (report-current-time) 
                (false)
                ) 
              (true) ;Creator-relative coordinates
              (true) ;Object classes
              )
            )
          
          let scene-to-deliberate-with []
          let i (0)
          while [i < (length visual-spatial-field-as-list-with-object-classes)][
            let visual-spatial-field-object-info-with-id (item (i) (visual-spatial-field-as-list-with-object-ids))
            let visual-spatial-field-object-info-with-class (item (i) (visual-spatial-field-as-list-with-object-classes))
            
            set scene-to-deliberate-with (lput
              (list 
                (chrest:ItemSquarePattern.get-column (visual-spatial-field-object-info-with-id))
                (chrest:ItemSquarePattern.get-row (visual-spatial-field-object-info-with-id))
                (chrest:ItemSquarePattern.get-item (visual-spatial-field-object-info-with-id))
                (chrest:ItemSquarePattern.get-item (visual-spatial-field-object-info-with-class))
                )
              (scene-to-deliberate-with)
              )
            set i (i + 1)
          ]
          
          let action-to-perform-time-taken-to-deliberate-and-used-pattern-recognition (deliberate (scene-to-deliberate-with) )
          set action-to-perform ( item (0) (action-to-perform-time-taken-to-deliberate-and-used-pattern-recognition) )
          let time-taken-to-deliberate ( item (1) (action-to-perform-time-taken-to-deliberate-and-used-pattern-recognition) )
          let used-pattern-recognition ( item (2) (action-to-perform-time-taken-to-deliberate-and-used-pattern-recognition) )
          
          set action-to-perform (chrest:ItemSquarePattern.new 
            (item (0) (action-to-perform)) 
            (item (1) (action-to-perform)) 
            (item (2) (action-to-perform)) 
            )
          
          output-debug-message (word "Action decided upon: " chrest:ItemSquarePattern.get-as-string (action-to-perform) ) (who)
          output-debug-message (word "Time spent deliberating: " time-taken-to-deliberate ".") (who)
          output-debug-message (word "Did I use pattern-recognition to generate " chrest:ItemSquarePattern.get-as-string (action-to-perform) "?: " used-pattern-recognition ".") (who)
          
          output-debug-message ( word "Adding the time taken to decide upon this action pattern to the current value of my 'time-spent-deliberating-on-plan' turtle variable (" time-spent-deliberating-on-plan ")...") (who)
          set time-spent-deliberating-on-plan (time-spent-deliberating-on-plan + time-taken-to-deliberate)
          output-debug-message ( word "My 'time-spent-deliberating-on-plan' turtle variable is now equal to: " time-spent-deliberating-on-plan "...") (who)
          
          output-debug-message ("Generating visual-spatial field moves...") (who)
          set visual-spatial-field-moves ( generate-visual-spatial-field-moves (action-to-perform) (false) )
          
          ;========================================;
          ;== PERFORM VISUAL-SPATIAL FIELD MOVES ==;
          ;========================================;
          
          output-debug-message ( word "Moving objects in the visual-spatial field..." ) (who)
          chrest:VisualSpatialField.move-objects (visual-spatial-field-moves) (report-current-time) (false)
          output-debug-message ( word "Completed moving objects in the visual-spatial-field...") (who)
          
          output-debug-message ("Incrementing my 'current-search-iteration' turtle variable by 1") (who)
          set current-search-iteration (current-search-iteration + 1)
          
          ;===========================================;
          ;== CHECK THAT LAST PLANNED ACTION VALID  ==;
          ;===========================================;
          
          ;CAUTION: When checking these conditions, don't get the visual-spatial-field as a Scene since only one object will exist on any visual-spatial field coordinate 
          ;preventing correct checks to be made on the state of the visual-spatial field.
          
          output-debug-message (word "I'll check that there are no illegal configurations of objects in 'visual-spatial-field-as-list-pattern'.") (who)
          output-debug-message (word "If there are, the previous planned action must have caused this and thus, the planned action will be unsuccessful if performed in reality.") (who)
          output-debug-message (word "Consequently, the move should be reversed in my visual-spatial field") (who)
          
          ;To check that the last planned action produces a valid visual-spatial field, we need to "cheat" and get the visual-spatial field at
          ;the time when the last planned action has actually been performed.
          let last-action-valid? (is-visual-spatial-field-state-valid-at-time? (chrest:get-attention-clock))
          
          ;============================;
          ;== REVERSE INVALID ACTION ==;
          ;============================;
          
          ifelse(not last-action-valid?)[
            output-debug-message ("The last action planned produces an invalid visual-spatial field state so I should reverse the action..." ) (who)
            set visual-spatial-field-moves ( generate-visual-spatial-field-moves (action-to-perform) (true) )
            
            ;To reverse the move, we need to "cheat" and pass the current attention free time of the model as a parameter to the "VisualSpatialField.move-objects" extension primitive so
            ;that the move is actually reversed (using the current environment time would result in the reversal not being performed because attention would be consumed at this time as
            ;far as the turtle's CHREST model is concerned).
            chrest:VisualSpatialField.move-objects (visual-spatial-field-moves) (chrest:get-attention-clock) (false)
            output-debug-message ( word "Completed reversing the move in the visual-spatial-field...") (who)
            
            output-debug-message ( word "Resetting my 'who-of-tile-last-pushed-in-plan' since, if I did push a tile, I shouldn't have because it resulted in the invalid state just reverted." ) (who)
            set who-of-tile-last-pushed-in-plan ""
          ]
          ;==============================;
          ;== ADD VALID ACTION TO PLAN ==;
          ;==============================;
          [
            output-debug-message ("Appending the action to perform and whether I used pattern-recognition to generate it to my plan...") (who)
            set plan ( lput ( list (action-to-perform) (used-pattern-recognition) ) (plan) )
            output-debug-message ( word "My plan turtle variable is now equal to: '" map ([list ( chrest:ItemSquarePattern.get-as-string (item (0) (?)) ) (item (1) (?))]) (plan) "'..." ) (who)
          ]
        ]
        ;=========================;
        ;== END PLAN GENERATION ==;
        ;=========================;
        [ 
          output-debug-message ( word "The local 'end-plan-generation?' variable is set to true so I should not plan any more.  To do this I need to set my 'generate-plan?' turtle variable to false..."  ) (who)
          set generate-plan? false
          
          output-debug-message ( word "I also need to set my 'deliberation-finished-time' turtle variable so that I simulate inactivity while deliberating.  This will be set to the sum of the current time (" report-current-time ") and the value of my 'time-spent-deliberating-on-plan' turtle variable (" time-spent-deliberating-on-plan ")..." ) (who)
          set deliberation-finished-time (report-current-time + time-spent-deliberating-on-plan)
          
          output-debug-message ( word "I'll also set my 'time-spent-deliberating-on-plan' turtle variable to 0 now since it has served its purpose for this plan generation cycle and should be reset for the next cycle..." ) (who)
          set time-spent-deliberating-on-plan 0
          
          output-debug-message ( word "I'll also set my 'current-search-iteration' turtle variable to 0 now since it should be reset for the next planning cycle..." ) (who)
          set current-search-iteration 0
          
          output-debug-message ( word "I'll also set my 'who-of-tile-last-pushed-in-plan' turtle variable to '' now since it should be reset for the next planning cycle..." ) (who)
          set who-of-tile-last-pushed-in-plan ""
          
          output-debug-message (word "My 'generate-plan?', 'deliberation-finished-time' and 'time-spent-deliberating-on-plan' turtle variables are now set to: '" generate-plan? "', '" deliberation-finished-time "' and '" time-spent-deliberating-on-plan "' respectively...") (who)
          output-debug-message (word "The final plan is set to: '" plan "'.") (who)
        ]
      ];construct-visual-spatial-field? check
    ];attention check
  ];CHREST turtle breed check
  
  set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "GENERATE-PUSH-CLOSET-TILE-TO-CLOSEST-HOLE" PROCEDURE ;;; - MAY NO LONGER BE REQUIRED DUE TO THE "DUMBING DOWN" OF AGENTS.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Enables a turtle to push its closest tile to its closest hole if it is possible
;;to do so.  The procedure will generate one of four action pattern classes for 
;;execution:
;;
;; 1. push-tile
;; 2. move-to-tile
;; 3. move-around-tile
;; 3. remain-stationary
;;
;;The procedure is complex and is broken into stages.  The stages are as follows:
;;
;; 1. The calling turtle checks to see if it is surrounded by immoveable objects
;;    in the scene passed.
;;
;;    1.1. The turtle is surrounded, report 'remain-stationary' action pattern. 
;;
;;    1.2  The turtle is not surrounded, go to step 2. 
;;
;; 2. All holes and their locations in the scene passed are retrieved.  Since this 
;;    procedure may be called by a turtle without first considering the scene passed, 
;;    a check is performed to see if any holes are retrieved.  The procedure may then 
;;    branch in two ways:
;;
;;    2.1. No holes are retrieved, report 'remain-stationary' action pattern.
;;    
;;    2.2. Holes are retrieved, so all tiles and their locations in the scene are 
;;         retrieved and the tile closest to the hole closest to the calling turtle's
;;         location in the scene passed is determined.  Go to step 3.
;;
;; 3. The calling turtle checks the distance between itself and the tile closest to the
;;    closest hole to the calling turtle's location in the scene passed. The procedure 
;;    may then branch in two ways:
;;
;;    3.1. If there is more than 1 patch seperating the closest tile and the calling turtle
;;         then the calling turtle will determine what heading needs to be adopted so that 
;;         it is facing the closest tile in the scene passed.  The calling turtle will then 
;;         check to see if it can move 1 patch forward along this heading in the scene passed.
;;         If there is some immovable object (a non-tile or a tile that is blocked from being 
;;         pushed along the heading being considered) on the patch ahead of the calling 
;;         turtle in the scene passed, the turtle will alter the heading by +/- 90.  This is 
;;         repeated until the patch immediately ahead along the heading is clear or has a 
;;         moveable tile on it.  The procedure can then branch in two ways:
;;
;;         3.1.1. There is a tile on the patch ahead.  In this case, a 'push-tile' action 
;;                pattern is reported so that the tile can be moved out of the way and the 
;;                calling turtle can reduce the distance between itself and the tile closest
;;                to the hole closest to the calling turtle in the scene passed.  Go to
;;                step 4.
;;
;;         3.1.2. There is nothing on the patch ahead.  In this case, a 'move-to-tile' action 
;;                pattern is generated so that the calling turtle can reduce the distance between
;;                itself and the tile closest to the hole closest to the calling turtle in the 
;;                scene passed.  Go to step 4.
;;
;;    3.2. If there is only 1 patch seperating the closest tile and the calling turtle in the 
;;         scene passed then the heading from the tile closest to the closest hole to the 
;;         calling turtle in the scene passed is determined.  This heading is compared against
;;         the heading from the calling turtle to the tile under consideration in the scene passed
;;         to determine if the calling turtle is already positioned correctly in the scene passed
;;         to push the tile towards the closest hole along the shortest distance. The procedure can 
;;         then branch in two ways:
;;
;;         3.2.1. The turtle is positioned correctly to push the tile being considered towards
;;                the closest hole along the heading that gives the shortest distance between 
;;                the tile and hole.  The calling turtle then checks to see if there is another
;;                turtle blocking the tile from being pushed along this heading.  The procedure 
;;                can then branch in two ways:
;;
;;                3.2.1.1. There is another turtle blocking the tile from being pushed.  In this
;;                         case, a 'remain-stationary' action pattern is reported.
;;
;;                3.2.1.2. There is nothing blocking the tile from being pushed.  In this case, 
;;                         a 'push-tile' action pattern is reported.
;;
;;         3.2.2. The turtle is not positioned correctly to push the tile being considered towards
;;                the closest hole along the heading that gives the shortest distance between 
;;                the tile and hole.  In this case, go to step 3.1 ignoring the distance check.
;;
;;         Name                   Data Type     Description
;;         ----                   ---------     -----------
;;@param   locations-of-tiles     List          A list of "jchrest.lib.Fixation" instances
;;                                              denoting the patches with tiles on that 
;;                                              should be considered.
;;@param   locations-of-holes     List          A list of "jchrest.lib.Fixation" instances
;;                                              denoting the patches with holes on that 
;;                                              should be considered.
;;@return  -                      String        The action to perform as an "item-square" 
;;                                              CHREST-compatible pattern.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to-report generate-push-closest-tile-to-closest-hole-action [locations-of-tiles locations-of-holes]
;  set debug-indent-level (debug-indent-level + 1)
;  output-debug-message ("EXECUTING THE 'generate-push-closest-tile-to-closest-hole-action' PROCEDURE...") ("")
;  set debug-indent-level (debug-indent-level + 1)
;  
;  output-debug-message ("Three local variables will be instantiated: 'location-of-self', 'remain-stationary' and 'action-pattern'...") (who)
;  output-debug-message ("The local 'location-of-self' variable will store my location in the scene passed...") (who)
;  output-debug-message ("The local 'remain-stationary' variable stores a boolean value that indicates if the calling turtle should remain stationary...") (who)
;  output-debug-message ("The local 'action-pattern' variable stores the action to be performed...") (who)
;  let location-of-self ( item (0) (get-locations-of-object-in-scene (self-token) (scene)) )
;  let remain-stationary (false)
;  let action-pattern ("")
; 
;  output-debug-message ("Checking to see if I'm surrounded, if I am, I can't push one of my closest tiles towards one of my closest holes...") (who)
;  ifelse( not (surrounded? (scene)) )[
;    
;    ;============================;
;    ;== DETERMINE CLOSEST HOLE ==;
;    ;============================;
;    
;    output-debug-message ("I'm not surrounded, I'll now calculate what tile(s) is(are) closest to the closest hole(s) I can see...") (who)
;    let hole-locations ( get-locations-of-object-in-scene (hole-token) (scene) )
;    
;    output-debug-message (word "Checking to see if I can see any holes since I may not be able to use visual-information to guide problem-solving.  If so I'll continue with this procedure...") (who)
;    ifelse(not empty? hole-locations)[
;    
;      output-debug-message (word "I can see holes in the scene passed, determining which one is the closest to me...") (who)
;      let closest-hole-location-and-manhattan-distance ( closest-object-in-set-to-specified-object-and-manhattan-distance (location-of-self) (hole-locations))
;      let closest-hole-location ( item (0) (closest-hole-location-and-manhattan-distance) )
;      output-debug-message (word "My closest hole is located at: '" closest-hole-location "'. I'll push the tile closest to this hole towards it or move towards the tile.  If more than one tile is a candidate I'll pick the tile closest to myself to push...") (who)
;      
;      output-debug-message ("Determing tile locations in scene passed...") (who)
;      let tile-locations ( get-locations-of-object-in-scene (tile-token) (scene) )
;
;      output-debug-message (word "Determining which tile (" tile-locations ") is closest to my closest-hole (" closest-hole-location ")...") (who)
;      let closest-tile-to-closest-hole-location-and-manhattan-distance ( closest-object-in-set-to-specified-object-and-manhattan-distance (closest-hole-location) (tile-locations) )
;      let closest-tile-to-closest-hole-location ( item (0) (closest-tile-to-closest-hole-location-and-manhattan-distance) )
;      
;      output-debug-message (word "Checking to see how far the closest tile to my closest hole (" closest-tile-to-closest-hole-location ") is from me...") (who)
;      let distance-from-me-to-closest-tile-to-closest-hole ( shortest-distance-from-location-to-location (location-of-self) (closest-tile-to-closest-hole-location) )
;      
;      output-debug-message (word "The distance between me and the tile closest to my closest hole is " distance-from-me-to-closest-tile-to-closest-hole ", checking to see if this is greater than 1...") (who)
;        
;        ifelse( distance-from-me-to-closest-tile-to-closest-hole > 1)[
;          output-debug-message ("The closest tile to my closest hole is more than 1 patch away so I need to move closer to it.") (who)
;          
;          ;==================================================================;
;          ;== SET HEADING DEPENDING UPON HEADING OF MYSELF TO CLOSEST TILE ==;
;          ;==================================================================;
;          
;          output-debug-message ("I'll face the tile indicated in my 'closest-tile' variable and then rectify my heading from there...") (who)
;          let heading-to-face (rectify-heading( (heading-that-gives-shortest-distance-from-location-to-location (location-of-self) (closest-tile-to-closest-hole-location)) ))
;          output-debug-message (word "Checking to see if there are any objects other than tiles on the patch ahead, if there is a tile, I'll check to see if it is blocked from being pushed...") (who)
;          
;          ;===================================================================================;
;          ;== CHECK TO SEE IF THERE IS AN UNMOVEABLE OBSTACLE ALONG HEADING TO CLOSEST TILE ==;
;          ;===================================================================================;
;          
;          while[ ( patch-ahead-blocked? (scene) (heading-to-face) ) ][
;            output-debug-message (word "The patch ahead with heading '" heading-to-face "' is blocked so I'll this heading by +/- 90 and check again...") (who)
;            set heading-to-face ( alter-heading-randomly-by-adding-or-subtracting-90 (heading-to-face) )
;          ]
;          output-debug-message (word "The patch ahead with heading " heading-to-face " isn't blocked.  Checking to see if the patch contains a tile, if so, I'll need to push it...") (who)
;          
;          let patch-ahead-contents ( get-object-and-patch-coordinates-ahead-of-location-in-scene (scene) (heading-to-face) (1) )
;          let patch-ahead-object ( chrest:get-item-from-item-square-pattern (patch-ahead-contents) )
;          output-debug-message (word "The patch ahead contains a '" patch-ahead-object "'...") (who)
;          
;          ifelse(patch-ahead-object = tile-token)[
;            output-debug-message (word "There is a moveable tile on the patch adjacent to me along heading '" heading-to-face "' so I'll push it along this heading..." ) (who)
;            set action-pattern (chrest:create-item-square-pattern (push-tile-token) (heading-to-face) (1))
;          ]
;          [
;            output-debug-message (word "The patch adjacent to me along heading '" heading-to-face "' is free so I'll move onto it..." ) (who)
;            set action-pattern (chrest:create-item-square-pattern (move-to-tile-token) (heading-to-face) (1))
;          ]
;        ]
;        ;====================================;
;        ;== CLOSEST TILE IS ADJACENT TO ME ==;
;        ;====================================;
;        [
;          output-debug-message ("My closest tile is adjacent to me (one patch away) so I should decide whether to push it into my closest hole (if possible), wait or re-position myself...") (who)
;          
;          ;===================================================================;
;          ;== CALCULATING LOCATION OF CLOSEST HOLE RELATIVE TO CLOSEST TILE ==;
;          ;===================================================================;
;          
;          output-debug-message ("Setting a local variable 'heading-from-closest-tile-to-closest-hole' to the heading that the tile closest to my closest hole would have to face to take the shortest path to my closest hole...")(who)
;          let heading-from-closest-tile-to-closest-hole ( heading-that-gives-shortest-distance-from-location-to-location (closest-tile-to-closest-hole-location) (closest-hole-location) )
;          
;          output-debug-message (word "The local 'heading-from-closest-tile-to-closest-hole' variable value is now set to: " heading-from-closest-tile-to-closest-hole ".  If this is less than 0 I'll convert it to its positive equivalent...") (who)
;          if(heading-from-closest-tile-to-closest-hole < 0)[
;            output-debug-message ("The local 'heading-from-closest-tile-to-closest-hole' variable is less than 0, converting it to its positive equivalent...") (who)
;            set heading-from-closest-tile-to-closest-hole (heading-from-closest-tile-to-closest-hole + 360)
;          ]
;          output-debug-message (word "The local 'heading-from-closest-tile-to-closest-hole' variable value is now set to: " heading-from-closest-tile-to-closest-hole"...") (who)
;          
;          output-debug-message (word "Setting the heading that I'd have to adopt to face the tile closest to my closest hole along the shortest distance between me and the tile...") (who)
;          let heading-from-me-to-tile-closest-to-my-closest-hole ( heading-that-gives-shortest-distance-from-location-to-location (location-of-self) (closest-tile-to-closest-hole-location) )
;          output-debug-message (word "The heading that I'd have to adopt to face the tile closest to my closest hole along the shortest distance between me and the tile is '" heading-from-me-to-tile-closest-to-my-closest-hole "'...") (who)
;          
;          output-debug-message ("Setting the local 'positioned-correctly?' variable to boolean false...") (who)
;          let positioned-correctly? false
;          
;          ;====================================================================;
;          ;== CLOSEST TILE IS DIRECTLY NORTH/EAST/SOUTH/WEST OF CLOSEST HOLE ==;
;          ;====================================================================;
;          
;          output-debug-message ("Checking to see if the tile closest to my closest hole is directly north/east/south/west of my closest hole...") (who)
;          ifelse(
;            (heading-from-closest-tile-to-closest-hole = 0) or
;            (heading-from-closest-tile-to-closest-hole = 90) or
;            (heading-from-closest-tile-to-closest-hole = 180) or
;            (heading-from-closest-tile-to-closest-hole = 270) 
;            )
;          [
;            output-debug-message ("The closest tile to my closest hole is directly north/east/south/west of my closest hole...") (who)
;            output-debug-message (word "Checking to see if I am positioned correctly to push the closest tile to my closest hole towards my closest hole without altering the current position of myself in 'scene' (is my heading to the tile along the shortest distance '" heading-from-me-to-tile-closest-to-my-closest-hole "', equal to the heading of the tile to my closest hole along the shortest distance '" heading-from-closest-tile-to-closest-hole "'?)...") (who)
;            if( heading-from-me-to-tile-closest-to-my-closest-hole = heading-from-closest-tile-to-closest-hole )[
;              set positioned-correctly? true
;            ]
;          ]
;          ;========================================================================;
;          ;== CLOSEST TILE IS NOT DIRECTLY NORTH/EAST/SOUTH/WEST OF CLOSEST HOLE ==;
;          ;========================================================================;
;          [
;            output-debug-message ("The tile closest to my closest hole is not directly north/east/south/west of my closest hole.  Determining where my closest hole is in relation to its closest tile...") (who)
;            output-debug-message ("I can push the tile closest to my closest hole in one of two directions in this case if I am positioned correctly in scene...") (who)
;            
;            if(
;              ( heading-from-closest-tile-to-closest-hole > 0 ) and 
;              ( heading-from-closest-tile-to-closest-hole < 90 )
;            )[
;              output-debug-message ("My closest hole is north-east of its closest tile...") (who)
;              output-debug-message ("Checking to see if the closest tile is adjacent to me to the north or east, if it is I can push it without adjusting my position...") (who)
;              
;              if(
;                ( heading-from-me-to-tile-closest-to-my-closest-hole = 0 ) or
;                ( heading-from-me-to-tile-closest-to-my-closest-hole = 90 )
;              )[
;                set positioned-correctly? true
;              ]
;            ]
;            
;            if(
;              ( heading-from-closest-tile-to-closest-hole > 90 ) and 
;              ( heading-from-closest-tile-to-closest-hole < 180 )
;            )[
;              output-debug-message ("My closest hole is south-east of its closest tile") (who)
;              output-debug-message ("Checking to see if the closest tile is adjacent to me to the east or south, if it is I can push it without adjusting my position...") (who)
;              
;              if(
;                ( heading-from-me-to-tile-closest-to-my-closest-hole = 90 ) or
;                ( heading-from-me-to-tile-closest-to-my-closest-hole = 180 )
;              )[
;                set positioned-correctly? true
;              ]
;            ]
;            
;            if(
;              ( heading-from-closest-tile-to-closest-hole > 180 ) and 
;              ( heading-from-closest-tile-to-closest-hole < 270 )
;            )[
;              output-debug-message ("My closest hole is south-west of its closest tile") (who)
;              output-debug-message ("Checking to see if the closest tile is adjacent to me to the south or west, if it is I can push it without adjusting my position...") (who)
;              
;              if(
;                ( heading-from-me-to-tile-closest-to-my-closest-hole = 180 ) or
;                ( heading-from-me-to-tile-closest-to-my-closest-hole = 270 )
;              )[
;                set positioned-correctly? true
;              ]
;            ]
;            
;            if(
;              ( heading-from-closest-tile-to-closest-hole > 270 ) and 
;              ( heading-from-closest-tile-to-closest-hole < 360 )
;            )[
;              output-debug-message ("My closest hole is north-west of its closest tile") (who) 
;              output-debug-message ("Checking to see if the closest tile is adjacent to me to the west or north, if it is I can push it without adjusting my position...") (who)
;              
;              if(
;                ( heading-from-me-to-tile-closest-to-my-closest-hole = 270 ) or
;                ( heading-from-me-to-tile-closest-to-my-closest-hole = 0 )
;              )[
;                set positioned-correctly? true
;              ]
;            ]
;          ]
;          
;          ;====================================;
;          ;== TURTLE IS POSITIONED CORRECTLY ==;
;          ;====================================;
;          
;          ifelse(positioned-correctly?)[
;            output-debug-message (word "I'm positioned correctly to push the tile closest to my closest hole towards my closest hole without changing position...") (who)
;            
;            ;============================================================================================;
;            ;== CHECK TO SEE IF THE TILE CLOSEST TO MY CLOSEST HOLE CAN BE PUSHED ALONG HEADING OR NOT ==;
;            ;============================================================================================;
;            output-debug-message (word "Checking to see if there is anything blocking the tile from being pushed along the heading I am to adopt to push so that the closest tile to my closest hole moves towards my closest hole (" heading-from-me-to-tile-closest-to-my-closest-hole ")...") (who)
;            ifelse( patch-ahead-blocked? (scene) (heading-from-me-to-tile-closest-to-my-closest-hole) )[
;              output-debug-message(word "There is something blocking the tile closest to my closest hole from being pushed along heading '" heading-from-me-to-tile-closest-to-my-closest-hole "'. This could only be another agent so I'll remain stationary (set the local 'remain-stationary' variable to true) and hope it moves...") (who)
;              set remain-stationary (true)
;            ]
;            [
;              output-debug-message(word "There is nothing blocking the tile closest to my closest hole from being pushed along heading '" heading-from-me-to-tile-closest-to-my-closest-hole "' so I'll push it along this heading...") (who)
;              set action-pattern (chrest:create-item-square-pattern (push-tile-token) (heading-from-me-to-tile-closest-to-my-closest-hole) (1))
;            ]
;          ]
;          ;========================================;
;          ;== TURTLE IS NOT POSITIONED CORRECTLY ==;
;          ;========================================;
;          [
;            output-debug-message ("I am not positioned correctly so I'll alter the value of 'heading-from-me-to-tile-closest-to-my-closest-hole' by +/- 90 to try and move into a correct position...") (who)
;            set heading-from-me-to-tile-closest-to-my-closest-hole ( alter-heading-randomly-by-adding-or-subtracting-90 (heading-from-me-to-tile-closest-to-my-closest-hole) )
;            
;            while[ patch-ahead-blocked? (scene) (heading-from-me-to-tile-closest-to-my-closest-hole) ][ 
;              output-debug-message (word "The patch ahead with heading " heading-from-me-to-tile-closest-to-my-closest-hole " is blocked so I'll alter the 'heading-from-me-to-tile-closest-to-my-closest-hole' value by +/- 90 and check again...") (who)
;              set heading-from-me-to-tile-closest-to-my-closest-hole ( alter-heading-randomly-by-adding-or-subtracting-90 (heading-from-me-to-tile-closest-to-my-closest-hole) )
;            ]
;            output-debug-message (word "The patch ahead with heading " heading-from-me-to-tile-closest-to-my-closest-hole " is either free or has a tile that can be pushed on it.  Checking to see if I need to push a tile or not...") (who)
;            
;            ;========================================================================;
;            ;== CHECK TO SEE IF I NEED TO PUSH A TILE TO MOVE ALONG HEADING OR NOT ==;
;            ;========================================================================;
;            let patch-ahead-contents ( get-object-and-patch-coordinates-ahead-of-location-in-scene (scene) (heading-from-me-to-tile-closest-to-my-closest-hole) (1) )
;            let object-on-patch-ahead ( chrest:get-item-from-item-square-pattern (patch-ahead-contents) )
;            
;            ifelse(object-on-patch-ahead = tile-token)[
;              output-debug-message (word "There is a moveable tile on the patch adjacent to me along heading '" heading-from-me-to-tile-closest-to-my-closest-hole "' so I'll push it..." ) (who)
;              set action-pattern ( chrest:create-item-square-pattern (push-tile-token) (heading-from-me-to-tile-closest-to-my-closest-hole) (1) )
;            ]
;            [
;              output-debug-message (word "The patch adjacent to me along heading '" heading-from-me-to-tile-closest-to-my-closest-hole "' is free so I'll move around the tile closest to my closest hole onto it..." ) (who)
;              set action-pattern (chrest:create-item-square-pattern (move-around-tile-token) (heading-from-me-to-tile-closest-to-my-closest-hole) (1))
;            ] 
;          ]
;        ]
;    ]
;    [
;      output-debug-message ("I can't see any holes so my 'visually-informed-problem-solving?' turtle variable must be 'false' and I've run this procedure at random.  Returning a 'procedure-not-applicable' action-pattern...") (who)
;      set action-pattern (chrest:create-item-square-pattern (procedure-not-applicable-token) (0) (0)) 
;    ]
;  ]
;  [
;    output-debug-message ("Since I'm surrounded I'll set the local 'remain-stationary' variable to 'true'...") (who)
;    set remain-stationary (true) 
;  ]
;  
;  output-debug-message (word "Checking to see if the 'remain-stationary' value (" remain-stationary ") is equal to 'true'...") (who)
;  if(remain-stationary)[
;    output-debug-message ("The local 'remain-stationary' value is set to 'true' so I'll remain stationary...") (who)
;    set action-pattern (chrest:create-item-square-pattern (remain-stationary-token) (0) (0))
;  ]
;  
;  output-debug-message (word "Reporexpected-visual-spatial-field-state-after-plan-generation-endsting the local 'action-pattern' variable that is set to: '" action-pattern "'...") (who)
;  set debug-indent-level (debug-indent-level - 2)
;  report (action-pattern)
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "GENERATE-RANDOM-MOVE-ACTION" PROCEDURE ;;; - NOT REQUIRED SINCE A TURTLE CAN JUST INVOKE "one-of (movement-headings)" SINCE THERE'S NO NEED TO CHECK IF TURTLE IS SURROUNDED.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;If the calling turtle is not surrounded, this procedure selects a heading at 
;;random from the global "movement-headings" variable with a 1 in n probablity 
;;where n is the number of elements in the global "movement-headings" variable.
;;If the calling turtle is surrounded a 'remain-stationary' action pattern will
;;be produced instead.
;;
;;If the patch immediately ahead with the randomly selected heading is blocked, 
;;this heading will no longer be able to be selected for this run of the procedure 
;;and a heading from those remaining will then be randomly selected with a 1 in
;;n probability where n is the number of headings still available.
;;
;;When a free patch has been found, an action pattern is created that indicates 
;;that the calling turtle will move 1 patch along this heading.
;;
;;         Name              Data Type     Description
;;         ----              ---------     -----------
;;@param   scene             List          A list of strings representing the environment to be used
;;                                         by this procedure.  Strings should be formatted as:
;;                                         "objectIdentifier;xcor;ycor".
;;@return  -                 String        The action to perform as an "item-square" 
;;                                         CHREST-compatible pattern.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>     
;to-report generate-random-move-action [scene]
;  set debug-indent-level (debug-indent-level + 1)
;  output-debug-message ("EXECUTING THE 'generate-random-move-action' PROCEDURE...") ("")
;  set debug-indent-level (debug-indent-level + 1)
;  
;  output-debug-message ( word "Instantiating two local variables: 'location-of-self' and 'action-pattern'...") (who)
;  output-debug-message ( word "The 'location-of-self' variable will store my location in the scene passed..." ) (who)
;  output-debug-message ( word "The 'action-pattern' variable will store the action generated by this procedure and will be reported..." ) (who)
;  let location-of-self ( item (0) (get-locations-of-object-in-scene (self-token) (scene)) )
;  let action-pattern ""
;  
;  output-debug-message ("Checking to see if I'm surrounded, if not, I'll continue...") (who)
;  ifelse(not surrounded? (scene))[
;    output-debug-message ("Since I'm not surrounded I'll continue trying to move randomly...") (who)
;    
;    let headings-available (movement-headings)
;    output-debug-message (word "Selecting a heading at random from those available in the local 'headings-available' list (" headings-available ") with a 1 in " (length headings-available) " probability...") (who)
;    let heading-to-face (one-of (headings-available))
;    
;    output-debug-message (word "Checking to see if the patch ahead with heading '" heading-to-face "' is blocked and whether I have any headings still available...") (who)
;    while[ not patch-ahead-empty? (scene) (heading-to-face) ][
;      
;      output-debug-message (word "Patch ahead with heading '' is blocked so I'll remove this heading from the local 'headings-available' list...") (who)
;      set headings-available (remove (heading-to-face) (headings-available) )
;      output-debug-message (word "The local 'headings-available' list is now equal to: '" headings-available "', picking a new heading with a 1 in " (length headings-available) " probability from this list if it isn't empty...") (who)
;        
;      ifelse( not empty? headings-available )[
;        set heading-to-face (one-of (headings-available))
;        output-debug-message (word "Checking to see if the patch ahead with heading '" heading-to-face "' is blocked...") (who)
;      ]
;      [
;        report (chrest:create-item-square-pattern (procedure-not-applicable-token) (0) (0) )
;      ]
;    ]
;    
;    set action-pattern (chrest:create-item-square-pattern (move-randomly-token) (heading-to-face) (1) )
;  ]
;  [
;    output-debug-message ("Since I'm surrounded I'll generate a 'remain-stationary' action...") (who)
;    set action-pattern (chrest:create-item-square-pattern (remain-stationary-token) (0) (0))
;  ]
;  
;  output-debug-message (word "Reporting the contents of the local 'action-pattern' variable: '" action-pattern "'...") (who)
;  set debug-indent-level (debug-indent-level - 2)
;  report (action-pattern)
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "GENERATE-VISUAL-CHUNK-FROM-SCENE" PROCEDURE ;;; - NOT REQUIRED DUE TO CHREST EXTENSION PRIMITIVES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Reports a CHREST-compatible visual chunk as a string containing "item-on-square" 
;;CHREST-compatible patterns for object information.
;;
;;Since each element in the "scene" list passed represents a patch in the environment, 
;;if that patch does not have an object-identifier or is set to "null" (indicating a 
;;"blind spot" in a mind's eye scene), then information about this patch is not added to
;;the string reported since such information is not useful to a turtle's LTM.
;;
;;         Name              Data Type     Description
;;         ----              ---------     -----------
;;@param   scene             List          A list of strings representing the environment to be used
;;                                         by this procedure.  Strings should be formatted as:
;;                                         "objectIdentifier;xcor;ycor".
;;@return  -                 String        A CHREST-compatible visual chunk formatted as:
;;                                         "[objectIdentifier xcor ycor] [...]".
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk> 
;to-report generate-visual-chunk-from-scene [scene]
;  set debug-indent-level (debug-indent-level + 1)
;  output-debug-message ("EXECUTING THE 'generate-visual-pattern-from-scene' PROCEDURE...") ("")
;  set debug-indent-level (debug-indent-level + 1)
;  
;  output-debug-message ("Setting a local 'visual-pattern' variable to be an empty string.  This variable will contain all relevant object information in the scene passed, formatted as 'item-on-square' patterns...") (who)
;  let visual-pattern ""
;
;  output-debug-message (word "Processing the contents of the 'scene' variable passed: " scene "...") (who)
;  foreach(scene)[
;    output-debug-message (word "Processing item: '" ? "'.  Splitting string on semi-colons (;) first...") (who)
;    let patch-info string:rex-split (?) (";")
;    output-debug-message (word "Result of split: '" patch-info "'...") (who)
;  
;    output-debug-message (word "Removing all white space from the object identifier extracted...") (who)
;    let object-identifier ( string:rex-replace-all (" ") (item (0) (patch-info)) ("") )
;    output-debug-message (word "Checking to see if the object identifier (" object-identifier ") is not empty or equal to 'null' (a blind-spot) since these patches are not used in LTM...") (who)
;    if( (object-identifier != "") and (object-identifier != "null") )[
;      
;      output-debug-message ("Splitting object identifier on occurrence of commas and processing each one...") (who)
;      foreach( string:rex-split (object-identifier) (",") )[
;        output-debug-message (word "Generating an item-square-pattern for object '" ? "' and appending this to the local 'minds-eye-scene' variable...") (who)
;        set visual-pattern ( word visual-pattern " " ( chrest:create-item-square-pattern (?) ( read-from-string(item (1) (patch-info)) ) ( read-from-string(item (2) (patch-info)) ) ) )
;      ]
;    ]
;  ]
;
;  set visual-pattern (string:rex-replace-all ("^\\s+") (visual-pattern) ("") )
;  output-debug-message (word "After processing all 'scene' items, the local 'visual-pattern' variable is equal to: '" visual-pattern "', this should be a string (" is-string? visual-pattern ").") (who)
;  set debug-indent-level (debug-indent-level - 2)
;  report visual-pattern
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "GENERATE-VISUAL-SPATIAL-FIELD-MOVES" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Generates moves for the calling turtle and other relevant objects to enable
;movement of these objects in the visual-spatial field of the calling turtle.
;
;         Name              Data Type                        Description
;         ----              ---------                        -----------
;@param   action-pattern    jchrest.lib.ItemSquarePattern    The action to perform.
;@param   reverse?          Boolean                          Set to true to reverse the action pattern 
;                                                            specified.  This can be used, for example, 
;                                                            when a move is performed in the visual-spatial field but 
;                                                            results in a visual-spatial field state which indicates
;                                                            that, if the move were to be performed in 
;                                                            reality, it would not be successful.  Therefore,
;                                                            the move performed should be "rolled-back" or
;                                                            reversed.                             
;@return  -                 List                             A 2D list, first dimension elements contain a 
;                                                            list of moves for one object and second 
;                                                            dimension elements contain the individual 
;                                                            object moves as "jchrest.lib.ItemSquare" 
;                                                            instances.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk> 
to-report generate-visual-spatial-field-moves [ action-pattern reverse? ]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'generate-visual-spatial-field-moves' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  let time-to-get-visual-spatial-field-at (report-current-time)
  if(reverse?)[
    set time-to-get-visual-spatial-field-at (chrest:get-attention-clock)
  ]
  let visual-spatial-field (chrest:VisualSpatialField.get-as-netlogo-list (time-to-get-visual-spatial-field-at) (false))
  output-debug-message (word "The visual-spatial field to work with is: " visual-spatial-field ) (who) 
  
  output-debug-message (word "Instantiating a local 2D list variable called 'object-moves' that will contain the moves for each object specified using the object's 'who' value and coordinates that are not relative to myself (as required by CHREST)...") (who)
  let object-moves []
  
  output-debug-message ( word "First, I need to parse the action to be performed...") (who)
  let action-identifier ( chrest:ItemSquarePattern.get-item (action-pattern) )
  let action-heading ( chrest:ItemSquarePattern.get-column (action-pattern) )
  let action-patches ( chrest:ItemSquarePattern.get-row (action-pattern) )
  output-debug-message ( word "Three local variables have been set: 'action-identifier', 'action-heading' and 'action-patches'.  Their values are: '" action-identifier "', '" action-heading "' and '" action-patches "', respectively...") (who) 
  
  ifelse(member? (action-identifier) (possible-actions) )[
    
    ;========================================;
    ;== CONSTRUCT MOVES FOR CALLING TURTLE ==;
    ;========================================;
    
    output-debug-message ( word "No matter what the action-pattern is, I will always need to move myself so I'll extract my location from the visual-spatial field now...") (who)
    let location-of-self ( item (0) (chrest:VisualSpatialField.get-object-locations (time-to-get-visual-spatial-field-at) (word who) (true)) )
    output-debug-message (word "Location of myself in scene: " location-of-self) (who)
    
    let self-who (word who)
    let self-xcor ( item (0) (location-of-self) )
    let self-ycor ( item (1) (location-of-self) )
    output-debug-message ( word "Location of myself xcor '" self-xcor "' and ycor '" self-ycor "'.  Adding this to the data structure containing my moves...") (who)
    
    let self-moves ( list (chrest:ItemSquarePattern.new (self-who) (self-xcor) (self-ycor)) )
    output-debug-message ( word "My moves is now equal to: " (map ([ chrest:ItemSquarePattern.get-as-string (?) ]) (self-moves)) ) (who)
      
    output-debug-message (word "Now I'll calculate my new location in my visual-spatial field after applying action " chrest:ItemSquarePattern.get-as-string (action-pattern) "...") (who)
    let new-location-of-self ""
    
    output-debug-message (word "I'll also calculate where a tile should be so that I can see if it is there should I need to move it") (who)
    let tile-location []
    
    ifelse( action-heading = 0 )[
      
      ifelse(reverse?)[
        set new-location-of-self ( chrest:ItemSquarePattern.new (self-who) (self-xcor) (self-ycor - action-patches) )
      ]
      [
        set new-location-of-self ( chrest:ItemSquarePattern.new (self-who) (self-xcor) (self-ycor + action-patches) )
      ]
      
      set tile-location (list (self-xcor) (self-ycor + 1))
    ]
    [
      ifelse( action-heading = 90 )[
        
        ifelse(reverse?)[
          set new-location-of-self ( chrest:ItemSquarePattern.new (self-who) (self-xcor - action-patches) (self-ycor) ) 
        ]
        [
          set new-location-of-self ( chrest:ItemSquarePattern.new (self-who) (self-xcor + action-patches) (self-ycor) ) 
        ]
        
        set tile-location (list (self-xcor + 1) (self-ycor))
      ]
      [
        ifelse( action-heading = 180 )[
          
          ifelse(reverse?)[
            set new-location-of-self ( chrest:ItemSquarePattern.new (self-who) (self-xcor) (self-ycor + action-patches) )
          ]
          [
            set new-location-of-self ( chrest:ItemSquarePattern.new (self-who) (self-xcor) (self-ycor - action-patches) )
          ]
          
          set tile-location (list (self-xcor) (self-ycor - 1))
        ]
        [
          ifelse( action-heading = 270 )[
            
            ifelse(reverse?)[
              set new-location-of-self ( chrest:ItemSquarePattern.new (self-who) (self-xcor + action-patches) (self-ycor) )
            ]
            [
              set new-location-of-self ( chrest:ItemSquarePattern.new (self-who) (self-xcor - action-patches) (self-ycor) )
            ]
            
            set tile-location (list (self-xcor - 1) (self-ycor))
          ]
          [
            set debug-indent-level (debug-indent-level - 2)
            error ( word "Occurred when running the 'generate-visual-spatial-field-moves' procedure and attempting to determine the calling turtle's new x/ycor: the heading specified (" action-heading ") in the action pattern passed (" action-pattern ") is not supported by this procedure." )
          ]
        ]
      ]
    ]
    output-debug-message ( word "My new location in my visual-spatial field will be: '" (chrest:ItemSquarePattern.get-as-string (new-location-of-self)) "', appending this to the moves for myself..." ) (who)
    set self-moves ( lput (new-location-of-self) (self-moves) )
    output-debug-message ( word "My moves is now equal to: " (map ([ chrest:ItemSquarePattern.get-as-string (?) ]) (self-moves)) ) (who)
    
    set object-moves (lput (self-moves) (object-moves))
    
    ;==============================;
    ;== CONSTRUCT MOVES FOR TILE ==;
    ;==============================;  
    
    output-debug-message (word "Checking to see if I need to add tile moves to this list, i.e. does the action pattern passed instruct me to push/pull a tile?..." ) (who)
    output-debug-message (word "The location of the tile to move (if necessary) is set to: " tile-location) (who)
    ifelse(action-identifier = push-tile-token)[
      output-debug-message (word "The action identifier indicates that I should push/pull a tile so a tile's location in scene should also be modified.") (who)

      

      output-debug-message (word "If this is a reversal of a 'push-tile' move, I need to see if the specific tile to be pulled still exists (its object representation may have decayed in my visual-spatial field") (who)
      let search-using-id? (false)
      let object (tile-token)
      if(not empty? who-of-tile-last-pushed-in-plan)[
        set search-using-id? (true)
        set object (who-of-tile-last-pushed-in-plan)
      ]      output-debug-message (word "Checking to see if " object " is on coordinates " tile-location " in my visual-spatial field...") (who)
      if( chrest:VisualSpatialField.is-object-on-square? (time-to-get-visual-spatial-field-at) (object) (item (0) (tile-location)) (item (1) (tile-location)) (search-using-id?) )[
        
        output-debug-message ( word "Object " object " is on coordinates " tile-location " in my visual-spatial field so I'll continue to generate a push/pull move...") (who)
        let current-xcor-of-tile ( item (0) (tile-location) )
        let current-ycor-of-tile ( item (1) (tile-location) )
        
        output-debug-message ( word "Since I need to specify an object's ID when performing visual-spatial moves, I need to set the tile to move's 'who' number so it can be pushed/pulled" ) (who)
        output-debug-message ( word "To do this, I'll first check to see if my 'who-of-tile-last-pushed-in-plan' turtle variable is empty (this will not be the case if this move is a reversal of a previously planned 'push-tile' action") (who)
        if(empty? who-of-tile-last-pushed-in-plan)[
          
          output-debug-message (word "My 'who-of-tile-last-pushed-in-plan' turtle variable is empty so I'll set the tile to move to the who of the tile on coordinates " tile-location) (who)
          ;This move isn't a reversal so there should only be one tile on the coordinates indicated.
       
          set who-of-tile-last-pushed-in-plan ( item (0) ( ;Get identifier for object
              item (0) ( ;Get first object on row
                item (current-ycor-of-tile) ( ;Get row contents
                  item (current-xcor-of-tile) (visual-spatial-field) ;Get col contents
                )
              ) 
            )
          )
        ]
        
        let tile-moves ( list (chrest:ItemSquarePattern.new (who-of-tile-last-pushed-in-plan) (current-xcor-of-tile) (current-ycor-of-tile)) )
        output-debug-message ( word "The tile moves data structure is now equal to: " (map ([ chrest:ItemSquarePattern.get-as-string (?) ]) (tile-moves)) ) (who)
        
        let new-location-of-tile ""
        ifelse( action-heading = 0 )[
          ifelse(reverse?)[
            set new-location-of-tile ( chrest:ItemSquarePattern.new (who-of-tile-last-pushed-in-plan) (current-xcor-of-tile) (current-ycor-of-tile - action-patches) )
          ]
          [
            set new-location-of-tile ( chrest:ItemSquarePattern.new (who-of-tile-last-pushed-in-plan) (current-xcor-of-tile) (current-ycor-of-tile + action-patches) )
          ]
        ]
        [
          ifelse( action-heading = 90 )[
            ifelse(reverse?)[
              set new-location-of-tile ( chrest:ItemSquarePattern.new (who-of-tile-last-pushed-in-plan) (current-xcor-of-tile - action-patches) (current-ycor-of-tile) ) 
            ]
            [
              set new-location-of-tile ( chrest:ItemSquarePattern.new (who-of-tile-last-pushed-in-plan) (current-xcor-of-tile + action-patches) (current-ycor-of-tile) ) 
            ]
          ]
          [
            ifelse( action-heading = 180 )[
              ifelse(reverse?)[
                set new-location-of-tile ( chrest:ItemSquarePattern.new (who-of-tile-last-pushed-in-plan) (current-xcor-of-tile) (current-ycor-of-tile + action-patches) )
              ]
              [
                set new-location-of-tile ( chrest:ItemSquarePattern.new (who-of-tile-last-pushed-in-plan) (current-xcor-of-tile) (current-ycor-of-tile - action-patches) )
              ]
            ]
            [
              ifelse( action-heading = 270 )[
                ifelse(reverse?)[
                  set new-location-of-tile ( chrest:ItemSquarePattern.new (who-of-tile-last-pushed-in-plan) (current-xcor-of-tile + action-patches) (current-ycor-of-tile) )
                ]
                [
                  set new-location-of-tile ( chrest:ItemSquarePattern.new (who-of-tile-last-pushed-in-plan) (current-xcor-of-tile - action-patches) (current-ycor-of-tile) )
                ]
              ]
              [
                set debug-indent-level (debug-indent-level - 2)
                error ( word "Occurred when running the 'generate-visual-spatial-field-moves' procedure and attempting to determine a tile's new x/ycor: the heading specified (" action-heading ") in the action pattern passed (" action-pattern ") is not supported by this procedure." )
              ]
            ]
          ]
        ]
        output-debug-message ( word "The tile's new location in my visual-spatial field will be: '" (chrest:ItemSquarePattern.get-as-string (new-location-of-tile)) "'.  Appending this to the data structure containing tile moves..." ) (who)
        set tile-moves ( lput (new-location-of-tile) (tile-moves))
        output-debug-message ( word "The tile moves data structure is now equal to: '" ( map ([chrest:ItemSquarePattern.get-as-string (?)]) (tile-moves) ) "'..." ) (who)
        
        output-debug-message (word "Adding the tile moves data structure to the local 'object-moves' list.  Its insertion point will be determined by whether the action is to be reversed or not...") (who)
        ifelse(reverse?)[
          output-debug-message (word "The action is to be reversed so I should pull the tile and therefore move myself in the visual-spatial field before the tile to ensure that there's no chance of myself and the tile co-habiting a square in my visual-spatial field (an illegal state)...") (who)
          set object-moves (lput (tile-moves) (object-moves))
        ]
        [
          output-debug-message (word "The action is not to be reversed so I should push the tile and therefore move the tile in the visual-spatial field before myself to ensure that there's no chance of myself and the tile co-habiting a square in my visual-spatial field (an illegal state)...") (who)
          set object-moves (fput (tile-moves) (object-moves))
        ]
      ]
    ]
    [
      output-debug-message ("I'm not to push a tile") (who)
    ]
  ]
  [
    set debug-indent-level (debug-indent-level - 2)
    error ( word "Occurred when running the 'generate-visual-spatial-field-moves' procedure: the action-identifier (" action-identifier ") in the action pattern passed (" action-pattern ") is not listed in the global 'possible-actions' list.  Please rectify." )
  ]
  
  output-debug-message (word "Reporting '" (map ([map ([chrest:ItemSquarePattern.get-as-string (?)]) (?)]) (object-moves)) "'...") (who)
  set debug-indent-level (debug-indent-level - 2)
  report object-moves
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "GET-OBJECT-AND-PATCH-COORDINATES-AHEAD-OF-LOCATION-IN-SCENE" PROCEDURE ;;; - MAY NO LONGER BE NEEDED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Reports information regarding the object located on the patch ahead 
;;with the heading and location specified in the scene passed.
;;
;;NOTE: This procedure does not support environment wrapping and therefore care
;;      should be used when passing a scene consisting of absolute coordinates
;;      rather than a scene consisting of coordinates that are relative to the
;;      agent's current location.
;;
;;         Name              Data Type          Description
;;         ----              ---------          -----------
;;@param   scene             jchrest.lib.Scene  The scene to be evaluated.        
;;@param   heading-to-check  Number             The heading from the location specified
;;                                              to check.
;;@param   patches-ahead     Number             The number of patches from from the source
;;                                              to check along the heading specified.
;;@return  -                 List               Contains 4 elements:
;;
;;                                                1. The ID of the object on the target patch.
;;                                                2. The class of the object on the target patch.
;;                                                3. The xcor of the target patch
;;                                                4. The ycor of the target patch
;;
;;                                              If the patch specified is not in the scene then
;;                                              elements 1 and 2 will be empty strings.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk> 
;to-report get-object-and-patch-coordinates-ahead-of-location-in-scene [scene heading-to-check patches-ahead]
;  set debug-indent-level (debug-indent-level + 1)
;  output-debug-message ("EXECUTING THE 'get-object-and-patch-coordinates-ahead-of-location-in-scene' PROCEDURE...") ("")
;  set debug-indent-level (debug-indent-level + 1)
;  
;  output-debug-message (word "Getting location of self in 'scene' passed and setting x/ycor values to local variables 'source-location-xcor' and 'source-location-ycor'...") (who)   
;  let source-location ( chrest:Scene.get-location-of-creator (scene) )      
;  let source-location-xcor ( item (0) (source-location) )       
;  let source-location-ycor ( item (1) (source-location) )         
;  output-debug-message (word "The local 'source-location-xcor' and 'source-location-ycor' variables are equal to '" source-location-xcor "' and '" source-location-ycor "', respectively...") (who)      
;  
;  output-debug-message (word "Calculating target patch x/ycor by determining the heading along which to check (" heading-to-check ") and setting these values to 'target-location-xcor' and 'target-location-ycor'...") (who)   
;  let target-location-xcor 0   
;  let target-location-ycor 0      
;  
;  ifelse(heading-to-check = 0)[     
;    set target-location-xcor (source-location-xcor)     
;    set target-location-ycor (source-location-ycor + patches-ahead)   
;  ]   
;  [     
;    ifelse(heading-to-check = 90)[       
;      set target-location-xcor (source-location-xcor + patches-ahead)       
;      set target-location-ycor (source-location-ycor)     
;    ]     
;    [       
;      ifelse(heading-to-check = 180)[         
;        set target-location-xcor (source-location-xcor)         
;        set target-location-ycor (source-location-ycor - patches-ahead)       
;      ]       
;      [         
;        ifelse(heading-to-check = 270)[           
;          set target-location-xcor (source-location-xcor - patches-ahead)           
;          set target-location-ycor (source-location-ycor)         
;        ]         
;        [           
;          error (word "The heading specified (" heading-to-check ") is not supported by the 'get-object-and-patch-coordinates-ahead-of-location-in-scene' procedure.")         
;        ]       
;      ]     
;    ]   
;  ]   
;  output-debug-message (word "The local 'target-location-xcor' and 'target-location-ycor' variables are set to '" target-location-xcor "' and '" target-location-ycor "', respectively...") (who)      
;  
;  let target-patch-contents ( chrest:Scene.get-square-contents-as-netlogo-list (scene) (target-location-xcor) (target-location-ycor) )
;  output-debug-message (word "Result of getting contents of the target location from scene: " target-patch-contents) (who)
;  
;  let list-to-report (list
;    ("") 
;    ("") 
;    (target-location-xcor) 
;    (target-location-ycor)
;  )
;  
;  if(not empty? target-patch-contents)[
;    set list-to-report ( replace-item (0) (list-to-report) (item (0) (target-patch-contents)) )
;    set list-to-report ( replace-item (1) (list-to-report) (item (1) (target-patch-contents)) )
;  ]
;  
;  output-debug-message (word "Reporting: " list-to-report) (who)
;  set debug-indent-level (debug-indent-level - 2)
;  report list-to-report
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "GET-OBSERVABLE-ENVIRONMENT" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Reports what the calling turtle can "see" as a 2D list.  Each inner list contains 4 elements:
;
; - The x-coordinate offset of the patch from the calling turtle.
; - The y-coordinate offset of the patch from the calling turtle.
; - The 'who' value of the turtle on the patch.
; - The object class of the turtle on the patch (see jchrest.lib.TileworldDomain).
;
;If a patch is empty then the 3rd and 4th elements are set to the "empty-patch-token" specified.
;The patches will be ordered from west -> east and then from south -> north.  Therefore, the
;south-western patch will appear first and the north-eastern patch will appear last. 
;
;         Name   Data Type     Description
;         ----   ---------     -----------
;@return  -      List          See above.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
to-report get-observable-environment
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'get-observable-environment' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  let observable-environment []
  
  ;Set 'xCorOffset' and 'yCorOffset' to the south-western point of the calling
  ;turtle's sight radius by converting the 'sight-radius' variable into its
  ;negative value i.e. 3 becomes -3.
  output-debug-message (word "My max xCorOffset and yCorOffset is: '" sight-radius "'.  This is how many patches north, east, south and west of my current location that I can 'see'.") (who)
  output-debug-message ("Setting the value of the local 'xCorOffset' and 'yCorOffset' variables (should be the negative value of my 'sight-radius' variable value)...") (who)
  let xCorOffset (sight-radius * -1)
  let yCorOffset (sight-radius * -1)
  
  while[ycorOffset <= sight-radius][
    output-debug-message (word "Checking for turtles at patch with xCorOffset '" xCorOffset "' and yCorOffset '" yCorOffset "' from the patch I'm on...") (who)
    
    ;If the "debug?" global variable is set to true then ask the current patch
    ;to set its colour to that stored in the calling turtle's "sight-radius-colour'
    ;variable.  This will result in the calling turtle's sight-radius being displayed
    ;graphically in the environment. 
    if(debug?)[
      ask patch-at xCorOffset yCorOffset [
        set pcolor ([sight-radius-colour] of myself)
      ]
    ]
    
    let square-content (list (xCorOffset) (yCorOffset) (empty-patch-token) (empty-patch-token))
    let turtles-at-x-and-y-offset ( (turtles-at xCorOffset yCorOffset) with [hidden? = false] )
    
    if(any? turtles-at-x-and-y-offset)[
      ask(turtles-at-x-and-y-offset)[
        ifelse(self = myself)[
          set square-content (replace-item (2) (square-content) ([who] of myself))
          set square-content (replace-item (3) (square-content) (self-token))
        ]
        [          
          ifelse( breed = tiles)[
            set square-content (replace-item (2) (square-content) ([who] of self))
            set square-content (replace-item (3) (square-content) (tile-token))
          ]
          [
            ifelse( breed = holes)[
              set square-content (replace-item (2) (square-content) ([who] of self))
              set square-content (replace-item (3) (square-content) (hole-token))
            ]
            [
              set square-content (replace-item (2) (square-content) ([who] of self))
              set square-content (replace-item (3) (square-content) (opponent-token))
            ]
          ]
        ]
      ]
    ]
    
    set observable-environment (lput (square-content) (observable-environment))
      
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; SET VIEW TO 1 PATCH EAST ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    set xCorOffset (xCorOffset + 1)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; RESET VIEW TO WESTERN-MOST PATCH AND 1 PATCH NORTH IF EASTERN-MOST PATCH REACHED ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    if(xCorOffset > sight-radius)[
      output-debug-message (word "The local 'xCorOffset' variable value: '" xCorOffset "' is greater than my 'sight-radius' variable value '" sight-radius "' so I'll reset the local 'xCorOffset' variable value to: '" (sight-radius * -1) "'.") (who)
      set xCorOffset (sight-radius * -1)
      set yCorOffset (yCorOffset + 1)
    ]
  ]
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; RESET THE COLOUR OF PATCHES THAT CAN BE SEEN BY THE TURTLE ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  if(debug?)[
    set xCorOffset (sight-radius * -1)
    set yCorOffset (sight-radius * -1)
    
    while[ycorOffset <= sight-radius][
      ask patch-at xCorOffset yCorOffset [
        set pcolor black
      ]
      
      set xCorOffset (xCorOffset + 1)
      if(xCorOffset > sight-radius)[
        set xCorOffset (sight-radius * -1)
        set yCorOffset (yCorOffset + 1)
      ]
    ]
  ]
  
  output-debug-message (word "This is what I can see: " observable-environment "." ) (who)
  
  set debug-indent-level (debug-indent-level - 2)
  report (observable-environment)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "GET-OBSERVABLE-ENVIRONMENT-AS-LIST-PATTERN" PROCEDURE ;;; - PROBABLY NO LONGER REQUIRED DUE TO "get-observable-environment" NOW BEING USED (CAN GET RESULT OF THAT AS LIST PATTERN USING EXTENSION PRIMITIVES)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Enables the calling turtle to look at and report what it can "see" in
;the environment.  
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@return  -                 List          A CHREST-compatible "ListPattern" instance containing 
;                                         "ItemSquarePattern" instances that represent what the
;                                         calling turtle can currently "see".  The "xcor" and 
;                                         "ycor" values of these "ItemSquarePattern" instances 
;                                         are relative to the calling turtle's current location.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to-report get-observable-environment-as-list-pattern
;  set debug-indent-level (debug-indent-level + 1)
;  output-debug-message ("EXECUTING THE 'get-observable-environment-as-list-pattern' PROCEDURE...") ("")
;  set debug-indent-level (debug-indent-level + 1)
;  
;  let observable-environment []
;  
;  ;Set 'xCorOffset' and 'yCorOffset' to the south-western point of the calling
;  ;turtle's sight radius by converting the 'sight-radius' variable into its
;  ;negative value i.e. 3 becomes -3.
;  output-debug-message (word "My max xCorOffset and yCorOffset is: '" sight-radius "'.  This is how many patches north, east, south and west of my current location that I can 'see'.") (who)
;  output-debug-message ("Setting the value of the local 'xCorOffset' and 'yCorOffset' variables (should be the negative value of my 'sight-radius' variable value)...") (who)
;  let xCorOffset (sight-radius * -1)
;  let yCorOffset (sight-radius * -1)
;  
;  while[ycorOffset <= sight-radius][
;    output-debug-message (word "Checking for turtles at patch with xCorOffset '" xCorOffset "' and yCorOffset '" yCorOffset "' from the patch I'm on...") (who)
;    
;    ;If the "debug?" global variable is set to true then ask the current patch
;    ;to set its colour to that stored in the calling turtle's "sight-radius-colour'
;    ;variable.  This will result in the calling turtle's sight-radius being displayed
;    ;graphically in the environment. 
;    if(debug?)[
;      ask patch-at xCorOffset yCorOffset [
;        set pcolor ([sight-radius-colour] of myself)
;      ]
;    ]
;    
;    let objects (list (empty-patch-token) )
;    let turtles-at-x-and-y-offset ( (turtles-at xCorOffset yCorOffset) with [hidden? = false] )
;    
;    if(any? turtles-at-x-and-y-offset)[
;      set objects (but-first (objects))
;      
;      ask(turtles-at-x-and-y-offset)[
;        ifelse(self = myself)[
;          set objects (lput (self-token) (objects))
;        ]
;        [          
;          ifelse( breed = tiles)[
;            set objects (lput (tile-token) (objects))
;          ]
;          [
;            ifelse( breed = holes)[
;              set objects (lput (hole-token) (objects))
;            ]
;            [
;              set objects (lput (opponent-token) (objects))
;            ]
;          ]
;        ]
;      ]
;    ]
;    
;    output-debug-message (word "I can see the following on the patch with xCorOffset '" xCorOffset "' and yCorOffset '" yCorOffset "' from the patch I'm on: " objects) (who)
;    foreach(objects)[
;      set observable-environment (lput (chrest:create-item-square-pattern (?) (xCorOffset) (yCorOffset)) (observable-environment))
;    ]
;      
;    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    ;;; SET VIEW TO 1 PATCH EAST ;;;
;    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    
;    set xCorOffset (xCorOffset + 1)
;    
;    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    ;;; RESET VIEW TO WESTERN-MOST PATCH AND 1 PATCH NORTH IF EASTERN-MOST PATCH REACHED ;;;
;    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    
;    if(xCorOffset > sight-radius)[
;      output-debug-message (word "The local 'xCorOffset' variable value: '" xCorOffset "' is greater than my 'sight-radius' variable value '" sight-radius "' so I'll reset the local 'xCorOffset' variable value to: '" (sight-radius * -1) "'.") (who)
;      set xCorOffset (sight-radius * -1)
;      set yCorOffset (yCorOffset + 1)
;    ]
;  ]
;  
;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  ;;; RESET THE COLOUR OF PATCHES THAT CAN BE SEEN BY THE TURTLE ;;;
;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  
;  if(debug?)[
;    set xCorOffset (sight-radius * -1)
;    set yCorOffset (sight-radius * -1)
;    
;    while[ycorOffset <= sight-radius][
;      ask patch-at xCorOffset yCorOffset [
;        set pcolor black
;      ]
;      
;      set xCorOffset (xCorOffset + 1)
;      if(xCorOffset > sight-radius)[
;        set xCorOffset (sight-radius * -1)
;        set yCorOffset (yCorOffset + 1)
;      ]
;    ]
;  ]
;  
;  let observable-environment-as-list-pattern (chrest:create-list-pattern ("visual") (observable-environment))
;  output-debug-message (word "This is what I can see in total: " (chrest:get-list-pattern-as-string (observable-environment-as-list-pattern)) "." ) (who)
;  
;  set debug-indent-level (debug-indent-level - 2)
;  report (observable-environment-as-list-pattern)
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "HEADING-THAT-GIVES-SHORTEST-DISTANCE-FROM-LOCATION-TO-LOCATION" PROCEDURE ;;; - DOESN'T APPEAR TO BE USED ANYMORE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Reports the heading that should be adopted in order to travel the shortest 
;;distance from the specified location to the specified location.
;;
;;         Name              Data Type     Description
;;         ----              ---------     -----------
;;@param   from-location     String        The location to face from in a scene formatted 
;;                                         as a string representation of CHREST-compatible
;;                                         "ItemSquarePattern" instances, i.e. 
;;                                         "[object-id xcor ycor]".
;;@param   to-location       String        The location to face to in a scene formatted 
;;                                         as a string representation of CHREST-compatible
;;                                         "ItemSquarePattern" instances, i.e. 
;;                                         "[object-id xcor ycor]".
;;@return  -                 Number        The heading that faces from the location specified
;;                                         to the location specified.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
;to-report heading-that-gives-shortest-distance-from-location-to-location [face-from face-to]
;  set debug-indent-level (debug-indent-level + 1)
;  output-debug-message ("EXECUTING THE 'heading-that-gives-shortest-distance-from-location-to-location' PROCEDURE...") ("")
;  set debug-indent-level (debug-indent-level + 1) 
;  
;  let face-from-xcor ( chrest:get-column-from-item-square-pattern (face-from) )
;  let face-from-ycor ( chrest:get-row-from-item-square-pattern (face-from) )
;  output-debug-message (word "The local 'face-from-xcor' and 'face-from-ycor' variables are now set to '" face-from-xcor "' and '" face-from-ycor "', respectively...") (who)
;  
;  let face-to-xcor ( chrest:get-column-from-item-square-pattern (face-to) )
;  let face-to-ycor ( chrest:get-row-from-item-square-pattern (face-to) )
;  output-debug-message (word "The local 'face-to-xcor' and 'face-to-ycor' variables are now set to '" face-to-xcor "' and '" face-to-ycor "', respectively...") (who)
;  
;  set debug-indent-level (debug-indent-level - 2)
;  report extras:towards (face-from-xcor) (face-from-ycor) (face-to-xcor) (face-to-ycor) (true)
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "IS-VISUAL-SPATIAL-FIELD-STATE-VALID-AT-TIME?" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Determines whether the calling turtle's visual-spatial field state is valid at a particular time.
;For a visual-spatial field's state to be valid, all of the following must be f:
;
; 1) A tile:
;   a. Exists on the same patch as another tile
;   b. Exists on the same patch as an opponent
; 2) The self:
;   a. Exists on the same patch as a hole
;   b. Exists on the same patch as a tile
;   c. Exists on the same patch as an opponent
;
;Note that only the self and tiles are checked since these are the only
;objects that can be moved by a calling turtle in its visual-spatial field.
;The calling turtle does not check that the tile is on the same patch as
;the self (and vice-versa) since the self always moves with a tile during 
;visual-spatial field object movement.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@param   state-at-time     Number        The time at which to check the validity of the visual-spatial
;                                         field at.
;@return  -                 Boolean       True if the visual-spatial field state is valid at the time
;                                         specified, false if not.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
to-report is-visual-spatial-field-state-valid-at-time? [state-at-time]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'is-visual-spatial-field-state-valid-at-time' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1) 
  
  let columns (chrest:VisualSpatialField.get-as-netlogo-list (state-at-time) (false))
  output-debug-message (word "Visual-spatial field at time " state-at-time ": " columns) (who)
  let col 0
  
  while[col < length columns][
    let rows (item (col) (columns))
    let row 0
    
    while [row < length rows] [
      let objects (item (row) (rows))
      let object-index 0
      output-debug-message (word "Checking coordinates " col ", " row) (who)
      set debug-indent-level (debug-indent-level + 1)
      
      let hole-counter 0
      let opponent-counter 0
      let self-counter 0
      let tile-counter 0
      
      while [object-index < length objects][
        let object (item (object-index) (objects))
        let object-class (item (1) (object))
        output-debug-message (word "Object class: '" object-class "'" ) (who)
        
        if(object-class = hole-token)[
          set hole-counter (hole-counter + 1)
        ]
        
        if(object-class = opponent-token)[
          set opponent-counter (opponent-counter + 1)
        ]
        
        if(object-class = chrest:Scene.get-creator-token)[
          set self-counter (self-counter + 1)
        ]
        
        if(object-class = tile-token)[
          set tile-counter (tile-counter + 1)
        ]
        
        set object-index (object-index + 1)
      ]
      set debug-indent-level (debug-indent-level - 1)
      
      output-debug-message (word "There's " hole-counter " hole(s), " opponent-counter " opponent(s), " self-counter " of me and " tile-counter " tile(s) here" ) (who)
      if(
        (tile-counter > 1) or 
        ((tile-counter = 1 or self-counter = 1) and opponent-counter > 0) or
        (self-counter = 1 and (hole-counter > 0 or tile-counter > 0))
      )[
        output-debug-message (word "This indicates an invalid visual-spatial field state so false will be reported." ) (who)
        set debug-indent-level (debug-indent-level - 2)
        report (false)
      ]
      
      set row (row + 1)
    ]
    
    set col (col + 1)
  ]
  
  output-debug-message (word "The visual-spatial field state must be valid at time " state-at-time " so true will be reported." ) (who)
  set debug-indent-level (debug-indent-level - 2)
  report (true)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "LOAD-ACTION" PROCEDURE ;;; - CHECK TO SEE IF THIS IS STILL NEEDED!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Sets the calling turtle's: 
;; - 'next-action-to-perform' variable to the parameter passed to this procedure.
;; - 'visual-pattern-used-to-generate-action' variable to the value of the 
;;   calling turtle's 'current-visual-pattern' variable
;; - 'time-to-perform-next-action' variable to the current time plus the value 
;;   passed in the 'deliberation-time' parameter and the calling turtle's 
;;   'action-performance-time' variable.
;;
;;         Name              Data Type     Description
;;         ----              ---------     -----------
;;@param   action-pattern    String        The action-pattern that is to be set to the calling
;;                                         turtle's 'next-action-to-perform' variable.  This 
;;                                         action may then be performed in the future.
;;@param   deliberation-time Number        The length of time that must pass to simulate the 
;;                                         time it took for the calling turtle to deliberate
;;                                         about the action that is to be loaded.  This, in 
;;                                         conjunction with the value of the calling turtle's
;;                                         'action-performance-time', will simulate one entire
;;                                         decision-making and action performance cycle.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to load-action [action-pattern deliberation-time]
;  set debug-indent-level (debug-indent-level + 1)
;  output-debug-message ("EXECUTING THE 'load-action' PROCEDURE...") ("")
;  set debug-indent-level (debug-indent-level + 1)
;  
;  output-debug-message (word "Setting my 'next-action-to-perform' variable value to: '" action-pattern "' and my 'visual-pattern-used-to-generate-action' variable value to: '" current-visual-pattern "'...") (who)
;  set next-action-to-perform (action-pattern)
;  set visual-pattern-used-to-generate-action (current-visual-pattern)
;  
;  let time (precision (report-current-time + deliberation-time + action-performance-time) (1))
;  output-debug-message ( word "Setting my 'time-to-perform-next-action' variable to the current time (" report-current-time ") + 'deliberation-time' (" deliberation-time ") + 'action-performance-time (" action-performance-time ") = " time "..." ) (who)
;  set time-to-perform-next-action (time)
;  
;  output-debug-message (word "I'm going to perform '" next-action-to-perform "' at time: '" time-to-perform-next-action "' and my 'visual-pattern-used-to-generate-action' variable is set to: '" visual-pattern-used-to-generate-action "'." ) (who)
;  set debug-indent-level (debug-indent-level - 2)
;end

;;;;;;;;;;;;;;;;;;;;;;;;
;;; "MOVE" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;Enables calling turtle to move along its current heading by the number of 
;patches specified by the parameter passed to this procedure so long as the 
;patch immediately ahead of the calling turtle along its current heading is 
;clear.  If the patch immediately in front of the calling turtle along its
;heading is not clear then any moves performed will be reversed.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@param   patches-to-move   Number        The number of patches that the turtle
;                                         should move forward by.
;@param   moving-randomly?  Boolean       Set to true if the calling turtle is
;                                         moving randomly resulting in the calling
;                                         turtle not associating the movement and
;                                         the current visual pattern together if it
;                                         is a CHREST turtle.
;@return  -                 Boolean       True if the turtle was able to move along
;                                         the number of patches specified successfully,
;                                         false otherwise.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to-report move [heading-to-move-along patches-to-move]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'move' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  output-debug-message (word "Setting my heading to the heading specified: " heading-to-move-along "...") (who)
  set heading (heading-to-move-along)
  output-debug-message ( word "My 'heading' turtle variable is now equal to: " heading "." ) (who)
  
  output-debug-message ( word "Setting a local 'move-successful' variable to boolean true.  This will be used to indicate whether I was able to complete the move sequence..." ) (who)
  let move-successful (true)
  output-debug-message ( word "The local 'move-successful' variable is now set to: '" move-successful "'..." ) (who)
  
  ifelse( not (any? (turtles-on (patch-ahead (1))) with [hidden? = false]) )[
    output-debug-message (word "The patch immediately ahead of me along heading " heading " is clear (no visible turtles on it) so I'll move onto it...") (who)
    forward 1
  ]
  [
    output-debug-message (word "The patch immediately ahead of me along heading " heading " is not clear (visible turtles on it) so I'll set the local 'move-successful' variable to boolean false...") (who)
    set move-successful (false)
    output-debug-message (word "The local 'move-successful' variable is now equal to: '" move-successful "'...") (who)
  ]
  
  output-debug-message (word "Reporting whether the move was successful or not...") (who)
  set debug-indent-level (debug-indent-level - 2)
  report move-successful
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "OUTPUT-DEBUG-MESSAGE" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Takes the message passed as the first parameter to this procedure and outputs 
;it to the file specified by the 'debug-message-output-file' string if the global 
;'debug?' variable is set to true.  Users can also specify that the message to 
;output is turtle-specific using the second parameter passed to this procedure.
;
;Debug messages are indented according to the value of the global 'debug-indent-level'
;variable.  An indent is composed of 3 spaces.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@param   message-to-output String        The debug message to be output to the
;                                         command center in the Netlogo "Interface"
;                                         tab.
;@param   turtle-id         Number/String If 'message-to-output' is to be attributed to a calling 
;                                         turtle then pass the calling turtle's 'who' variable 
;                                         value; this will output 'message-to-output' prepended 
;                                         with an identifier for the calling turtle.  If 
;                                         'message-to-output' is not to be attributed to a calling
;                                         turtle then pass an empty string (""); no turtle identifier
;                                         will be prepended to 'message-to-output'.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to output-debug-message [msg-to-output turtle-id]
  
  if(debug?)[
    let t-id (sentence turtle-id)
    let x 0
    
    if( (item (0) (t-id)) != "" )[
      set msg-to-output (word "(turtle " turtle-id "): " msg-to-output )
    ]
    
    while[x < debug-indent-level][
      set msg-to-output (word "   " msg-to-output)
      set x (x + 1)
    ]
  
;    ifelse(testing?)[
;      set testing-debug-messages (word testing-debug-messages msg-to-output "\n")
;    ]
;    [
      ;This will evaluate to true if the user has pressed 'cancel' when 
      ;asked to define where debug messages should be output to.
      ifelse(debug-message-output-file = false)[
        print msg-to-output
      ]
      [
        ;This will evaluate to true if the user has set 'debug?' to true
        ;whilst the simulation is running.
        ifelse(debug-message-output-file = 0)[
          specify-debug-message-output-file
        ]
        [
          file-open debug-message-output-file
          file-print msg-to-output
          file-flush
        ]
      ]
;    ]
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "PATCH-AHEAD-BLOCKED?" PROCEDURE ;;; - MAY NO LONGER BE NEEDED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Determines if the patch ahead of the calling turtle's location in scene
;;is blocked.  A patch is blocked if it contains an opponent, a hole or
;;a non-moveable tile.
;;
;;         Name              Data Type          Description
;;         ----              ---------          -----------
;;@param   scene             jchrest.lib.Scene  The scene to be evaluated.
;;@param   heading-to-face   Number             The heading along which the patch to check is located.
;;@return  -                 Boolean            True if the patch ahead along the heading specified
;;                                              in scene is blocked, false if not.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>    
;to-report patch-ahead-blocked? [scene heading-to-face]
;  set debug-indent-level (debug-indent-level + 1)
;  output-debug-message ("EXECUTING THE 'patch-ahead-blocked?' PROCEDURE...") ("")
;  set debug-indent-level (debug-indent-level + 1)
;  
;  output-debug-message (word "Checking to see if the patch along heading '" heading-to-face "' from my location in the scene passed contains an opponent, hole or unmoveable tile...") (who)
;  let object-ahead-one-patch-away ( item (1) (get-object-and-patch-coordinates-ahead-of-location-in-scene (scene) (heading-to-face) (1)) )
;  let object-ahead-two-patches-away ( item (1) (get-object-and-patch-coordinates-ahead-of-location-in-scene (scene) (heading-to-face) (2)) )
;  output-debug-message (word "The patch ahead contains '" object-ahead-one-patch-away "' and the patch ahead of this patch contains '" object-ahead-two-patches-away "'...") (who)
;          
;  ifelse(
;    (object-ahead-one-patch-away = opponent-token) or
;    (object-ahead-one-patch-away = hole-token) or
;    ;(object-ahead-one-patch-away = "null" and cautious?) or
;    (
;      (object-ahead-one-patch-away = tile-token) and
;      (
;        (object-ahead-two-patches-away = opponent-token) or
;        (object-ahead-two-patches-away = tile-token)
;        ;(object-ahead-two-patches-away = "null" and cautious? )
;      )
;    )
;  )[
;    output-debug-message ("The patch ahead is blocked, reporting true...") (who)
;    set debug-indent-level (debug-indent-level - 2)
;    report true
;  ]
;  [
;    output-debug-message ("The patch ahead is not blocked or isn't present in the scene passed, reporting false...") (who)
;    set debug-indent-level (debug-indent-level - 2)
;    report false
;  ]
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "PATCH-AHEAD-EMPTY?" PROCEDURE ;;; - MAY NO LONGER BE REQUIRED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Determines whether the patch immediately ahead of the calling turtle
;(ahead with respect to the calling turtle's current heading) is
;completely empty (has no turtles on it).
;
;         Name              Data Type          Description
;         ----              ---------          -----------
;@param   scene             jchrest.lib.Scene  The scene to check
;@param   heading-of-self   Number             The heading to be checked for the calling turtle.
;@return  -                 Boolean            Boolean true indicates that the patch ahead
;                                              contains no turtles.  Boolean false indicates
;                                              that the patch ahead does contain turtles.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to-report patch-ahead-empty? [scene heading-of-self]
; set debug-indent-level (debug-indent-level + 1)
; output-debug-message ("EXECUTING THE 'patch-ahead-empty?' PROCEDURE...") ("")
; set debug-indent-level (debug-indent-level + 1)
; 
; let location-of-self ( chrest:Scene.get-location-of-creator (scene) )
; let location-of-self-xcor ( item (0) (location-of-self) )
; let location-of-self-ycor ( item (1) (location-of-self) )
; let pxcor-to-check 0
; let pycor-to-check 0
; 
; ifelse(heading-of-self = 0)[
;   set pxcor-to-check (location-of-self-xcor)
;   set pycor-to-check (location-of-self-ycor + 1)
; ]
; [
;   ifelse(heading-of-self = 90)[
;     set pxcor-to-check (location-of-self-xcor + 1)
;     set pycor-to-check (location-of-self-ycor)
;   ]
;   [
;     ifelse(heading-of-self = 180)[
;       set pxcor-to-check (location-of-self-xcor)
;       set pycor-to-check (location-of-self-ycor - 1)
;     ]
;     [
;       ifelse(heading-of-self = 270)[
;         set pxcor-to-check (location-of-self-xcor - 1)
;         set pycor-to-check (location-of-self-ycor)
;       ]
;       [
;         error (word "The 'heading-specified' value passed to the 'patch-ahead-empty?' procedure (" heading-of-self ") is not supported.")
;       ]
;     ]
;   ]
; ]
; 
; output-debug-message (word "The patch x/ycor to check is '" pxcor-to-check "' and '" pycor-to-check "', respectively...") (who)
; let class-of-object-on-patch-ahead ( item (1) (chrest:Scene.get-square-contents-as-netlogo-list (scene) (pxcor-to-check) (pycor-to-check)) )
; output-debug-message (word "The class of the object on these coordinates is: '" class-of-object-on-patch-ahead "'.  Reporting if this is equal to '" empty-patch-token "' or '" blind-patch-token "'") (who)
; set debug-indent-level (debug-indent-level - 2)
; report (class-of-object-on-patch-ahead) = empty-patch-token or (class-of-object-on-patch-ahead = blind-patch-token)
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "PERFORM-ACTION" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Takes an action pattern and uses the information contained within it to enable
;the calling turtle to perform the action appropriately.
;
;If the calling turtle is a CHREST turtle and the action is performed successfully,
;this procedure will also ask the CHREST turtle to learn the action.
;
;
;         Name              Data Type                Description
;         ----              ---------                -----------
;@param   action-info       List                     Should contain two elements:
;                                                    1) The action pattern to perform as a
;                                                       list with the following form:
;                                                       [action-token heading patches-moved].
;                                                    2) Boolean value indicating whether 
;                                                       pattern-recognition was used to decide 
;                                                       upon this action.
;@param   current-view     List                      What the turtle can currently see as a list of 
;                                                    lists with the following form:
; 
;                                                    [
;                                                      [pxcor pycor object1-class]
;                                                      [pxcor pycor object2-class]
;                                                    ]
;
;                                                    This list is used to enable production creation.  
;                                                    If the turtle is not capable of production creation 
;                                                    or is not able to produce such visual information, 
;                                                    pass an empty list.
;@return  -                 Boolean                  True if the action was performed successfully,
;                                                    false if not.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to-report perform-action [ action-info current-view ]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'perform-action' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  ;;;;;;;;;;;;;
  ;;; SETUP ;;;
  ;;;;;;;;;;;;;
  
  let action-details ( item (0) (action-info) )
  output-debug-message (word "The action to perform is: " action-details) (who)
  
  let action-identifier ( item (0) (action-details) )
  let action-heading ( item (1) (action-details) )
  let action-patches ( item (2) (action-details) )
  output-debug-message ( word "After extracting information from the action passed to this procedure, three local variables 'action-identifier', 'action-heading' and 'action-patches' have been set to '" action-identifier "', '" action-heading "' and '" action-patches "', respectively..." ) (who)
  
  let pattern-rec-used? (item (1) (action-info))
  output-debug-message ( word "Was pattern-recognition used to generate this action? '" pattern-rec-used? "'..." ) (who)
  
  let action-performed-successfully (false)
  output-debug-message (word "Assuming that the action will be performed unsuccessfully since the action specified may not be a valid action.  Checking this now...") (who)
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CHECK FOR VALID ACTION ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ifelse(member? (action-identifier) (possible-actions))[
    output-debug-message (word "The action to perform (" action-identifier ") is a valid action so I'll try to perform it now") (who)
    
    ;;;;;;;;;;;;;;;;;;;;;;
    ;;; PERFORM ACTION ;;;
    ;;;;;;;;;;;;;;;;;;;;;;
  
    ifelse(action-identifier = push-tile-token)[
      output-debug-message (word "The local 'action-identifier' variable is equal to: '" action-identifier "' so I should execute the 'push-tile' procedure...") (who)
        set action-performed-successfully ( push-tile (action-heading) )
    ]
    [
      output-debug-message (word "The local 'action-identifier' variable is equal to: '" action-identifier "' so I should execute the 'move' procedure...") (who)
        set action-performed-successfully ( move (action-heading) (action-patches) )
    ]
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; ASSIGN ACTION PERFORMANCE SUCCESS VARIABLE ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
    output-debug-message ( word "Checking to see if the local 'action-performed-successfully' variable is a list (" is-list? action-performed-successfully ").  If it is, the first element will be extracted and set as this variable's value" ) (who)
    if( is-list? (action-performed-successfully) )[
      output-debug-message ( word "The local 'action-performed-successfully' variable is a list so its value will be set to the first element (" ( item (0) (action-performed-successfully) ) ")..." ) (who)
        set action-performed-successfully ( item (0) (action-performed-successfully) )
    ]
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; CHREST TURTLE CODE ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;
  
    output-debug-message ("Checking to see if I am a CHREST turtle.  If so, I have some work to do...") (who)
    if(breed = chrest-turtles)[
  
      ;;;;;;;;;;;;;;;;;;;;
      ;;; LEARN ACTION ;;;
      ;;;;;;;;;;;;;;;;;;;;
      
      output-debug-message ("I am a CHREST turtle.  First, I'll learn the action I just attempted to perform...") (who)
      
      let problem-solving-action ( chrest:ListPattern.new ("action") (list chrest:ItemSquarePattern.new (problem-solving-token) (0) (0)) )
      let explicit-action ( chrest:ListPattern.new ("action") (list chrest:ItemSquarePattern.new (action-identifier) (action-heading) (action-patches)) )
    
      ;If problem-solving has been used the turtle has a 50% chance of learning either the problem-solving 
      ;action or the explicit action.  If the problem-solving action is selected for learning but is already 
      ;learned, the explicit action will be learned instead.  Otherwise, the explicit action will be learned.
      let action-to-learn (explicit-action)
      if( (not pattern-rec-used?) and ((random-float (1.0)) < 0.5) )[
        set action-to-learn (problem-solving-action)
      ]
  
      ;Check for learned problem-solving action.
      let action-recognised  ( chrest:Node.get-image (chrest:recognise-and-learn-list-pattern (action-to-learn) (report-current-time)) )
      output-debug-message (word "Recognised " chrest:ListPattern.get-as-string (action-recognised) " given action " chrest:ListPattern.get-as-string (action-to-learn)) (who)
      
      ;Learn explicit action if problem-solving action already learned.
      if( 
        ( (chrest:ListPattern.get-as-string (action-to-learn)) = (chrest:ListPattern.get-as-string (problem-solving-action)) ) and 
        ( (chrest:ListPattern.get-as-string (action-recognised)) = (chrest:ListPattern.get-as-string (problem-solving-action)) ) 
      )[
        output-debug-message ("The action to learn is the problem-solving action but I've already learned it so I'll learn the explicit action instead") (who)
        set action-to-learn (explicit-action)
      ]
      
      output-debug-message (word "Attempting to learn action: " chrest:ListPattern.get-as-string (action-to-learn)) (who)
      let ignore-this (chrest:recognise-and-learn-list-pattern (action-to-learn) (report-current-time))
      ;Note: the action won't be learned (learning resource in CHREST won't be consumed) if the action is already committed to LTM.
      
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;; CREATE VISUAL LIST-PATTERN TO USE IN PRODUCTION/EPISODE CREATION ;;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      
      ;Construct a jchrest.lib.ListPattern from the contents of 'current-view-as-list-of-item-square-patterns' and normalise the jchrest.lib.ListPattern 
      ;according to the CHREST turtle's domain-specifics so that its possible to determine if an episode and production created from this visual information
      ;will actually be of use.
      ;
      ;The visual information passed to this procedure will eventually be used by CHREST in a recognition function (to create or identify a production, the
      ;visual part of the production must be recognised completely).  CHREST doesn't learn visual information that is entirely empty when its domain is set 
      ;to Tileworld.  So, if during learning, the turtle can only see empty/blind patches or itself (hereafter referred to as an "empty" visual list-pattern)
      ;then nothing is learned since the "jchrest.lib.TileWorldDomain#normalise" function will strip out all jchrest.lib.ItemSquarePatterns that denote 
      ;empty/blind patches or the CHREST turtle itself from the jchrest.lib.ListPattern passed to it when discrimination or familiarisation occurs.  If the
      ;result of this is an empty visual list-pattern, the CHREST turtle does not proceed with discrimination or familiarisation.  Consequently, if the CHREST 
      ;turtle attempts to create a production using an empty visual list-pattern or use an episode containing an empty visual list-pattern to reinforce a 
      ;production then neither operation will occur since nothing will be recognised when these functions are invoked.  To save wasting time invoking such
      ;functions if they will ultimately fail, create the visual chrest.lib.ListPattern that will be contained in an episode or production and pass it to 
      ;the "jchrest.lib.TileWorldDomain#normalise" function.  If this produces an empty visual list-pattern, the CHREST turtle will forego adding an episode 
      ;containing it or creating a production using it.
      output-debug-message ("Creating the visual list-pattern for the episode to be added to episodic memory and the (potential) production to be created..." ) (who)
      
      let current-view-as-list-of-item-square-patterns []
      foreach(current-view)[
        set current-view-as-list-of-item-square-patterns (lput 
          (chrest:ItemSquarePattern.new 
            (item (2) (?)) 
            (item (0) (?)) 
            (item (1) (?))
          ) 
          (current-view-as-list-of-item-square-patterns)
        )
      ]
      
      let visual-list-pattern ( chrest:DomainSpecifics.normalise-list-pattern (chrest:ListPattern.new ("visual") (current-view-as-list-of-item-square-patterns)) )
      output-debug-message (word "Visual list-pattern generated: " chrest:ListPattern.get-as-string (visual-list-pattern)) (who)
    
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;; CHECK IF PRODUCTION/EPISODE CREATION SHOULD OCCUR ;;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      
      ;At this point, all information required to make a decision on whether to add an episode to episodic memory and attempt production creation is available.
      ;Note that episodes are used to facilitate production reinforcement in CHREST, the importance of this statement will become apparent below.
      ;
      ;To add an episode to episodic memory and attempt production creation, the following statements must all evaluate to true for the reasons provided:
      ;
      ; 1) Action performed must not be a 'move' action: the 'move' action is only generated when a turtle should explore the environment freely to try and
      ;    find an environment state that enables it to secure a tile or push a tile into a hole.  Due to the stochasticity of Tileworld, such movement should
      ;    be random so biasing such random movement by creating a production that terminates with the 'move' action makes such movements non-random.  This may
      ;    adversely affect the scoring potential of the turtle so should be avoided.
      ; 2) Only successful actions should be used to create productions.  Helps to uphold the principle of production rationality specified by Miyazaki et al: 
      ;    "better productions should be selected more frequently than worse ones" [Miyazaki, K., Yamamura, M., Kobayashi, S.: On the rationality of profit 
      ;    sharing in reinforcement learning. In: 3rd International Conference on Fuzzy Logic, Neural Nets and Soft Computing. pp. 285–288. Korean Institute of 
      ;    Intelligent Systems (1994)].
      ; 3) The visual list-pattern constructed above should not be empty: (see comment in "CREATE VISUAL LIST-PATTERN TO USE IN PRODUCTION/EPISODE CREATION" section).
      ; 4) The CHREST turtle must be capable of reinforcing problem-solving, explicit actions or both: when a production is created, its utility value is initially
      ;    set to 0 so will not be selected for use if recognised in future unless the utility is incremented through production reinforcement. There is therefore 
      ;    no gain to be made by creating productions if they will never be reinforced since they will never be used.  Likewise, since episodes are used to 
      ;    facilitate production reinforcement, if the CHREST turtle is incapable of reinforcing any type of production then there is no purpose in creating an
      ;    episode.
      ; 5) The action performed was generated using pattern recognition and the CHREST turtle can't reinforce explicit actions: in this case, production creation
      ;    is invalid since creating a production containing an explicit action without being able to reinforce it means that the production will never be used.
      ;    Likewise, if its not possible to reinforce explicit action productions then there's no reason to add an episode to episodic memory.
      output-debug-message ("Checking to see if I should add an episode to episodic memory and if I should attempt to create a production...") (who)
      output-debug-message (word "I'll do this if the following are all true:") (who)
      output-debug-message (word " 1. The action performed was not equal to '" move-token "' (" (action-identifier != move-token) ")") (who) 
      output-debug-message (word " 2. The action was performed successfully (" action-performed-successfully ")") (who) 
      output-debug-message (word " 3. The visual list-pattern generated isn't empty (" not chrest:ListPattern.empty? visual-list-pattern ")") (who)
      output-debug-message (word " 4. I can reinforce either problem-solving productions (" reinforce-problem-solving? ") or explicit action productions (" reinforce-actions? ")") (who)
      output-debug-message (word " 5. Its not the case that the action performed was generated using pattern-recognition and I can't reinforce explicit action productions (" not (pattern-rec-used? and not reinforce-actions?) ")") (who)
      
      ifelse(
        (action-identifier != move-token) and 
        (action-performed-successfully) and
        (not chrest:ListPattern.empty? visual-list-pattern) and
        (reinforce-problem-solving? or reinforce-actions?) and
        (not (pattern-rec-used? and not reinforce-actions?))
      )[
        
        output-debug-message ("I'll attempt to create a production and add an episode to episodic memory...") (who)
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;; ADD EPISODE TO EPISODIC MEMORY ;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        output-debug-message ( word "I'll add an episode containing the visual list-pattern, the explicit action performed and whether pattern-recognition was used to generate the action to my 'episodic-memory'..." ) (who)
        add-episode-to-episodic-memory (visual-list-pattern) (explicit-action) (pattern-rec-used?)
            
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;; DETERMINE IF PRODUCTION CREATION SHOULD OCCUR AND IF SO, WHAT ACTION TO USE ;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
            
        output-debug-message ("I can reinforce problems or actions so I'll attempt to create a production now.  Determining what type of production (problem-solving or explicit action) to create...") (who)
              
        ; In most cases, the CHREST turtle should create a production terminating in an explicit action.  However,
        ; in certain circumstances, a production terminating with the problem-solving action should be created.
        ; If its determined that a problem-solving production should be created, it may still be the case that the
        ; CHREST turtle creates an explicit-action production if the problem-solving production for the visual
        ; list pattern created below already exists (same reasoning as with the determination of whether to learn
        ; the problem-solving action or an explicit action above).
        ;
        ; The following table makes explicit all possible scenarios that may occur at this point and what the outcome
        ; with regard to production creation should be.
        ;
        ; |---------------------|-----------|---------------|------------------------------------------------------|
        ; | PS Generate Action? | Reinf PS? | Reinf Action? | Outcome                                              |
        ; |---------------------|-----------|---------------|------------------------------------------------------|
        ; | Yes                 | Yes       | Yes           | Choice between PS and action                         |
        ; |                     |           | No            | Create explicit PS production                        |
        ; |                     | No        | Yes           | Create explicit action production                    |
        ; |                     |           | No            | N/A (must be able to reinf PS or action to get here) |
        ; | No                  | Yes       | Yes           | Create explicit action production                    |
        ; |                     |           | No            | N/A (this is checked for in outer conditional)       |
        ; |                     | No        | Yes           | Create explicit action production                    |
        ; |                     |           | No            | N/A (must be able to reinf PS or action to get here) |
        ; |---------------------|-----------|---------------|------------------------------------------------------|
          
        ; Since its more likely that the CHREST turtle will create an explicit-action production, set the action to
        ; be used in the production to the explicit action here.
        let action-for-production (explicit-action)
        
        ; Overwrite the action to be used in the production here, if applicable.
        if(not pattern-rec-used?)[
          if(reinforce-problem-solving?)[
            ifelse(reinforce-actions?)[
              if( (random-float 1.0) < 0.5)[
                set action-for-production (problem-solving-action)
              ]
            ]
            [
              set action-for-production (problem-solving-action)
            ]
          ]
        ]
        output-debug-message (word "Determined that " chrest:ListPattern.get-as-string (action-for-production) " is to be the action part of the production" ) (who)
        
        ; Check to see if the turtle should create an explicit action production instead of a problem-solving production. 
        if( 
          (chrest:ListPattern.get-as-string (action-for-production)) = (chrest:ListPattern.get-as-string (problem-solving-action)) and
          reinforce-actions?
        )[
          output-debug-message (word "I'm to create a problem-solving production and I can reinforce explicit actions so if such a production already exists for the visual list-pattern generated I'll create a production with the explicit action instead...") (who)
          
          let associated-action-nodes-and-link-values (chrest:recognise-list-pattern-and-return-nodes-with-modality (visual-list-pattern) ("action") (report-current-time))
          output-debug-message (word "Actions associated with " chrest:ListPattern.get-as-string (visual-list-pattern) ": " map ([chrest:ListPattern.get-as-string (chrest:Node.get-image (item (0) (?)))]) (associated-action-nodes-and-link-values)) (who)
          
          foreach(associated-action-nodes-and-link-values)[
            let associated-action-node (item (0) (?))
            let associated-action-node-contents ( chrest:ListPattern.get-as-netlogo-list (chrest:Node.get-image (associated-action-node)) )
            foreach(associated-action-node-contents)[
              let associated-action (chrest:ItemSquarePattern.get-item (?))
              output-debug-message (word "Checking if '" associated-action "' is equal to '" problem-solving-token "'" ) (who)
              if(associated-action = problem-solving-token)[
                output-debug-message (word "Action '" associated-action "' is equal to '" problem-solving-token "' so there is already a problem-solving production for " chrest:ListPattern.get-as-string (visual-list-pattern) "!") (who)
                output-debug-message (word "Setting the action for the production to " chrest:ListPattern.get-as-string (explicit-action) " instead...") (who)
                set action-for-production (explicit-action)
              ]
            ]
          ]
        ]
          
        output-debug-message (word "The production will terminate with action " chrest:ListPattern.get-as-string (action-for-production)) (who)
        
        ;;;;;;;;;;;;;;;;;;;;;;;;;
        ;;; CREATE PRODUCTION ;;;
        ;;;;;;;;;;;;;;;;;;;;;;;;;
        
        output-debug-message (word "Creating a production that starts with vision " chrest:ListPattern.get-as-string (visual-list-pattern) " and terminates with action " chrest:ListPattern.get-as-string (action-for-production)) (who)
        chrest:associate-list-patterns (visual-list-pattern) (action-for-production) (report-current-time)
      ]
      [
        output-debug-message ("I won't attempt to create a production or add an episode to episodic memory...") (who)
      ]
    ] ;CHREST turtle breed check.
  ]
  [
    error (word "The action to perform specified by turtle " who " is not a valid action (does not occur in the global 'possible-actions' list: " possible-actions ").")
  ]
  
  output-debug-message ( word "Reporting the value of the local 'action-performed-successfully' variable (" action-performed-successfully ")..." ) (who)
  set debug-indent-level (debug-indent-level - 2)
  report action-performed-successfully
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "PLACE-RANDOMLY" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Places the calling turtle on a random patch in the environment that is not
;currently occupied by a visible turtle if there are any such patches available.
;If there are no patches available, the calling turtle dies.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to place-randomly
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'place-randomly' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  let number-free-patches (count (patches with [not any? turtles-here with [hidden? = false]]))
  output-debug-message (word "CHECKING TO SEE HOW MANY PATCHES ARE FREE (THOSE OCCUPIED BY INVISIBLE TURTLES ARE CONSIDERED FREE). IF 0, THIS PROCEDURE WILL ABORT: " number-free-patches "...") ("")
  ifelse( number-free-patches > 0 )[
    output-debug-message ("MORE THAN ONE PATCH IS FREE, PLACING THE CALLING TURTLE RANDOMLY ON ONE OF THESE PATCHES...") ("")
    let patch-to-be-placed-on (one-of patches with [not any? turtles-here with [hidden? = false]])
    move-to patch-to-be-placed-on
    output-debug-message (word "I've been placed on the patch whose xcor is: '" xcor "' and ycor is: '" ycor "'." ) (who)
  ]
  [
    output-debug-message ("THERE ARE NO PATCHES FREE, ASKING THE CALLING TURTLE TO DIE...") ("")
    ask myself [
      die
    ]
  ]
  
  set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "PLAY" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Enables Tileworld games to be played.  The game progresses in the following way:
;
; 1. A check is made as to whether this is the first repeat of the first scenario in
;    a set of simulations.  If this is true, relevant variables are set and execution 
;    continues from step 2.
; 2. Some general housekeeping is performed; checks are made on whether the relevant 
;    scenario-repeat directory structure exists in the specified directory where 
;    results are to be output, whether the user has turned the "debug?" switch to 
;    "yes" in between play cycles and the environment is updated.
; 3. A check is made on whether all players have completed playing.
;    3.1. If all players have finished playing then a check is made on whether the 
;         simulation mode is set to training or not.
;       3.1.1. If training mode is enabled training data is saved if specified, all
;              player turtles become visible again, all plots/model output are cleared
;              and turtles are reset (CHREST turtle's CHREST instances are not reset).
;       3.1.2. If training mode is not enabled then data is saved, the current repeat
;              number is incremented by 1, all turtles/plots/model output is cleared,
;              training and game times are reset to 0 and a check is made upon the 
;              new repeat number.  If the new repeat number is greater than the total 
;              number of repeats specified for a scenario then the repeat number is 
;              reset to 1 and the current scenario number is incremented by 1.  The
;              current scenario number is then checked to see if it is greater than
;              the total number of scenarios specified.  If this is the case then the
;              model code execution stops completely.  If not, the setup procedure is
;              run again.
;    3.2. If some players are still playing then new tiles and holes are first created
;         then player turtles act in the following order:
;           - CHREST turtles
;         After player turtles have acted a check is made on whether data should be 
;         rendered to the model's output.  Finally, time is updated.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to play
  
  set debug-indent-level 0
  
  ;=======================;
  ;== FIRST CYCLE SETUP ==;
  ;=======================;
  
  if((current-scenario-number = 0) and (current-repeat-number = 0))[
    __clear-all-and-reset-ticks
    file-close-all
    
    set testing? false
    set current-scenario-number 1
    set current-repeat-number 1
    
    if(debug?)[
      specify-debug-message-output-file
    ]
    
    user-message ("Please specify where model input/output files can be found in the next dialog that appears.")
    set setup-and-results-directory user-directory
    
    set directory-separator pathdir:get-separator
    check-for-scenario-repeat-directory
    
    ifelse(user-yes-or-no? "Would you like to save the interface at the end of each repeat?")[ set save-interface? true ][ set save-interface? false ]
    ifelse(user-yes-or-no? "Would you like to save all model data at the end of each repeat?")[ set save-world-data? true ][ set save-world-data? false ]
    ifelse(user-yes-or-no? "Would you like to save model output data at the end of each repeat?")[ set save-output-data? true ][ set save-output-data? false ]
    ifelse(user-yes-or-no? "Would you like to save the data specified during training?")[ set save-training-data? true ][ set save-training-data? false ]
    
    output-debug-message (word "USER'S RESPONSE TO WHETHER THE INTERFACE SHOULD BE SAVED AFTER EACH REPEAT IS: " save-interface? ) ("")
    output-debug-message (word "USER'S RESPONSE TO WHETHER MODEL DATA SHOULD BE SAVED AFTER EACH REPEAT IS: " save-world-data? ) ("")
    output-debug-message (word "USER'S RESPONSE TO WHETHER THE MODEL'S OUTPUT DATA SHOULD BE SAVED AFTER EACH REPEAT IS: " save-output-data? ) ("")
    output-debug-message (word "USER'S RESPONSE TO WHETHER INTERFACE/MODEL DATA/MODEL OUTPUT DATA SHOULD BE SAVED AFTER TRAINING IS COMPLETE IS: " save-training-data? ) ("")
    
    setup (false)
    
;    if(save-output-data?)[
;      output-debug-message ("SINCE THE MODEL'S OUTPUT DATA SHOULD BE SAVED THE USER NEEDS TO SPECIFY WHEN THE OUTPUT SHOULD BE UPDATED...") ("")
;      set output-interval (read-from-string (user-input ("Model output should be generated every ____ seconds?")))
;      output-debug-message ("CHECKING TO SEE IF THE MAXIMUM TRAINING/PLAY TIME OF ANY CHREST TURTLE IS GREATER THAN 0 AND IF SO WHETHER THE INTERVAL SPECIFIED FOR OUTPUTTING MODEL DATA IS GREATER THAN EITHER OF THESE TIMES...") ("")
;      while[
;        ( ( (max [training-time] of chrest-turtles) > 0) or ( (max [play-time] of chrest-turtles) > 0 ) ) and
;        (output-interval > max [training-time] of chrest-turtles) or (output-interval > max [play-time] of chrest-turtles)
;      ][
;        user-message (word "The output interval specified (" output-interval ") is greater than the maximum value specified for 'training-time' (" max [training-time] of chrest-turtles ") or 'play-time' (" max [play-time] of chrest-turtles ").")
;        set output-interval (read-from-string (user-input ("Model output should be generated every ____ seconds?")))
;      ]
;    ]
  ]
  
  output-debug-message ("") ("") ;Blank to seperate time increments for readability.
  output-debug-message (word "========== TIME: " report-current-time " ==========") ("") 
  
  ;==================;
  ;== HOUSEKEEPING ==;
  ;==================;
  
  output-debug-message ("HOUSEKEEPING...") ("")
  ;Check that the scenario-repeat directory exists at the start of every cycle to ensure that the 
  ;user is alerted as soon as possible to the non-existance of a directory to write results to.
  check-for-scenario-repeat-directory
  
  ;Check if the user has switched on debugging in between cycles.  If they have, ask them to 
  ;specify where debug messages should be output to.
  output-debug-message ("CHECKING TO SEE IF DEBUGGING HAS BEEN SWITCHED ON IN BETWEEN CYCLES...") ("")
  if(debug? and debug-message-output-file = 0)[
    output-debug-message ("DEBUGGING HAS BEEN SWITCHED ON AND THE 'debug-message-output-file' VARIABLE VALUE IS SET TO 0.  ASKING THE USER WHERE DEBUG FILES SHOULD BE OUTPUT TO...") ("")
    specify-debug-message-output-file
  ]
  
  ;Check if the user has switched off debugging in between cycles.  If they have, set the 
  ;'debug-message-output-file' variable value to 0 so that if it is switched on again, the
  ;user is prompted to specify where debug files should be saved to.
  output-debug-message ("CHECKING TO SEE IF DEBUGGING HAS BEEN SWITCHED OFF IN BETWEEN CYCLES...") ("")
  if(not debug? and debug-message-output-file != 0)[
    output-debug-message ("DEBUGGING HAS BEEN SWITCHED OFF AND THE 'debug-message-output-file' VARIABLE VALUE HAS BEEN SET PREVIOUSLY.  CLOSING THE 'debug-message-output-file' AND SETTING THIS VARIABLES VALUE BACK TO 0...") ("")
    file-close
    set debug-message-output-file 0
  ]
  
  ;Remove any players from the environment if the current time equals their 'training-time'
  ;or 'play-time' variables.
  remove-players
  
  ;===================;
  ;=== END OF PLAY ===;
  ;===================;
  
  output-debug-message (word "CHECKING TO SEE IF THERE ARE ANY PLAYER TURTLES STILL PLAYING (VISIBLE)...") ("")
  ifelse(player-turtles-finished?)[
    
    ;=====================;
    ;== END OF TRAINING ==;
    ;=====================;
    
    output-debug-message (word "CHECKING TO SEE IF THE GLOBAL 'training?' VARIABLE (" training? ") IS SET TO TRUE...") ("")
    ifelse(training?)[
      output-debug-message ("THERE ARE NO PLAYERS STILL VISIBLE AND THE GLOBAL 'training?' VARIABLE IS SET TO TRUE.  TRAINING IS THEREFORE COMPLETE...") ("")
      output-debug-message ("CHECKING TO SEE IF ANY TRAINING DATA SHOULD BE SAVED...") ("")
      if(save-training-data?)[
        if(save-interface?)[
          output-debug-message (word "EXPORTING INTERFACE TO: " setup-and-results-directory directory-separator "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number directory-separator "Repeat" current-repeat-number "-TRAINING.png" "...")("")
          export-interface (word setup-and-results-directory directory-separator "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number directory-separator "Repeat" current-repeat-number "-TRAINING.png" )
        ]
      
        if(save-output-data?)[
          output-debug-message (word "EXPORTING MODEL OUTPUT TO: " setup-and-results-directory directory-separator "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number directory-separator "Repeat" current-repeat-number "-TRAINING.txt" "...")("")
          export-output (word setup-and-results-directory directory-separator "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number directory-separator "Repeat" current-repeat-number "-TRAINING.txt" )
        ]
      
        if(save-world-data?)[
          output-debug-message (word "EXPORTING WORLD DATA TO: " setup-and-results-directory directory-separator "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number directory-separator "Repeat" current-repeat-number "-TRAINING.csv" "...")("")
          export-world (word setup-and-results-directory directory-separator "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number directory-separator "Repeat" current-repeat-number "-TRAINING.csv" )
        ]
      ]
    
      output-debug-message ("SETTING THE GLOBAL 'training?' VARIABLE TO FALSE, ASKING ALL TURTLES TO BECOME VISIBLE AGAIN, CLEARING ALL PLOTS AND ALL MODEL OUTPUT...") ("")
      set training? false
      ask turtles [
        set hidden? false
      ]
      clear-all-plots
      output-debug-message ("RESETTING CHREST TURTLES BUT MAINTAINING THEIR CHREST INSTANCES...") ("")
      setup-chrest-turtles (false)
      clear-output
    ]
    ;===================;
    ;=== END OF GAME ===;
    ;===================;
    [
      output-debug-message ("THERE ARE NO PLAYERS STILL VISIBLE AND THE GLOBAL 'training?' VARIABLE IS SET TO FALSE.  THE GAME IS THEREFORE COMPLETE...")("")
      
      output-print (word "Avg score: " (mean [score] of chrest-turtles) )
      output-print (word "Avg deliberation time: " (mean [total-deliberation-time] of chrest-turtles) )
      output-print (word "Avg # visual-action links: " (mean [chrest:get-ltm-modality-num-action-links "visual"] of chrest-turtles) )
      output-print (word "Avg frequency of random behaviour: " (mean [frequency-of-random-behaviour] of chrest-turtles) )
      output-print (word "Avg frequency of problem-solving: " (mean [frequency-of-problem-solving] of chrest-turtles) )
      output-print (word "Avg frequency of pattern-recognition: " (mean [frequency-of-pattern-recognitions] of chrest-turtles) )
      output-print (word "Avg # visual LTM nodes: " (mean [chrest:get-ltm-modality-size "visual"] of chrest-turtles) )
      output-print (word "Avg depth visual LTM: " (mean [chrest:get-ltm-modality-avg-depth "visual"] of chrest-turtles) )
      output-print (word "Avg # action LTM nodes: " (mean [chrest:get-ltm-modality-size "action"] of chrest-turtles) )
      
      output-debug-message ("CHECKING TO SEE IF ANY DATA ACCUMULATED DURING THE GAME SHOULD BE SAVED...") ("")
      if(save-interface?)[
        output-debug-message (word "EXPORTING INTERFACE TO: " setup-and-results-directory directory-separator "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number directory-separator "Repeat" current-repeat-number ".png" "...")("")
        export-interface (word setup-and-results-directory directory-separator "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number directory-separator "Repeat" current-repeat-number ".png" )
      ]
      
      if(save-output-data?)[
        output-debug-message (word "EXPORTING MODEL OUTPUT TO: " setup-and-results-directory directory-separator "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number directory-separator "Repeat" current-repeat-number ".txt" "...")("")
        export-output (word setup-and-results-directory directory-separator "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number directory-separator "Repeat" current-repeat-number ".txt" )
      ]
      
      if(save-world-data?)[
        output-debug-message (word "EXPORTING WORLD DATA TO: " setup-and-results-directory directory-separator "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number directory-separator "Repeat" current-repeat-number ".csv" "...")("")
        export-world (word setup-and-results-directory directory-separator "Scenario" current-scenario-number directory-separator "Repeat" current-repeat-number directory-separator "Repeat" current-repeat-number ".csv" )
      ]

      output-debug-message (word "INCREMENTING THE GLOBAL 'current-repeat-number' (" current-repeat-number ") BY 1...") ("")
      set current-repeat-number (current-repeat-number + 1)
      
      output-debug-message ("SINCE THIS GAME HAS FINISHED ALL TURTLES SHOULD DIE, THE GLOBAL 'current-training-time' AND 'current-game-time' PLOTS SHOULD BE SET TO 0 AND ALL PLOTS SHOULD BE CLEARED...") ("")
      clear-turtles
      clear-output
      set current-training-time 0
      set current-game-time 0
      clear-all-plots
      file-close-all
      
      ;=======================;
      ;=== END OF SCENARIO ===;
      ;=======================;
      
      output-debug-message (word "CHECKING TO SEE IF GLOBAL 'current-repeat-number' VARIABLE VALUE (" current-repeat-number ") IS GREATER THAN THE GLOBAL 'total-number-of-repeats' (" total-number-of-repeats ") VARIABLE VALUE...") ("")
      if(current-repeat-number > total-number-of-repeats)[
        set current-scenario-number (current-scenario-number + 1)
        set current-repeat-number 1
      ]
      
      ;=========================;
      ;=== END OF SIMULATION ===;
      ;=========================;
      
      if(current-scenario-number > total-number-of-scenarios)[
        stop
      ]
    
      setup (false)
    ]
  ]
  ;================;
  ;== MAIN CYCLE ==;
  ;================;
  [
    output-debug-message ("PLAYER TURTLES MUST STILL BE PLAYING...") ("")
    
    create-new-tiles-and-holes
    chrest-turtles-act
    
    ask tiles [age]
    ask holes [age]
    update-time
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "PLAYER-TURTLES-FINISHED?" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Used to determine whether any turtle breeds except "tiles" and "holes" are
;still visible.  If turtles are visible they are still considered to be playing
;otherwise, they are not considered to be playing.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@returns -                 Boolean       True if the number of non-tile and non-hole turtles 
;                                         whose "hidden?" turtle-variable is set to false is
;                                         equal to 0, false if not.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
to-report player-turtles-finished?
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'player-turtles-finished?' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message (word "THE NUMBER OF VISIBLE TURTLES THAT AREN'T OF BREED 'tiles' AND 'holes' IS: " count turtles with [ breed != tiles and breed != holes and hidden? = false ] ".") ("")
  
  ifelse( ( count (turtles with [ breed != tiles and breed != holes and hidden? = false ]) ) = 0 )[ 
    output-debug-message ("THERE ARE NO VISIBLE TURTLES THAT AREN'T OF BREED 'tiles' AND 'holes' IN THE ENVIRONMENT.") ("")
    set debug-indent-level (debug-indent-level - 2)
    report true
  ]
  [ 
    output-debug-message ("THERE ARE VISIBLE TURTLES THAT AREN'T OF BREED 'tiles' AND 'holes' IN THE ENVIRONMENT.") ("")
    set debug-indent-level (debug-indent-level - 2)
    report false
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "PRINT-AND-RUN" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Takes a string as a parameter which should contain some Netlogo code.
;It would appear that providing a string concatonation to the "run"
;primitive causes an error so the Netlogo code to be run should first
;be concatonated and then passed to the "run" primitive.  This procedure
;provides such a service and also prints the string to be run for debugging 
;purposes.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@param   string-to-be-run  String        A string containing Netlogo code that should
;                                         be passed to the "run" primitive.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
to print-and-run [string-to-be-run]
 set debug-indent-level (debug-indent-level + 1)
 output-debug-message ("EXECUTING THE 'print-and-run' PROCEDURE...") ("")
 set debug-indent-level (debug-indent-level + 1)

 output-debug-message (word "NETLOGO COMMAND TO BE PASSED TO 'run' PRIMITIVE: '" string-to-be-run "'.") ("")
 set debug-indent-level (debug-indent-level - 2)
 run string-to-be-run
 
 
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "PUSH-TILE" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
;Enables the calling agent (the pusher) to push a tile by setting the pusher's heading 
;to face its closest-tile, T, and T is asked to do the same so that it moves along the 
;same heading as the pusher.  
;
;If the pusher's breed indicates that it is a CHREST turtle, it will attempt to associate 
;the current visual pattern and the action-pattern it is currently performing together in 
;its LTM.  The CHREST turtle will then update its 'visual-action-time-heuristics' list so that links
;between its contents can be reinforced if T fills a hole.
;
;The procedure then branches in one of two ways depending on whether there is a hole 
;on the patch ahead of T:
;
;  1. If there is a hole on the patch immediately ahead of T then:
;     a. T moves forward by 1 patch (simulates the first pat of the tile being 
;        pushed).
;     b. The hole is asked to die (simulates the first part of the tile filling the 
;        hole). 
;     c. The pusher's score is incremented by the value of the global "reward-value" 
;        variable.
;     d. The pusher's breed is checked, if it is a CHREST turtle then the pusher's
;        'visual-action-time-heuristics' list is iterated through and the pusher attempts to
;        reinforce each visual-action pair.  Following this, the pusher then clears
;        the 'visual-action-time-heuristics' list.
;     e. T dies (simulating the second part of the simulated hole fill).
;
;  2. If there isn't a hole on the patch immediately ahead of T, T checks to see if
;     there are any other turtles on the patch ahead.
;     a. There is something on the patch ahead of T so T does not move.
;     b. There is nothing on the patch ahead of T so T moves forward 1 patch (simulates
;        the first part of the tile being pushed).
;
;Following this branch, the pusher checks to see if T is directly in on the patch 
;immediately ahead.
;
;  1. If T is on the patch immediately ahead then the pusher does not move.
;  2. If T is not on the patch immediately ahead then it must have been pushed so
;     the pusher also moves forward one patch (simulates the second part of the 
;     push).
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@param   push-heading      Number        The heading that the pusher should set its heading
;                                         to in order to push the tile in question.
;@return  -                 Boolean       True if the move was completed successfully, false
;                                         otherwise.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to-report push-tile [push-heading]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'push-tile' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  output-debug-message ("Setting two local variables: 'push-tile-successful' and 'hole-filled' to boolean false...") (who)
  let push-tile-successful (false)
  let hole-filled (false)
  output-debug-message ( word "The local 'push-tile-successful' and 'hole-filled' variables are now set to: '" push-tile-successful "' and '" hole-filled "'..." ) (who)
  
  output-debug-message( word "Setting my heading to the value contained in the local 'push-heading' variable: " push-heading "...") (who)
  set heading (push-heading)
  output-debug-message (word "My 'heading' variable is now set to:" heading ".  Checking to see if there is a tile immediately ahead...") (who)
  
  ifelse(any? tiles-on patch-at-heading-and-distance (heading) (1))[
    output-debug-message (word "There is a tile immediately ahead along heading " heading ".  Pushing this tile...") (who)
    
    ask tiles-on patch-at-heading-and-distance (heading) (1)[
      output-debug-message ("I am the tile to be pushed.") (who)
      output-debug-message (word "Setting my 'heading' variable value to that of the pusher (" [heading] of myself ")...") (who)
      set heading [heading] of myself ;The tile's heading used to be set to 'heading-to-tile' which was a parameter passed.
      output-debug-message (word "My 'heading' variable value is now set to: " heading ".") (who)
      output-debug-message (word "Checking to see if there are any holes immediately ahead of me with this heading (" any? holes-on patch-ahead 1 ")...") (who)
    
      ifelse( any? holes-on patch-ahead 1 )[
        output-debug-message (word "There is a hole 1 patch ahead with my current heading (" heading ") so I'll move onto that patch, the hole will die, turtle " [who] of myself "'s 'score' will increase by 1 and I will die.") (who)
        forward 1
        ask holes-here[ die ]
        
        ask myself [
          output-debug-message (word "Since I have successfully pushed a tile into a hole I should increase my current score (" score ") by the 'reward-value' variable value (" reward-value ") and set the local 'hole-filled' variable to boolean true...") (who)
          set score (score + reward-value)
          set hole-filled (true)
          output-debug-message (word "My score is now equal to: " score " and the local 'hole-filled' variable is set to '" hole-filled "'.") (who)
        ]
        
        die
      ]
      [
        output-debug-message ("There are no holes ahead so I'll check to see if there are any other visible turtles ahead, if there is, I won't move...") (who)
        if(not any? (turtles-on (patch-ahead (1))) with [hidden? = false])[
          output-debug-message (word "There are no turtles on the patch immediately ahead of me with heading " heading " so I'll move forward by 1 patch...") (who)
          forward 1
        ]
      ]
    ]
    
    output-debug-message ("Checking to see if the tile I was pushing has moved...") (who)
    if(not any? tiles-on patch-at-heading-and-distance (heading) (1))[
      output-debug-message (word "The tile I was pushing has moved so I should also move forward by 1 patch to simulate a push and set the local 'push-tile-successful' variable to boolean true...") (who)
      forward 1
      set push-tile-successful (true)
    ]
  ]
  [
    output-debug-message ("There isn't a tile immediately ahead so I can't push a tile therefore the action has failed.  Setting the local 'push-tile-successful' variable to boolean false...") (who)
    set push-tile-successful (false)
  ]
  
  output-debug-message (word "The local 'push-tile-successful' and 'hole-filled' variables are set to: '" push-tile-successful "' and '" hole-filled "'. Reporting these as a list...") (who)
  set debug-indent-level (debug-indent-level - 2)
  report ( list (push-tile-successful) (hole-filled) )
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "QUOTE-STRING-OR-READ-FROM-STRING" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Checks to see if "value" contains alphabetical characters. If it doesn't, 
;it should be assigned as the result of the "read-from-string" primitive 
;so that it is converted from a string data-type to a value data-type.  
;If "value" does contain an alphabetical character then the result of 
;enclosing "value" with double quotes will be reported.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@param  value              String/Value  The value to check.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to-report quote-string-or-read-from-string [value]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'quote-string-or-read-from-string' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  output-debug-message ( word "CHECKING TO SEE IF " value " IS AN INTEGER OR A FLOATING POINT NUMBER...") ("")
  ifelse(string:rex-match ("-?[0-9]+\\.?[0-9]*") (value) )[
    output-debug-message (word value " IS AN INTEGER OR FLOATING POINT NUMBER.  REPORTING THE RESULT OF APPLYING THE 'read-from-string' PRIMITIVE TO IT...") ("")
    set debug-indent-level (debug-indent-level - 2)
    report read-from-string (value)
  ]
  [
    output-debug-message (word value " IS NOT AN INTEGER OR FLOATING POINT NUMBER.  CHECKING TO SEE IF IT IS A BOOLEAN VALUE...") ("")
    ifelse(string:rex-match ("true|false") (value))[
      output-debug-message (word value " IS A BOOLEAN VALUE, DETERMINING WHETHER TRUE OR FALSE SHOULD BE REPORTED...") ("")
      ifelse(string:rex-match ("true") (value))[
        output-debug-message (word value " MATCHES 'true' SO BOOLEAN 'true' WILL BE REPORTED.") ("")
        set debug-indent-level (debug-indent-level - 2)
        report true
      ]
      [
        output-debug-message (word value " MATCHES 'false' SO BOOLEAN 'false' WILL BE REPORTED.") ("")
        set debug-indent-level (debug-indent-level - 2)
        report false
      ]
    ]
    [
      output-debug-message (word value " IS NOT A BOOLEAN VALUE, REPORTING THE RESULT OF ENCLOSING IT WITH DOUBLE QUOTES") ("")
      set debug-indent-level (debug-indent-level - 2)
      report (word "\"" value "\"")
    ]
  ]
end
         
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "RECTIFY-HEADING" PROCEDURE ;;; - MAY NO LONGER BE NEEDED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Reports one of 0, 90, 180 or 270 if the heading passed does not already
;;equal one of these values. If the heading passed is less than 0, it is 
;;converted to its positive equivalent and this converted value is used
;;to determine what heading is reported.  If the heading does not equal 
;;0, 90, 180 or 270 the value returned is as follows:
;;
;; - If the heading passed is 360, 0 is returned.
;; - If the heading passed is > 0 and < 90 either 0 or 90 is returned.
;; - If the heading passed is > 90 and < 180 either 90 or 180 is returned.
;; - If the heading passed is > 180 and < 270 either 180 or 270 is returned.
;; - If the heading passed is > 270 and < 360 either 270 or 0 is returned. 
;;
;;The non-determinism of the value reported ensures that the calling turtle
;;does not repeat the same action over and over e.g. if a calling turtle's
;;closest tile is to the south-east and the calling turtle turns to face this
;;tile and its heading is then rectified, it has a 1 in 2 chance of setting 
;;its heading east or south rather than always setting its heading to the east
;;or always to the south.  Thus, the behaviour of the calling turtle is more 
;;flexible.
;;
;;         Name              Data Type     Description
;;         ----              ---------     -----------
;;@param   heading-to-recify Float         The heading to be rectified.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to-report rectify-heading [heading-to-rectify]
; set debug-indent-level (debug-indent-level + 1)
; output-debug-message ("EXECUTING THE 'recitify-heading' PROCEDURE...") ("")
; set debug-indent-level (debug-indent-level + 1)
; output-debug-message (word "THE VALUE OF THE LOCAL VARIABLE 'heading-to-rectify' IS: '" heading-to-rectify "'.") ("")
; 
; if(heading-to-rectify = 360)[
;   output-debug-message (word "'heading-to-rectify' IS EQUAL TO 360, REPORTING 0") ("")
;   set debug-indent-level (debug-indent-level - 2)
;   report 0
; ]
; 
; if(heading-to-rectify < 0)[
;   set heading-to-rectify (360 + heading-to-rectify)
;   output-debug-message ("'heading-to-rectify' IS LESS THAN 0, SO 360 HAS BEEN ADDED TO IT TO CONVERT IT TO A POSITIVE VALUE.") ("")
;   output-debug-message(word "'heading-to-rectify' IS NOW EQUAL TO: '" heading-to-rectify "'.") ("")
; ]
; 
; output-debug-message ("SETTING THE LOCAL 'random-decision' VARIABLE VALUE...") ("")
; let random-decision (random 2)
; output-debug-message (word "THE LOCAL 'random-decision' VARIABLE VALUE IS NOW SET TO: " random-decision "...") ("")
; output-debug-message (word "CHECKING THE VALUE OF THE LOCAL 'heading-to-rectify' VARIABLE VALUE (" heading-to-rectify ")...") ("")
; 
; if( (heading-to-rectify > 0) and (heading-to-rectify < 90) )[
;   output-debug-message (word "THE LOCAL 'heading-to-rectify' VARIABLE VALUE IS > 0 AND < 90...") ("")
;   ifelse( random-decision = 0 )[
;     output-debug-message (word "REPORTING " (item (0) (movement-headings)) "...") ("")
;     set debug-indent-level (debug-indent-level - 2)
;     report (item (0) (movement-headings))
;   ]
;   [
;     output-debug-message (word "REPORTING " (item (1) (movement-headings)) "...") ("")
;     set debug-indent-level (debug-indent-level - 2)
;     report (item (1) (movement-headings))
;   ]
; ]
; 
; if( (heading-to-rectify > 90) and (heading-to-rectify < 180) )[
;   output-debug-message (word "THE LOCAL 'heading-to-rectify' VARIABLE VALUE IS > 90 AND < 180...") ("")
;   ifelse( random-decision = 0 )[
;     output-debug-message (word "REPORTING " (item (1) (movement-headings)) "...") ("")
;     set debug-indent-level (debug-indent-level - 2)
;     report (item (1) (movement-headings))
;   ]
;   [
;     output-debug-message (word "REPORTING " (item (2) (movement-headings)) "...") ("")
;     set debug-indent-level (debug-indent-level - 2)
;     report (item (2) (movement-headings))
;   ]
; ]
; 
; if( (heading-to-rectify > 180) and (heading-to-rectify < 270) )[
;   output-debug-message (word "THE LOCAL 'heading-to-rectify' VARIABLE VALUE IS > 180 AND < 270...") ("")
;   ifelse( random-decision = 0 )[
;     output-debug-message (word "REPORTING " (item (2) (movement-headings)) "...") ("")
;     set debug-indent-level (debug-indent-level - 2)
;     report (item (2) (movement-headings))
;   ]
;   [
;     output-debug-message (word "REPORTING " (item (3) (movement-headings)) "...") ("")
;     set debug-indent-level (debug-indent-level - 2)
;     report (item (3) (movement-headings))
;   ]
; ]
; 
; if( (heading-to-rectify > 270) and (heading-to-rectify < 360) )[
;   output-debug-message (word "THE LOCAL 'heading-to-rectify' VARIABLE VALUE IS > 270 AND < 360...") ("")
;   ifelse( random-decision = 0 )[
;     output-debug-message (word "REPORTING " (item (3) (movement-headings)) "...") ("")
;     set debug-indent-level (debug-indent-level - 2)
;     report (item (3) (movement-headings))
;   ]
;   [
;     output-debug-message (word "REPORTING " (item (0) (movement-headings)) "...") ("")
;     set debug-indent-level (debug-indent-level - 2)
;     report (item (0) (movement-headings))
;   ]
; ]
; 
; output-debug-message ("THE LOCAL 'heading-to-rectify' VARIABLE VALUE IS SET TO EITHER 0, 90, 180 or 270, REPORTING THIS VALUE...") ("")
; set debug-indent-level (debug-indent-level - 2)
; report heading-to-rectify
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "REINFORCE-VISUAL-ACTION-LINKS" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Uses a turtle's reinforcement learning theory to reinforce all visual-action 
;links in episodic memory if the turtle is able to do so.
;
;The procedure also reinforces heruistic deliberation if the turtle is able to
;do so and the action pattern in the visual-action link in question was generated
;using heuristic deliberation. 
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
to reinforce-visual-action-links
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'reinforce-visual-action-links' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  if(breed = chrest-turtles)[
    let rlt ("null")
    set rlt (chrest:get-reinforcement-learning-theory)
  
    output-debug-message (word "Checking to see if my reinforcement learning theory is set to 'null' (" rlt ").  If so, I won't continue with this procedure...") (who)
    if(rlt != "null")[
      
      output-debug-message ("Retrieving each of the items in my 'visual-action-time-heuristics' list and reinforcing the links between the patterns...") (who)
      output-debug-message (word "Time that reward was awarded: " report-current-time "s.") (who)
      output-debug-message (word "The contents of my 'episodic-memory' list is: " episodic-memory) (who)
      
      foreach(episodic-memory)[
        output-debug-message (word "Processing the following item: " ? "...") (who)
        output-debug-message (word "Visual pattern is: " (item (0) (?))) (who)
        output-debug-message (word "Action pattern is: " (item (1) (?))) (who)
        output-debug-message (word "Action pattern was performed at time " (item (2) (?)) "s") (who)
        output-debug-message (word "Was pattern-recognition used to determine that this action pattern should be performed: " (item (3) (?))) (who)
        
        ;ADDED THIS COMMENT ON THE 23RD OCTOBER 2015: ORIGINALLY LOCATED IN "perform-action" PROCEDURE BUT I HAD GOTTEN CONFUSED AND
        ;REALISED THAT WHAT I WAS TRYING TO FIGURE OUT IS WHETHER PROBLEM-SOLVING OR PATTERN-RECOGNITION SHOULD BE REINFORCED.  ESSENTIALLY,
        ;YOU SHOULD ASSUME THAT THE ACTUAL ACTION IS TO BE REINFORCED AND JUST CHECK THAT THE TWO CONDITIONS LEADING TO PROBLEM-SOLVING
        ;BEING REINFORCED INSTEAD APPLY.  IF SO, OVERWRITE THE ACTION TO BE REINFORCED WITH THE PROBLEM-SOLVING ACTION. I COMMENTED OUT
        ;THE REMAINDER OF THE CONDITIONAL CODE BELOW TO PREVENT CONFUSION TOO.
        ;
        ; | Reinf PS? | Reinf Action? | PS Generate Action? | Outcome
        ; | Yes       | Yes           | Yes                 | Choice between PS and action
        ; |           |               | No                  | Reinforce action
        ; |           | No            | Yes                 | Reinforce PS
        ; |           |               | No                  | -
        ; | No        | Yes           | Yes                 | Reinforce action
        ; |           |               | No                  | Reinforce action
        ; |           | No            | Yes                 | -
        ; |           |               | No                  | Impossible since if PS not used to generate action, PR must have been but turtle can't reinforce PS or action so PS can't be used!
        
        ;      output-debug-message (word chrest:ListPattern.get-as-string (item (0) (?)) "'s action links before reinforcement: " (chrest:recognise-list-pattern-and-return-nodes-with-modality (item (0) (?)) ("action") (report-current-time)) ) (who)
        ;     
        ;      output-debug-message (word "Checking to see if I am able to reinforce problem-solving (" reinforce-problem-solving? ") and if this action was generated by pattern-recognition (" (item (3) (?)) ")...") (who)
        ;      if( (reinforce-problem-solving?) and not (item (3) (?)) )[
        ;        output-debug-message (word "Since I am able to reinforce problem-solving and this action was not generated by pattern-recognition, I'll reinforce the link between this visual pattern and problem-solving...") (who)
        ;        chrest:reinforce-action-link
        ;          (item (0) (?)) 
        ;          (chrest:ListPattern.new ("action") (chrest:ItemSquarePattern.new (problem-solving-token) (0) (0)))
        ;          (list (reward-value) (discount-rate) (report-current-time) (item (2) (?)))
        ;          (report-current-time)
        ;      ]
        ;      
        ;      output-debug-message (word "Checking to see if I am able to reinforce actions (" reinforce-actions? ")...") (who)
        ;      if( reinforce-actions? )[
        ;        output-debug-message (word "I can reinforce actions so I will...") (who)
        ;        chrest:reinforce-action-link 
        ;          (item (0) (?)) 
        ;          (item (1) (?)) 
        ;          (list (reward-value) (discount-rate) (report-current-time) (item (2) (?)))
        ;          (report-current-time)
        ;      ]
        ;      
        ;      output-debug-message (word chrest:ListPattern.get-as-string (item (0) (?)) "'s action links after reinforcement: " ( chrest:recognise-list-pattern-and-return-nodes-with-modality (item (0) (?)) ("action") (report-current-time) ) ) (who)
      ]
      
      output-debug-message ("Reinforcement of visual-action patterns complete.  Clearing my 'visual-action-time-heuristics' list...") (who)
      set episodic-memory []
      output-debug-message (word "My 'episodic-memory' list is now equal to: " episodic-memory "...") (who)
    ]
  ]
  
  set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "REMOVE-PLAYERS" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Hides all non "tiles" and "holes" turtle breeds if their 'training-time' or
;'game-time' variable values are equal to the 'current-training-time' or 
;'current-game-time" variable values.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to remove-players
 set debug-indent-level (debug-indent-level + 1)
 output-debug-message ("EXECUTING 'remove-players' PROCEDURE...") ("")
 set debug-indent-level (debug-indent-level + 1)
 
 output-debug-message ("ASKING ALL chrest-turtles TO SET THEIR 'hidden?' VARIABLE TO TRUE IF THEIR 'training-time' OR 'play-time' VARIABLE IS LESS THAN/EQUAL TO 'current-training-time' OR 'current-game-time'...") ("")
 ask chrest-turtles[
   output-debug-message (word "Checking to see if I am playing the game in a training context i.e is the global 'training?' variable (" training? ") set to true?") (who)
   ifelse(training?)[
     output-debug-message (word "I am playing the game in a training context so I need to check and see if my 'training-time' variable (" training-time ") is equal to the global 'current-training-time' variable (" current-training-time ").") (who)
     if(current-training-time = training-time)[
       output-debug-message ("My 'training-time' variable is equal to the global 'current-training-time' value so I'll set my 'hidden?' variable to true...") (who)
       set hidden? true
     ]
   ]
   [
     output-debug-message (word "I am playing the game in a non-training context so I need to check and see if my 'play-time' variable (" play-time ") is equal to the global 'current-game-time' variable (" current-game-time ").") (who)
     if(current-game-time = play-time)[
       output-debug-message ("My 'play-time' variable is equal to the global 'current-game-time' value so I'll set my 'hidden?' variable to true...") (who)
       set hidden? true
     ]
   ]
 ]
 
 set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "REPORT-CURRENT-TIME" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Reports the current time by determining if the game is currently 
;being played in a training context or not.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to-report report-current-time
 ifelse(training?)[
   report current-training-time
 ]
 [
   report current-game-time
 ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "RESET" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;Resets the model.  How this is done is dependent upon whether the model is being run
;in a testing context or not.  If it isn't, everything will be reset, if it is, only
;ticks, turtles and patches will be reset.  In addition, the "testing-debug-messages"
;global variable will be reset to 0 otherwise memory will be depleted quickly and tests 
;will run extremely slowly.  All other global variables are not reset, however.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to reset [testing]
  file-close-all
  
  ifelse(testing)[
    clear-ticks
    clear-turtles
    clear-patches
    set testing-debug-messages ""
  ]
  [
    __clear-all-and-reset-ticks
  ]
end
         
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "ROULETTE-SELECTION" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Selects an action to perform from a list of action patterns and their
;associated optimality weights using the "roulette" action selection 
;algorithm.
;
;         Name                 Data Type     Description
;         ----                 ---------     -----------
;@param   actions-and-weights  List          A list containing lists of "jchrest.architecture.Node"
;                                            instances (action chunks) and optimality ratings (numbers),
;                                            i.e. [[<Node> 2] [<Node> 3]]
;@return  -                    String        The action pattern to perform formatted as:
;                                            "[act-token heading patches]".
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to-report roulette-selection [actions-and-optimality-ratings]
 set debug-indent-level (debug-indent-level + 1)
 output-debug-message ("EXECUTING THE 'roulette-selection' PROCEDURE...") ("")
 set debug-indent-level (debug-indent-level + 1)
 output-debug-message (word "The actions and optimality ratings to work with are: " ( map ([ map ([ (chrest:ListPattern.get-as-string (chrest:Node.get-image (item (0) (?)))) ]) (?) ]) (actions-and-optimality-ratings) ) ) (who)
 
 let candidate-actions-and-optimality-ratings []
 foreach(actions-and-optimality-ratings)[
   foreach(?)[
     output-debug-message (word "Checking to see if " (item (1) (?)) " is greater than 0.0.  If so, I'll add it to the 'candidate-actions-and-weights' list...") (who)
     if( (item (1) (?)) > 0.0 )[
       output-debug-message (word (item (1) (?)) " is greater than 0.0, adding it to the 'candidate-actions-and-optimality-ratings' list...") (who)
       set candidate-actions-and-optimality-ratings (lput (?) (candidate-actions-and-optimality-ratings))
     ]
   ]
 ]
 
 output-debug-message (word "Checking to see if the 'candidate-actions-and-optimality-ratings' list is empty (" (empty? candidate-actions-and-optimality-ratings) ").") (who)
 ifelse(empty? candidate-actions-and-optimality-ratings)[
   output-debug-message ("The 'candidate-actions-and-optimality-ratings' list is empty, reporting an empty list...") (who)
   set debug-indent-level (debug-indent-level - 2)
   report []
 ]
 [
   output-debug-message ("The 'candidate-actions-and-optimality-ratings' list is not empty, processing its items...") (who)
   output-debug-message (word "The 'candidate-actions-and-optimality-ratings' list contains: " ( map ([ (list ( chrest:ListPattern.get-as-string (chrest:Node.get-image (item (0) (?))) ) (item (1) (?) )) ]) (candidate-actions-and-optimality-ratings) ) ".") (who)
   
   output-debug-message ("First, I'll sum together the weights of all actions in 'candidate-actions-and-optimality-ratings'") (who)
   let sum-of-weights 0
   foreach(candidate-actions-and-optimality-ratings)[
     set sum-of-weights ( sum-of-weights + (item (1) (?)) )
   ]
   output-debug-message (word "The sum of all weights is: " sum-of-weights ".")  (who)
   
   output-debug-message ("Now, I need to build normalised ranges of values for the actions in the 'candidate-actions-and-optimality-ratings' list...") (who)
   let action-value-ranges []
   let range-min 0
   foreach(candidate-actions-and-optimality-ratings)[
     output-debug-message (word "The minimum range for action " (chrest:ListPattern.get-as-string (chrest:Node.get-image (item (0) (?)))) " is currently set to: " range-min "...") (who)
     let range-max (range-min + ( (item (1) (?)) / sum-of-weights) )
     output-debug-message (word "The max range for action " (chrest:ListPattern.get-as-string (chrest:Node.get-image (item (0) (?)))) " is currently set to: " range-max "...") (who) 
     set action-value-ranges (lput (list (item (0) (?)) (range-min) (range-max) ) (action-value-ranges) )
     set range-min (range-max)
   ]
   output-debug-message (word "After processing each 'candidate-actions-and-optimality-ratings' item, the 'action-value-ranges' variable is equal to: " (map ([ (list (chrest:ListPattern.get-as-string (chrest:Node.get-image (item (0) (?)))) (item (1) (?)) (item (2) (?))) ]) (action-value-ranges)) "...") (who)
   
   output-debug-message (word "The maximum max range value should be equal to 1.0 (" (item (2) (last action-value-ranges)) "), checking if this is the case...") (who)
   ifelse((item (2) (last action-value-ranges)) = 1.0)[
     output-debug-message ("The maximum max range value is equal to 1.0.  Generating a random float, 'r', that is >= 0 and < 1.0.  This will be used to select an action...") (who)
     let r (random-float 1.0)
     output-debug-message (word "The variable 'r' = " r) (who)
     
     output-debug-message ("Checking each item in the 'action-value-ranges' variable to see if 'r' is between its min and max range.  If it is, that action will be selected...") (who)
     foreach(action-value-ranges)[
       output-debug-message (word "Processing item: " ( list (chrest:ListPattern.get-as-string (chrest:Node.get-image (item (0) (?)))) (item (1) (?)) (item (2) (?)) ) "...") (who)
       output-debug-message (word "Checking if 'r' (" r ") is >= " (item (1) (?)) " and < " (item (2) (?)) "...") (who)
       if( ( r >= (item (1) (?)) ) and ( r < (item (2) (?)) ) )[
         output-debug-message (word "'r' is in the range of values for action " (chrest:ListPattern.get-as-string (chrest:Node.get-image (item (0) (?)))) ", reporting this as the action to perform..." ) (who)
         set debug-indent-level (debug-indent-level - 2)
         report (item (0) (?))
       ]
       output-debug-message (word "'r' is not in the range of values for action " (chrest:ListPattern.get-as-string (chrest:Node.get-image (item (0) (?)))) ".  Processing next item...") (who)
     ]
   ]
   [
     output-debug-message ("The max range value is not equal to 1.0, reporting an empty list") (who)
     set debug-indent-level (debug-indent-level - 2)
     report []
   ]
 ]
end
         
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "SCHEDULED-TO-PERFORM-ACTION-IN-FUTURE?" PROCEDURE ;;; - CHECK IF THIS IS NEEDED ANYMORE!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;Checks the calling turtle's 'time-to-perform-next-action' variable against either
;;the 'current-training-time' or 'current-game-time' depending on whether the game
;;is being played in a training context or not.
;;
;;         Name              Data Type     Description
;;         ----              ---------     -----------
;;@returns -                 Boolean       True returned if the value of the calling turtle's 
;;                                         'time-to-perform-next-action' variable is greater 
;;                                         than the value of the local 'current-time' variable.  
;;                                         False is returned if not.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to-report scheduled-to-perform-action-in-future?
; set debug-indent-level (debug-indent-level + 1)
; output-debug-message (word "EXECUTING THE 'scheduled-to-perform-action-in-future?' PROCEDURE...") ("")
; set debug-indent-level (debug-indent-level + 1)
; 
; output-debug-message (word "CHECKING THE VALUE OF THE GLOBAL 'training?' VARIABLE (" training? ") TO SEE IF THE GAME IS BEING PLAYED IN A TRAINING CONTEXT OR NOT.  'true' IF IT IS, 'false' IF NOT...") ("")
; output-debug-message (word "A LOCAL VARIABLE: 'current-time' WILL BE SET TO EITHER THE VALUE OF 'current-training-time' (" current-training-time ") OR 'current-game-time' (" current-game-time ") DEPENDING ON WHETHER THE GAME IS BEING PLAYED IN A TRAINING CONTEXT OR NOT...") ("")
; output-debug-message (word "THE LOCAL 'current-time' VARIABLE WILL THEN BE CHECKED AGAINST THE VALUE OF THE CALLING TURTLE's 'time-to-perform-next-action' VARIABLE TO SEE IF IT IS SCHEDULED TO PERFORM AN ACTION IN THE FUTURE...") ("")
; let current-time 0
; ifelse(training?)[ set current-time (current-training-time) ][ set current-time (current-game-time) ]
; 
; output-debug-message (word "Comparing the value of my 'time-to-perform-next-action' variable (" time-to-perform-next-action ") against the value of the local 'current-time' variable (" current-time ")...") (who)
; 
; ifelse(time-to-perform-next-action > current-time)[
;   output-debug-message ("The value of my 'time-to-perform-next-action' variable is greater than the value of the local 'current-time' variable.") (who)
;   output-debug-message ("I am therefore scheduled to perform an action in the future.  Reporting 'true'...") (who)
;   set debug-indent-level (debug-indent-level - 2)
;   report true
; ]
; [
;   set debug-indent-level (debug-indent-level - 2)
;   report false
; ]
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "SCHEDULED-TO-PERFORM-ACTION-NOW?" PROCEDURE ;;; - CHECK IF THIS IS NEEDED ANYMORE!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Checks the calling turtle's 'time-to-perform-next-action' variable against either
;;the 'current-training-time' or 'current-game-time' depending on whether the game
;;is being played in a training context or not.
;;
;;         Name              Data Type     Description
;;         ----              ---------     -----------
;;@returns -                 Boolean       True returned if the value of the calling turtle's 
;;                                         'time-to-perform-next-action' variable is greater 
;;                                         than the value of the local 'current-time' variable.  
;;                                         False is returned if not.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to-report scheduled-to-perform-action-now?
; set debug-indent-level (debug-indent-level + 1)
; output-debug-message (word "EXECUTING THE 'scheduled-to-perform-action-now?' PROCEDURE...") ("")
; set debug-indent-level (debug-indent-level + 1)
; 
; output-debug-message (word "CHECKING THE VALUE OF THE GLOBAL 'training?' VARIABLE (" training? ") TO SEE IF THE GAME IS BEING PLAYED IN A TRAINING CONTEXT OR NOT.  'true' IF IT IS, 'false' IF NOT...") ("")
; output-debug-message (word "A LOCAL VARIABLE: 'current-time' WILL BE SET TO EITHER THE VALUE OF 'current-training-time' (" current-training-time ") OR 'current-game-time' (" current-game-time ") DEPENDING ON WHETHER THE GAME IS BEING PLAYED IN A TRAINING CONTEXT OR NOT...") ("")
; output-debug-message (word "THE LOCAL 'current-time' VARIABLE WILL THEN BE CHECKED AGAINST THE VALUE OF THE CALLING TURTLE's 'time-to-perform-next-action' VARIABLE TO SEE IF IT IS SCHEDULED TO PERFORM AN ACTION NOW...") ("")
; let current-time 0
; ifelse(training?)[ set current-time (current-training-time) ][ set current-time (current-game-time) ]
; 
; output-debug-message (word "Comparing the value of my 'time-to-perform-next-action' variable (" time-to-perform-next-action ") against the value of the local 'current-time' variable (" current-time ")...") (who)
; ifelse(time-to-perform-next-action = current-time)[
;   output-debug-message ("The value of my 'time-to-perform-next-action' variable is equal to the value of the local 'current-time' variable.") (who)
;   output-debug-message ("I am therefore scheduled to perform an action now.  Reporting 'true'...") (who)
;   set debug-indent-level (debug-indent-level - 2)
;   report true
; ]
; [
;   set debug-indent-level (debug-indent-level - 2)
;   report false
; ]
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "SETUP" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
;The setup procedure performs a number of tasks in the following order:
;
; 1. Set global and turtle-specific variables using hard-coded values.
; 2. Set global and turtle-specific variables using user-specified values.
; 3. Set hard-coded breed-specific variable values in the following order:
;    - chrest-turtles
; 4. Check variable values.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@param   testing           Boolean       Specifies whether the model is being run in a testing
;                                         context or not: true for yes, false for no.  
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to setup [testing]
  set testing? testing
  
  if(testing?)[
    set testing-debug-messages ""
  ]
  
  set debug-indent-level 0
  output-debug-message ("EXECUTING THE 'setup' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)

  ;The global "directory-separator" value is set here so that calls to 
  ;"setup" in the "test" procedure will reinstantiate it after the "reset"
  ;procedure is called after each test.
  set directory-separator pathdir:get-separator 
  
  ;Set turtle shapes
  set-default-shape chrest-turtles "turtle"
  set-default-shape tiles "box"
  set-default-shape holes "circle"
  
  ;Set action strings.
  set problem-solving-token "PS"
  set move-around-tile-token "MAT"
  set move-token "MV"
  set move-to-tile-token "MTT"
  set procedure-not-applicable-token "PNA"
  set push-tile-token "PT"
  
  ;Set object identifier strings.
  set blind-patch-token (chrest:Scene.get-blind-square-token)
  set empty-patch-token (chrest:Scene.get-empty-square-token)
  set unknown-patch-token (chrest:VisualSpatialFieldObject.get-unknown-square-token)
  set hole-token "H"
  set tile-token "T"
  set opponent-token "C"
  set self-token (chrest:Scene.get-self-identifier)
  
  ;Set other miscellaneous variables.
  set current-training-time 0
  set current-game-time 0
  set breeds extras:get-list-of-all-breed-names
  set movement-headings [ 
    0 
    90 
    180 
    270 
  ]
  set possible-actions ( list 
    (move-around-tile-token)
    (move-token)
    (move-to-tile-token)
    (push-tile-token)
  )
  set training? true
  
  output-debug-message (word "THE 'current-training-time' GLOBAL VARIABLE IS SET TO: '" current-training-time "'.") ("")
  output-debug-message (word "THE 'current-game-time' GLOBAL VARIABLE IS SET TO: '" current-game-time "'.") ("")
  output-debug-message (word "THE 'movement-headings' GLOBAL VARIABLE IS SET TO: '" movement-headings "'.") ("")
  output-debug-message (word "THE 'training?' GLOBAL VARIABLE IS SET TO: '" training? "'.") ("")
  output-debug-message (word "THE 'move-around-tile-token' GLOBAL VARIABLE IS SET TO: '" move-around-tile-token "'.") ("")
  output-debug-message (word "THE 'move-token' GLOBAL VARIABLE IS SET TO: '" move-token "'.") ("")
  output-debug-message (word "THE 'move-to-tile-token' GLOBAL VARIABLE IS SET TO: '" move-to-tile-token "'.") ("")
  output-debug-message (word "THE 'push-tile-token' GLOBAL VARIABLE IS SET TO: '" push-tile-token "'.") ("")
  output-debug-message (word "THE 'hole-token' GLOBAL VARIABLE IS SET TO: '" hole-token "'.") ("")
  output-debug-message (word "THE 'opponent-token' GLOBAL VARIABLE IS SET TO: '" opponent-token "'.") ("")
  output-debug-message (word "THE 'tile-token' GLOBAL VARIABLE IS SET TO: '" tile-token "'.") ("")
  
  setup-independent-variables
  setup-chrest-turtles (true)
  check-variable-values
  
  set debug-indent-level (debug-indent-level - 1)
  stop
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "SETUP-CHREST-TURTLES" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
;Sets up or resets CHREST turtle variables depending upon the context
;in which this procedure is called.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@params  setup-chrest?     Boolean       If set to true the procedure will 
;                                         endow all chrest-turtles with an 
;                                         instance of the CHREST architecture 
;                                         and set various parameters concerned 
;                                         with a CHREST instance's operation.
;                                         Useful when setting up CHREST turtles
;                                         after training has finished but before 
;                                         non-training begins.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to setup-chrest-turtles [setup-chrest?]
        
  ask chrest-turtles [
    set closest-tile ""
    set current-visual-pattern ""
    set heading 0
    set construct-visual-spatial-field? true
    set next-action-to-perform ""
    set plan []
    set score 0
    set time-to-perform-next-action -1 ;Set to -1 initially since if it is set to 0 the turtle will think it has some action to perform in the initial round.
    set episodic-memory []
    set sight-radius-colour (color + 2)
    set generate-plan? true
    set current-search-iteration 0
    set who-of-tile-last-pushed-in-plan ""
    
    if(setup-chrest?)[
      chrest:instantiate-chrest-in-turtle
      chrest:set-domain ( chrest:TileworldDomain.new ( list (hole-token) (opponent-token) (tile-token) ) )
    ]
      
    chrest:set-add-link-time ( add-link-time )
    chrest:set-discrimination-time ( discrimination-time)
    chrest:set-familiarisation-time ( familiarisation-time)
    chrest:set-reinforcement-learning-theory (reinforcement-learning-theory)
   
    place-randomly
    
    setup-plot-pen ("Scores") (0)
    setup-plot-pen ("Total Deliberation Time") (0)
    setup-plot-pen ("Num Visual-Action Links") (0)
    setup-plot-pen ("Random Behaviour Frequency") (1)
    setup-plot-pen ("Problem-Solving Frequency") (1)
    setup-plot-pen ("Pattern-Recognition Frequency") (1)
    setup-plot-pen ("Visual STM Size") (0)
    setup-plot-pen ("Visual LTM Size") (0)
    setup-plot-pen ("Visual LTM Avg. Depth") (0)
    setup-plot-pen ("Action STM Size") (0)
    setup-plot-pen ("Action LTM Size") (0)
    setup-plot-pen ("Action LTM Avg. Depth") (0)
    
    output-debug-message (word "My 'closest-tile' variable is set to: '" closest-tile "'.") (who)
    output-debug-message (word "My 'current-visual-pattern' variable is set to: '" current-visual-pattern "'.") (who)
    output-debug-message (word "My 'heading' variable is set to: '" heading "'.") (who)
    output-debug-message (word "My 'plan' variable is set to: '" plan "'.") (who)
    output-debug-message (word "My 'next-action-to-perform' variable is set to: '" next-action-to-perform "'.") (who)
    output-debug-message (word "My 'score' variable is set to: '" score "'.") (who)
    output-debug-message (word "My 'time-to-perform-next-action' variable is set to: '" time-to-perform-next-action "'.") (who)
    output-debug-message (word "My '_addLinkTime' CHREST variable is set to: '" chrest:get-add-link-time "' seconds.") (who)
    output-debug-message (word "My '_discriminationTime' CHREST variable is set to: '" chrest:get-discrimination-time "' seconds.") (who)
    output-debug-message (word "My '_familiarisationTime' CHREST variable is set to: '" chrest:get-familiarisation-time "' seconds.") (who)
    output-debug-message (word "My '_reinforcementLearningTheory' CHREST variable is set to: '" chrest:get-reinforcement-learning-theory "'.") (who)
 ]
end
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "SETUP-INDEPENDENT-VARIABLES" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Sets various global and turtle independent variables using an external .txt 
;file. The file to be used is determined by the current value of the 
;"current-scenario-number" variable.
;
;TODO: This could be extracted into its own extension for use by the Netlogo community.
;
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to setup-independent-variables
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'setup-independent-variables' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  ifelse(testing?)[
    file-open (word "tests" (directory-separator) (item (0) (test-info)) (directory-separator) (item (1) (test-info)) ".txt")
  ]
  [
    output-debug-message ("CHECKING TO SEE IF THE RELEVANT SCENARIO AND REPEAT DIRECTORY EXISTS") ("")
    check-for-scenario-repeat-directory
    output-debug-message (word "THE RELEVANT SCENARIO AND REPEAT DIRECTORY EXISTS.  ATTEMPTING TO OPEN " (setup-and-results-directory) "Scenario" (current-scenario-number) (directory-separator) "Scenario" (current-scenario-number) "Settings.txt" ) ("")
    file-open (word (setup-and-results-directory) "Scenario" (current-scenario-number) (directory-separator) "Scenario" (current-scenario-number) "Settings.txt" )
  ]
  
  let variable-name ""
  
  while[not file-at-end?][
    let line file-read-line
    output-debug-message (word "LINE BEING READ FROM EXTERNAL FILE IS: '" line "'") ("")
    
    output-debug-message (word "CHECKING TO SEE IF '" line "' CONTAINS ANYTHING OTHER THAN WHITE SPACE, IF IT DOESN'T THE NEXT LINE WILL BE PROCESSED") ("")
    ifelse( ( not (string:rex-match ("\\s+") (line)) ) and (line != "") )[
      output-debug-message (word "'" line "' IS NOT EMPTY SO IT WILL BE PROCESSED.") ("")
      
      output-debug-message (word "CHECKING TO SEE IF '" line "' STARTS WITH A SEMI-COLON INDICATING A NETLOGO COMMENT.  IF SO, THIS LINE WILL NOT BE PROCESSED FURTHER") ("")
      if( not string:rex-match ("^\\s*;.*") (line) )[
        ifelse( (string:rex-match "[a-zA-Z_\\-\\?]+" line) and (empty? variable-name) )[
          set variable-name line
          output-debug-message (word "'" line "' ONLY CONTAINS EITHER ALPHABETICAL CHARACTERS, HYPHENS, UNDERSCORES OR QUESTION MARKS SO IT MUST BE A VARIABLE NAME.") ("")
          output-debug-message (word "THE 'variable-name' VARIABLE IS NOW SET TO: '" variable-name "'.") ("")
        ]
        [
          output-debug-message (word "CHECKING FOR <test> IN '" line "', IF ENCOUNTERED, ALL CONTENT UNTIL </test> TAG WILL BE IGNORED..." ) ("")
          ifelse(string:rex-match ("^\\s*<test>.*") (line) )[
            while[ ( not (string:rex-match (".*<\\/test>\\s*$") (line)) ) ][
              set line file-read-line
            ]
          ]
          [
            ifelse(string:rex-match "^\\s*<run>.*" line)[
              output-debug-message (word "'" line "' STARTS WITH <run> INDICATING THAT THIS IS A NETLOGO CODE TO BE RUN USING THE 'print-and-run' PROCEDURE.  CONCATONATING SUBSEQUENT LINES WITH '' UNTIL </run> TAG IS FOUND..." ) ("")
              while[not (string:rex-match ("<.*\\/run>\\s*$") (line))][
                set line (word line (file-read-line))
              ]
              set line ( string:rex-replace-all ("<\\/run>") (string:rex-replace-all ("<run>") (line) ("")) ("") )
              print-and-run (line)
            ]
            [
              output-debug-message (word "'" line "' MUST BE A VALUE.") ("")
              
              ifelse( member? ":" line )[
                output-debug-message (word "'" line "' CONTAINS A COLON SO THE VALUE IS TO BE SET FOR ONE OR MORE TURTLE VARIABLES.  CHECKING FORMATTING OF THE LINE...") ("")
                
                output-debug-message ("CHECKING FOR MATCHING PARENTHESIS...") ("")
                if( (check-for-substring-in-string-and-report-occurrences "(" line) != (check-for-substring-in-string-and-report-occurrences ")" line) )[
                  error (word "ERROR: External model settings file line: '" line "' does not contain matching parenthesis!" )
                ]
                output-debug-message ("PARENTHESIS MATCH OR PARENTHESIS DO NOT EXIST...") ("")
                
                output-debug-message ("CHECKING FOR MORE THAN ONE PAIR OF MATCHING PARENTHESIS...") ("")
                if(
                  (check-for-substring-in-string-and-report-occurrences "(" line) = (check-for-substring-in-string-and-report-occurrences ")" line) and 
                  (check-for-substring-in-string-and-report-occurrences "(" line) > 1
                  )
                [
                  error (word "ERROR: External model settings file line: '" line "' contains more than one pair of matching parenthesis!" )
                ]
                output-debug-message ("NO MORE THAN ONE PAIR OF MATCHING PARENTHESIS EXISTS...") ("")
                
                output-debug-message ("CHECKING FOR A HYPHEN IF MATCHING PARENTHESIS EXIST...") ("")
                if(
                  (check-for-substring-in-string-and-report-occurrences "(" line) = (check-for-substring-in-string-and-report-occurrences ")" line) and
                  (check-for-substring-in-string-and-report-occurrences "(" line) = 1 and 
                  not member? "-" line 
                  )
                [
                  error (word "ERROR: External model settings file line: '" line "' does not contain a hyphen in turtle ID specification!" )
                ]
                output-debug-message ("LINE CONTAINS A HYPHEN AND ONE PAIR OF MATCHING PARENTHESIS...") ("")
                
                output-debug-message ("CHECKING FOR MATCHING PARENTHESIS IF A HYPHEN EXISTS...") ("")
                if( string:rex-match ("^\\d+-\\d+:") (line) )[
                  error (word "ERROR: External model settings file line: '" line "' contains a hyphen but no parenthesis in group ID specification!" )
                ]
                output-debug-message ("HYPHEN IS SPECIFIED ALONG WITH MATCHING PARENTHESIS") ("")
                
                output-debug-message (word "'" line "' IS FORMATTED CORRECTLY.") ("")
                
                ifelse( member? "(" line )[
                  output-debug-message (word "'" line "' CONTAINS A '(' SO THE '" variable-name "' VARIABLE FOR A NUMBER OF TURTLES SHOULD BE SET...") ("")
                  
                  let turtle-id read-from-string ( substring line ( (position "(" line) + 1 ) (position "-" line) )
                  let last-turtle-id read-from-string ( substring line ( (position "-" line) + 1 ) (position ")" line) )
                  let value-specified ( quote-string-or-read-from-string ( substring line ( (position ":" line) + 1 ) (length line) ) )
                  
                  while[turtle-id <= last-turtle-id][
                    output-debug-message (word "TURTLE " turtle-id "'s '" variable-name "' VARIABLE WILL BE SET TO: '" value-specified "'.") ("")
                    
                    ask turtle turtle-id[ 
                      print-and-run (word "set " variable-name " " value-specified)
                    ]
                    
                    set turtle-id (turtle-id + 1)
                  ]
                ]
                [
                  output-debug-message (word "'" line "' DOES NOT CONTAIN A '(' SO THE '" variable-name "' VARIABLE FOR ONE TURTLE SHOULD BE SET...") ("")
                  
                  let turtle-id read-from-string ( substring line 0 (position ":" line ) )
                  let value-specified ( quote-string-or-read-from-string ( substring line ( (position ":" line) + 1 ) (length line) ) )
                  output-debug-message (word "TURTLE " turtle-id "'s '" variable-name "' VARIABLE WILL BE SET TO: '" value-specified "'.") ("")
                  
                  ask turtle turtle-id[ 
                    print-and-run (word "set " variable-name " " value-specified)
                  ]
                ]
              ]
              [
                output-debug-message (word "'" line "' DOES NOT CONTAIN A ':' SO '" variable-name "' IS A GLOBAL VARIABLE...") ("")
                output-debug-message (word "'" variable-name "' will therefore be set to: " quote-string-or-read-from-string (line) "...") ("")
                print-and-run (word "set " variable-name " " (quote-string-or-read-from-string (line) ) )
              ]
            ]
          ]
        ]
      ]
    ]
    [
      output-debug-message (word "'" line "' IS EMPTY THEREFORE, THE 'variable-name' VARIABLE WILL BE SET TO EMPTY...") ("")
      set variable-name ""
    ]
    
    ifelse(testing?)[
      file-open (word "tests" (directory-separator) (item (0) (test-info)) (directory-separator) (item (1) (test-info)) ".txt")
    ]
    [
      file-open (word setup-and-results-directory "Scenario" current-scenario-number directory-separator "Scenario" current-scenario-number "Settings.txt" )
    ]
  ]
  
  file-close
  set debug-indent-level (debug-indent-level - 2)
end
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "SETUP-PLOT-PEN" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Creates a pen for the turtle calling this function on the plot specified by
;the parameter passed to this procedure and sets the x-axis interval to be
;whatever the 'time-increment' value is currently set to.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@param   name-of-plot      String        The name of the plot to create the calling 
;                                         turtle's pen on.
;@param   mode-of-pen       Number        The mode that the pen should be set to.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to setup-plot-pen [name-of-plot mode-of-pen]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'setup-plot-pen' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message (word "Setting my plot pen for the '" name-of-plot "' plot.") (who)
  
  set-current-plot name-of-plot
  create-temporary-plot-pen (word "Turtle " who)
  set-current-plot-pen (word "Turtle " who)
  set-plot-pen-color color
  set-plot-pen-mode (mode-of-pen)
  
  set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "SHORTEST-DISTANCE-FROM-LOCATION-TO-LOCATION" PROCEDURE ;;; - MAY NO LONGER BE NEEDED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Reports the least number of patches that would need to be traversed to
;get from the location specified to the location specified if movement
;headings are unrestricted and environment wrapping is enabled.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@param   from-location     String        The location to calculate distance from.
;                                         Should be formatted as the string representation
;                                         of a CHREST-compatible "ItemSquarePattern"
;                                         instance, i.e. "[object-id xcor ycor]".
;@param   to-location       String        The location to calculate distance to.
;                                         Should be formatted as the string representation
;                                         of a CHREST-compatible "ItemSquarePattern"
;                                         instance, i.e. "[object-id xcor ycor]".
;@return  -                 Number        See procedure description.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to-report shortest-distance-from-location-to-location [from-location to-location]
;  set debug-indent-level (debug-indent-level + 1)
;  output-debug-message ("EXECUTING THE 'shortest-distance-from-location-to-location' PROCEDURE...") ("")
;  set debug-indent-level (debug-indent-level + 1)
;  
;  let from-location-xcor ( chrest:ItemSquarePattern.get-column (from-location) )
;  let from-location-ycor ( chrest:ItemSquarePattern.get-row (from-location) )
;      
;  let to-location-xcor ( chrest:ItemSquarePattern.get-column (to-location) )
;  let to-location-ycor ( chrest:ItemSquarePattern.get-row (to-location) )
;      
;  output-debug-message (word "The x/ycor values to calculate the shortest distance between when wrapping is enabled are '" from-location-xcor "'/'" from-location-ycor "' and '" to-location-xcor "'/'" to-location-ycor "', respectively...") (who)
;  set debug-indent-level (debug-indent-level - 2)
;  report ( extras:distance (from-location-xcor) (from-location-ycor) (to-location-xcor) (to-location-ycor) (true) )
;end
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "SPECIFY-DEBUG-MESSAGE-OUTPUT-FILE" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Allows the user to specify where debug message should be output to since 
;the quantity of these messages quickly depletes the space available in 
;the Java heap.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to specify-debug-message-output-file
 user-message "Since you have enabled debug mode, please specify where you would like to write debug information to on the next dialog that appears.  To have debug messages output to the command center simply click 'Cancel' on the next dialog that appears."
 set debug-message-output-file (user-new-file)
 if(debug-message-output-file != false)[
   if(file-exists? debug-message-output-file)[
     file-delete debug-message-output-file 
   ]
   file-open debug-message-output-file
 ]
end
             
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "SURROUNDED?" PROCEDURE ;;; - MAY NO LONGER BE NEEDED
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;Determines whether the calling turtle is surrounded by checking to see if either 
;;condition that follows is true for each item, n, in the global 'movement-headings' 
;;variable:
;;
;; - Is there a turtle other than a tile on the patch immediately ahead of the calling
;;   turtle with heading n?
;; - If there is a tile on the patch immediately ahead of the calling turtle with 
;;   heading n, is there another turtle other than a hole on the patch that is 2 
;;   patches away from the calling turtle with heading n?
;;
;;If these conditions are true for all items in the global 'movement-headings' 
;;variable then the calling turtle is surrounded. 
;;
;;         Name              Data Type          Description
;;         ----              ---------          -----------
;;@param   scene             jchrest.lib.Scene  The scene to evaluate.
;;@return  -                 Boolean            Boolean true indicates that the calling turtle is
;;                                              surrounded, boolean false indicates that the calling 
;;                                              turtle is not surrounded.
;;
;;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
;to-report surrounded? [scene]
; set debug-indent-level (debug-indent-level + 1)
; output-debug-message ("EXECUTING THE 'surrounded?' PROCEDURE...") ("")
; set debug-indent-level (debug-indent-level + 1)
; 
; output-debug-message ("Setting the local 'headings-blocked' and 'heading-item' variable values to an empty list and 0, respectively...") (who)
; let headings-blocked []
; let heading-item 0
; output-debug-message (word "The local 'headings-blocked' and 'heading-item' variable values are now set to: '" headings-blocked "' and '" heading-item "'...") (who)
; 
; output-debug-message (word "Setting the local 'location-of-self' variable to the location of myself in the scene I am to analyse so I can determine if I am surrounded...") (who)
; let location-of-self ( chrest:Scene.get-location-of-creator (scene) )
; output-debug-message (word "The local 'location-of-self' variable is now set to: '" location-of-self "'.") (who)
; let self-xcor ( item (0) (location-of-self) )
; let self-ycor ( item (1) (location-of-self) )
;  
; let xcor-of-adjacent-patch 0
; let ycor-of-adjacent-patch 0
; let xcor-of-patch-ahead-of-adjacent-patch 0
; let ycor-of-patch-ahead-of-adjacent-patch 0
; 
; while[heading-item < length movement-headings][
;   let heading-to-check (item (heading-item) (movement-headings))
;   
;   let object-on-adjacent-patch ( item (1) (get-object-and-patch-coordinates-ahead-of-location-in-scene (scene) (heading-to-check) (1)) )
;   let object-on-patch-ahead-of-adjacent-patch ( item (1) (get-object-and-patch-coordinates-ahead-of-location-in-scene (scene) (heading-to-check) (2)) )
;   
;   
;   output-debug-message (word "With heading " heading-to-check "the object on the patch adjacent to me is: '" object-on-adjacent-patch "' and the object on the patch ahead of the patch adjacent to me is: '" object-on-patch-ahead-of-adjacent-patch "'.") (who)
;   if(
;     ;Check that the patch adjacent to the calling turtle along the heading specified is not empty, not a "blind spot" and contains an object other than a tile.
;     (
;       object-on-adjacent-patch != tile-token and 
;       object-on-adjacent-patch != empty-patch-token and 
;       object-on-adjacent-patch != blind-patch-token
;     ) or
;     ;Check that the adjacent patch contains a tile and the patch ahead of this adjacent patch is not empty, a "blind spot" and doesn't contain a hole.
;     (
;       object-on-adjacent-patch = tile-token and
;       object-on-patch-ahead-of-adjacent-patch != hole-token and
;       object-on-patch-ahead-of-adjacent-patch != empty-patch-token and
;       object-on-patch-ahead-of-adjacent-patch != blind-patch-token
;     )
;   )[
;     output-debug-message (word "Either, the patch adjacent to me with heading " heading-to-check " contains a non-moveable object or a non-moveable tile so I'll add " heading-to-check " to the local 'headings-blocked' list...") (who)
;     set headings-blocked (lput (heading-to-check) (headings-blocked))
;     output-debug-message (word "The local 'headings-blocked' variable is now set to: " headings-blocked ".  Checking the next heading in the global 'movement-headings' variable...") (who)
;   ]
;   
;   ;TODO: CONSIDER INCREMENTING DELIBERATION TIME HERE.
;   set heading-item (heading-item + 1)
; ]
; 
; output-debug-message (word "Checking the length of the local 'headings-blocked' list (" length headings-blocked ").  If this is equal to the length of the global 'movement-headings' list (" length movement-headings ") then I'm surrounded...") (who)
; ifelse( (length headings-blocked) = (length movement-headings) )[
;   output-debug-message ("The length of the local 'headings-blocked' list is equal to the length of the global 'movement-headings' list so I am surrounded...") (who)
;   set debug-indent-level (debug-indent-level - 2)
;   report true
; ]
; [
;   output-debug-message ("The length of the local 'headings-blocked' list is not equal to the length of the global 'movement-headings' list so I am not surrounded...") (who)
;   set debug-indent-level (debug-indent-level - 2)
;   report false
; ]
;   
;end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "UPDATE-PLOT-NO-X-AXIS-VALUE" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Plots the value specified by the second parameter passed to this function on
;the y-axis of the plot specified by the first parameter passed to this function
;for the calling turtle.  The x-axis value where the value is plotted is 
;determined by the plot's x-interval value.
;
;         Name              Data Type     Description
;         ----              ---------     -----------                                          
;@param   name-of-plot      String        The name of the plot to be updated.
;@param   value             Double        The value to be plotted.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to update-plot-no-x-axis-value [name-of-plot value]
 set debug-indent-level (debug-indent-level + 1)
 output-debug-message ("EXECUTING THE 'update-plot' PROCEDURE...") ("")
 set debug-indent-level (debug-indent-level + 1)
 
 output-debug-message ("CHECKING TO SEE IF THE 'draw-plots?' VARIABLE IS SET TO FALSE, IF SO, I WON'T CONTINUE WITH THIS PROCEDURE...") ("")
 if(draw-plots?)[
   output-debug-message (word "The name of the plot to update is: '" name-of-plot "'.") (who)
   set-current-plot name-of-plot
   set-current-plot-pen (word "Turtle " who)
   
   ifelse(is-number? value)[
     plot value
   ]
   [
     error (word "To plot, the value passed must be a number and the value passed for the '" name-of-plot "' plot is not.  Please rectify.")
   ]
 ]
 
 set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "UPDATE-PLOT-WITH-X-AXIS-VALUE" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Plots the value specified by the first parameter passed to this function on
;the x-axis value specified by the second parameter passed to this function 
;and the y-axis value specified by the third parameter passed to this function.
;
;         Name              Data Type     Description
;         ----              ---------     -----------                                          
;@param   name-of-plot      String        The name of the plot to be updated.
;@param   x-value           Double        The x-axis value where the plot should 
;                                         be made.
;@param   y-value           Double        The y-axis value where the plot should 
;                                         be made.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to update-plot-with-x-axis-value [name-of-plot x-value y-value]
 set debug-indent-level (debug-indent-level + 1)
 output-debug-message ("EXECUTING THE 'update-plot' PROCEDURE...") ("")
 set debug-indent-level (debug-indent-level + 1)
 
 output-debug-message ("CHECKING TO SEE IF THE 'draw-plots?' VARIABLE IS SET TO FALSE, IF SO, I WON'T CONTINUE WITH THIS PROCEDURE...") ("")
 if(draw-plots?)[
   output-debug-message (word "The name of the plot to update is: '" name-of-plot "'.") (who)
   set-current-plot name-of-plot
   set-current-plot-pen (word "Turtle " who)
   
   ifelse(is-number? x-value and is-number? y-value)[
     plotxy (x-value) (y-value)
   ]
   [
     error (word "To plot, the value passed must be a number and the value passed for the '" name-of-plot "' plot is not.  Please rectify.")
   ]
 ]
 
 set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "UPDATE-TIME" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Determines whether the game is being played in a training or non-training
;context and updates the time by 1.
; 
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to update-time
 set debug-indent-level (debug-indent-level + 1)
 output-debug-message ("EXECUTING 'update-environment' PROCEDURE...") ("")
 set debug-indent-level (debug-indent-level + 1)
 output-debug-message(word "CHECKING TO SEE IF GAME IS BEING PLAYED IN TRAINING CONTEXT I.E IS THE GLOBAL 'training?' VARIABLE (" training? ") SET TO TRUE?") ("")
 
 ifelse(training?)[
   output-debug-message (word "GAME IS BEING PLAYED IN TRAINING CONTEXT.  INCREMENTING GLOBAL 'current-training-time' VARIABLE (" current-training-time ") BY 1...") ("")
   set current-training-time ( precision (current-training-time + 1) (1) )
   output-debug-message (word "GLOBAL 'current-training-time' VARIABLE NOW SET TO: " current-training-time ".") ("")
 ]
 [
   output-debug-message (word "GAME IS BEING PLAYED IN NON-TRAINING CONTEXT.  INCREMENTING GLOBAL 'current-game-time' VARIABLE (" current-game-time ") BY 1...") ("")
   set current-game-time ( precision (current-game-time + 1) (1) )
   output-debug-message (word "GLOBAL 'current-game-time' VARIABLE NOW SET TO: " current-game-time ".") ("")
 ]
 set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;
;;; "TEST" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

;Runs a series of tests to validate correct operation of model procedures.
;This procedure relies on a particular file structure: the directory in 
;which this model is located should contain a directory called 
;"tests".  Inside this directory should be directories indicating
;particular test-suites, for organisational purposes its recommended to
;name these directories after the procedures being tested.  These 
;directories are also called "test-suites", if you add a new test-suite 
;directory then ensure that the directory's name is an element of the
;"test-suites" variable local to this procedure.
;
;Within the test suite directory should be one or more test files whose
;names should be integers from 1 to n.  If there is a break in the file
;name sequence i.e. 1, 2, 4 or a duplicate file name i.e. 1, 1, 2 then
;this procedure will skip over test numbers after the break in the
;sequence.  These test files should be plain text i.e. have a .txt 
;extension.
;
;For each test file, this procedure will setup the model according to 
;details in the test file, run the test outlined in the test file and 
;tear down the model.  Model setup is achieved by including content in
;the test file that is compatible with the "setup" procedure in this
;model.
;
;To specify Netlogo code to be run for the actual test, enclose the
;relevant code in your test file  with <test> and </test> tags.  If you
;wish to demo test code before including it in the test file, ensure 
;that the body of the procedure below is commented out.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to test
  ifelse( user-yes-or-no? ("Would you like to run a specific test?  If not, all tests in the 'tests' model directory will be run.") )[
    let test-file (user-file)
    let test-type-name-and-number ( substring (test-file) ( (position ("tests") (test-file)) ) ( (position (".txt") (test-file)) ) )
    let test-type-name-and-number-info ( string:rex-split (test-type-name-and-number) (pathdir:get-separator) )
    set test-info ( list 
      ( item (1) (test-type-name-and-number-info) ) 
      ( item (2) (test-type-name-and-number-info) ) 
    )
    run-test (test-file)
  ]
  [
    set directory-separator pathdir:get-separator
    
    let test-names (pathdir:list (word pathdir:get-current (directory-separator) "tests" ))
    foreach(test-names)[
      
      let test-number (1) 
      let test-file (word "tests" (directory-separator) (?) (directory-separator) test-number ".txt")
      
      while[file-exists? test-file][
        set test-info (list (?) (test-number))
        run-test (test-file)
        set test-number (test-number + 1)
        set test-file (word "tests" (directory-separator) (?) (directory-separator) test-number ".txt")
      ]
    ]
  ]
  
  reset (false)
  user-message "Tests completed with no errors."
end

to run-test [file]
  output-print word "RUNNING TEST: " test-info
  setup (true)
  
  file-open file
  
  let file-line ""
  let read-in-test-code false
  let test-code ""
  
  while[not file-at-end?][
    set file-line file-read-line
    
    ;If the contents of 'file-line' start with a </test> closing
    ;tag, set the 'read-in-test-code' value to 'false' since
    ;this </test> tag indicates the end of test code. 
    if( (string:rex-match ("^.*<\\/test>\\s*$") (file-line)) )[
      set read-in-test-code false
    ]
      
    ;If a <test> tag has been encountered and the line does not 
    ;start with a semi-colon (indicating Netlogo comment), add 
    ;the line to the local 'test-code' variable.
    if( 
      read-in-test-code and 
      not (string:rex-match ("^\\s*;.*") (file-line)) 
    )[
      set test-code ( word test-code (file-line) )
    ]
  
    ;If the contents of 'file-line' start with a <test> opening
    ;tag, set the 'read-in-test-code' value to 'true' since
    ;this <test> tag indicates the start of test code. 
    if( string:rex-match ("^\\s*<test>.*") (file-line) )[
      set read-in-test-code true
    ]
    
  ]
  
  ;Remove any unneccessary white space so the test code is quicker to run.
  set test-code ( string:rex-replace-all ("\\s{2,}") (test-code) (" ") )
  
  if(empty? test-code)[
    file-close
    error (word "No test code specified in file: '" file "'.")
  ]
  
  file-close
  print-and-run task (test-code)
  
  reset (true)
  output-print word "COMPLETED TEST: " test-info
  output-print ""
end

to check-test-output [result expected test-description]
  
  if(not is-list? result)[
    set result ( list result )
  ]
  
  if(not is-list? expected)[
    set expected ( list expected )
  ]
  
  foreach(result)[
    if(not member? ? expected )[
      print (testing-debug-messages)
      error (word "Result returned (" ? ") is not an expected value (" expected ") for test number " (item (1) (test-info)) " of '" (item (0) (test-info)) "' test (" test-description ").  Check command center in interface tab for detailed debug info.")
    ]
  ]
end

to check-equal [result expected test-description]
  if(result != expected)[
    print (testing-debug-messages)
    error (word "Result returned (" result ") is not equal to what is expected (" expected ") for test number " (item (1) (test-info)) " of '" (item (0) (test-info)) "' test (" test-description ").  Check command center in interface tab for detailed debug info.")
  ]
end

to check-greater-than-or-equal-to [result expected test-description]
  if(not (result >= expected) )[
    print (testing-debug-messages)
    error (word "Result returned (" result ") is not greater than or equal to what is expected (" expected ") for test number " (item (1) (test-info)) " of '" (item (0) (test-info)) "' test (" test-description ").  Check command center in interface tab for detailed debug info.")
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
280
10
710
461
17
17
12.0
1
10
1
1
1
0
1
1
1
-17
17
-17
17
0
0
1
ticks
30.0

PLOT
711
10
957
189
Scores
Time
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

BUTTON
7
246
80
279
Play
play
NIL
1
T
OBSERVER
NIL
P
NIL
NIL
1

PLOT
1203
189
1449
368
Visual LTM Size
Time
# Nodes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

PLOT
1203
368
1449
547
Visual LTM Avg. Depth
Time
NIL
0.0
10.0
0.0
5.0
true
false
"" ""
PENS

MONITOR
153
100
280
145
Training Time (ms)
current-training-time
1
1
11

PLOT
1449
189
1695
368
Action LTM Size
Time
#Nodes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

PLOT
1449
368
1695
547
Action LTM Avg. Depth
Time
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

MONITOR
153
145
280
190
Game Time (ms)
current-game-time
1
1
11

MONITOR
153
280
280
325
Tile Birth Prob.
tile-birth-prob
1
1
11

MONITOR
153
325
280
370
Hole Birth Prob
hole-birth-prob
17
1
11

MONITOR
153
370
280
415
Tile Lifespan (ms)
tile-lifespan
1
1
11

MONITOR
153
415
280
460
Hole Lifespan (ms)
hole-lifespan
1
1
11

PLOT
711
368
957
547
Num Visual-Action Links
Time
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

MONITOR
153
190
280
235
Tile Born Every (ms)
tile-born-every
1
1
11

MONITOR
153
235
280
280
Hole Born Every (ms)
hole-born-every
1
1
11

SWITCH
7
135
126
168
debug?
debug?
1
1
-1000

PLOT
1203
10
1449
189
Visual STM Size
Time
# Nodes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

PLOT
1449
10
1695
189
Action STM Size
Time
# Nodes
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

MONITOR
153
10
280
55
Scenario Number
current-scenario-number
17
1
11

MONITOR
153
55
280
100
Repeat Number
current-repeat-number
17
1
11

INPUTBOX
7
10
147
70
total-number-of-scenarios
54
1
0
Number

INPUTBOX
7
70
147
130
total-number-of-repeats
10
1
0
Number

BUTTON
7
210
80
243
Reset
reset(false)
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
5
463
710
676
12

PLOT
711
189
957
368
Total Deliberation Time
Time
Seconds
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

PLOT
957
10
1203
189
Random Behaviour Frequency
Turtle ID
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

PLOT
957
189
1203
368
Problem-Solving Frequency
Turtle ID
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

PLOT
957
368
1203
547
Pattern-Recognition Frequency
Turtle ID
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

SWITCH
7
168
126
201
draw-plots?
draw-plots?
1
1
-1000

BUTTON
7
303
106
336
Run Unit Tests
test
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
# CHREST Tileworld  
## CREDITS

**Chief Architect:** Martyn Lloyd-Kelly  <martynlloydkelly@gmail.com>

## MODEL DESCRIPTION

The "Tileworld" testbed was first formally described in:

Martha Pollack and Marc Ringuette. _"Introducing the Tileworld: experimentally evaluating agent architectures."_  Thomas Dietterich and William Swartout ed. In Proceedings of the Eighth National Conference on Artificial Intelligence,  p. 183--189, AAAI Press. 1990.

This Netlogo model is based upon Jose M. Vidal's "Tileworld" Netlogo model.  Vidal's model and details thereof can be found at the following website:
http://jmvidal.cse.sc.edu/netlogomas/tileworld/index.html

In this model, some turtles are endowed with instances of the Java implementation of the CHREST architecture developed principally by Prof. Fernand Gobet and Dr. Peter Lane. See the following website for more details regarding the CHREST architecture: 
http://www.chrest.info/

Players score points by pushing tiles into holes; these artefacts are transient and appear at random.  The probability of new tiles/holes being created, how often they may be created and how long they exist for can be altered by the user to increase/decrease intrinsic environment dynamism.

Players are not capable of pushing more than one tile at a time, if a tile is blocked then the player must reposition themselves and push the tile from a different direction.  Each patch may only hold one player, tile or hole.  Players are not able to push other players or holes.

Tileworld games are composed of two stages: training and non-training.  The length of time that players spend in each stage is defined by the user.  These stages are of particular interest to CHREST turtles who can learn production rules as they interact with the environment.  For more details of such behaviour, see the "CHREST TURTLE BEHAVIOUR" section below.

## AIM OF THE MODEL

The aim of this model is to investigate the interplay between _talent_ and _practice_ using the CHREST architecture as a theory of cognition in an environment whose dynanism is not just a result of the actions of players.

"Talent" is embodied by the following parameters that can be set for players:

  * The size of a turtle's the sight-radius: larger sight-radii equates to greater talent since increasing the amount of the Tileworld that can be seen equates to greater complexity and more opportunities to score (more tiles and holes can be seen in one percept).  See: Gerardo I. Simari and Simon Parsons. _"On Approximating the Best Decision for an Autonomous Agent"_ Sixth Workshop on Game Theoretic and Decision Theoretic Agents (GTDT 2004) at the Third Conference on Autonomous Agents and Multi-agent Systems (AAMAS 2004), pp. 91-100.

"Expertise" is embodied by the size and quality of a CHREST turtle's LTM.  The size of this should increase if CHREST turtles are presented with new information more frequently and are allowed to learn for longer periods of time.

## MODEL SET-UP
The model runs a user-specified number of scenarios for a user-specified number of repeats: the number of scenarios and repeats can be set in the relevant boxes in the model's interface tab.  The values in these boxes must be reflected by a directory structure created somewhere on your system.  The topology and nomenclature of directories and files within this directory structure is vital to ensure correct operation of the model since these directories and the files they contain will be used to set-up the simulations and record results from them. 

Scenarios are intended to represent different configurations of initial values for the simulation's independent variables (a complete list of independent variables can be found in section "INDEPENDENT VARIABLES" below).  These initial values are user-specified and should be placed in a plain text file with the name "ScenarioXSettings.txt" within each top-level scenario folder within the directory structure mentioned above.

The basic topology and nomenclature of the directory structure referred to in the previous paragraphs is illustrated below for clarification:

Containing directory
|
|____Scenario1
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____Scenario1Settings.txt
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____Repeat1
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____Repeat2
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____Repeat_n_
|
|____Scenario2
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____Scenario2Settings.txt
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____Repeat1
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____Repeat2
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:
|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____Repeat_n_
|
|____:
|
|____Scenario_n_
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____ScenarioNSettings.txt
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____Repeat1
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____Repeat2
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;:
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|____Repeat_n_

  * Scenario numbering must run from 1 to _n_ where _n_ is equal to the number specified in the "total-number-of-scenarios" box in the model's interface tab.
  * Repeat numbering must run from 1 to _n_ where _n_ is equal to the number specified in the "total-number-of-repeats" box in the model's interface tab.
  * The number of repeats is equal for all scenarios so every "Scenario" directory must contain the same number of "Repeat" directories (from 1 to _n_).
  * Filenames are case and space sensitive

When you first press the "Play" button on the model's interface tab, a number of dialog options will appear asking you if you wish to record various pieces of information.  You will also be asked to specify where the "Containing directory" in the directory structure illustration above.

## SETTINGS FILE

When creating a scenario settings file, a particular syntax should be used:
  
  * To specify a Netlogo command that should be interpreted as-is: enclose the command in <run></run> tags.  For example, the following line in a settings file would tell the model to create 4 turtles of breed "chrest-turtles":

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<run>create chrest-turtles 4</run>

  * To specify a global variable value: give the name of the global variable on one line and the value it should be set to on the next line.  **Do not enclose with <run></run> tags.**  For example, the following line in a settings file would tell the model to set the value for the "hole-birth-probability" global variable to 0.1:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;hole-birth-probability
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0.1

  * To specify a turtle variable value for a single turtle: give the name of the turtle variable on one line and on the next line specify the turtle ID followed by a colon followed by the value that this turtle should have for the variable in question.  **Do not enclose with double quotes.**  For example, the following line in a settings file would tell the model to set the value for the "sight-radius" turtle variable to 2 for the turtle whose "who" variable is equal to 0:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sight-radius
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;0:2

  * To specify a turtle variable value for a number of turtles: give the name of the turtle variable on one line and on the next line specify the turtle IDs that are to have this variable set to the value specified by giving the first turtle ID of the range followed by a hyphen and the last turtle ID of the range.  This range specification should then be enclosed with standard parenthesis and followed by a colon followed by the value that this turtle should have for the variable in question.  **Do not enclose with <run></run> tags.**  For example, the following line in a settings file would tell the model to set the value for the "sight-radius" turtle variable to 2 for turtles whose "who" variables are equal to 0, 1, 2 and 3:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;sight-radius
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(0-3):2


### INDEPENDENT VARIABLES

Only the following variables should be modified using the scenario settings file, modifying other variables may cause erroneous model operation.  Note: any text in bold are variables or primitives that can be used, any text in italics represents a value that can be substituted for a value of your choice.

#### GLOBAL VARIABLES

  * **hole-birth-prob:** determines how likely it is that a hole will be born/created in the model environment when the length of time stipulated by the **hole-born-every** variable has passed.

  * **hole-born-every:** determines how often a hole will have a chance of being born.

  * **hole-lifespan:** determines how long holes are present in the model environment before they are removed.

  * **tile-birth-prob:** determines how likely it is that a tile will be born/created in the model environment when the length of time stipulated by the **tile-born-every** variable has passed.

  * **tile-born-every:** determines how often a tile will have a chance of being born.

  * **tile-lifespan:** determines how long tiles are present in the model environment before they are removed.

  * **time-increment:** determines the value that training or play time is incremented by after every iteration of the "play" procedure.

#### CHREST TURTLE BREED VARIABLES

  * **action-performance-time:** determines how long it takes for a player turtle to perform an action once one has been decided upon and loaded for execution.

  * **action-selection-heuristic-time:** determines the base unit of time taken for a player turtle to deliberate about what action to perform next rather than using pattern-recognition to achieve the same goal.  This is used as the base unit in 

  * **action-selection-pattern-recognition-time:** determines how long it takes for a CHREST turtle to select an action to perform based upon pattern recognition rather than deliberation.

  * **add-link-time:** determines how long it takes for a CHREST turtle to add a link between two chunks in long-term memory.

  * **discrimination-time:** determines how long it takes for a CHREST turtle to discriminate a chunk in long-term memory.

  * **familiarisation-time:** determines how long it takes for a CHREST turtle to familiarise a chunk in long-term memory.

  * **max-length-of-visual-action-pairs-list:** determines the maximum length of a CHREST
turtle's "visual-action-pairs" list.

  * **play-time:** determines how long a player turtle can play a non-training game for.

  * **probability-of-deliberation:** determines the probability that a CHREST turtle will resort to heuristic deliberation to decide upon what action to perform given a particular visual pattern, _vp_, rather than selecting an action associated with _vp_.  Ensures that CHREST turtle behaviour does not become rigid.

  * **sight-radius:** determines how many patches to the north, east, south and west a player turtle can see. 

  * **training-time:** determines how long a player turtle can train for.
 
## CHREST TURTLE BEHAVIOUR

The behaviour of CHREST turtles in the model is driven by the generation and recognition of _visual_ and _action_ patterns; symbolic representations of the current environment and the actions performed within it.  Visual patterns are used to enable _planning_ where the mind's eye of a CHREST turtle is used to plan its next moves i.e. the action patterns to perform.  When the plan generation cycle ends, the CHREST turtle performs the actions in its plan until either: 
  
  * An action pattern fails to be applied because there is an incongruence between the action to perform and the current environment state (CHREST turtle should push a tile to the north but the tile has disappeared, for example).

  * The plan is empty.

CHREST turtles generate visual patterns that symbolically represent what objects it can see and where these objects are located relative to the CHREST turtle's current location.  For example, the visual pattern: [T, 3, 1] indicates that the CHREST turtle can see a tile, _T_, 3 patches to its east and 1 patch north of itself.  

Action patterns are generated using the current visual pattern.  Action patterns look similiar to visual patterns but they instead describe what action should be performed.  For example, the action pattern: [PT, 0, 1] indicates that the CHREST turtle should push a tile, _PT_, 1 patch (1) along heading 0 (north).

Since these patterns can be stored in a CHREST turtle's LTM, visual and action patterns can be associated except when the turtle can not see a tile or hole and decides to move randomly.  This is because the environment is dynamic i.e. tiles and holes appear at random and therefore, favouring one random heading over another does not impart any benefit upon the potential score of a player.  After a CHREST turtle attempts to associate a visual pattern with an action pattern, the visual and action pattern in question are added to the CHREST turtle's "episodic-memory" list.  This list enables the CHREST turtle to reinforce a link between a particular visual pattern and action pattern since there is no way to indicate precisely what action pattern in action STM is linked to what visual pattern in visual STM.  The "episodic-memory" list has a maximum capacity that is set by the user in the settings file for a scenario.

### DUAL-PROCESS THEORY OF BEHAVIOUR

The CHREST turtle's deliberation process for what action should be performed in a particular situation, can either be driven by a problem-solving or pattern-recognition process.  This produces a dual-process theory of behaviour for turtles endowed with CHREST architectures.

Note that CHREST turtles embody different forms of this system.  It is possible to have pure problem-solving turtles, pure pattern-recognition turtles, hybrid problem-solvers and pattern-recognisers or blind problem-solvers.  Such turtles can be created by manipulating the "pattern-recognition?", "problem-solving?" and "visually-informed-problem-solving?" CHREST turtle variables in the following way:

  1. Pure problem-solvers:
  2. Pure pattern-recognisers:
  3. Blind problem-solvers

 and as input to its long-term memory discrimination net.  Action patterns are generated by deliberating about the current visual scene and are associated with visual patterns if they are performed successfully.  T  

When plan generation occurs, a CHREST turtle uses the visual pattern created as input to its LTM to try and recognise this visual pattern i.e. see if it already exists in LTM.  If it does, the CHREST turtle will then check to see if it has an action patterns associated with this visual pattern in its LTM.  If it does then two situations may be true:

  1. **The visual pattern is not associated with any visual patterns.**  In this case, the turtle selects an action to perform using its heuristic deliberation process:
    1. If the turtle can see one or more tiles and holes, it will attempt to push the tile closest to the hole that is closest to the turtle into this hole.
    2. If the turtle can see one or more tiles but no holes, it will attempt to push the tile closest to it along the heading it approaches it at.
    3. If the CHREST turtle can see no tiles or holes, it will select a heading at random to move in. 

  2. **The visual pattern is associated with one or more action patterns.** In this case, the turtle has an _x_ in _n_ chance of performing an action pattern associated with the current visual pattern and a _v_ in _n_ chance of using heuristic deliberation to produce an action pattern.
    * _x_ is equal to the weight of the link between the current visual and action pattern.
    * _n_ is equal to the cumulative weight of all links that this visual pattern has to action patterns plus _v_.
    * _v_ is equal to the value of the **probability-of-deliberation** variable for the turtle in question.  This ensures that the CHREST turtle will always have a chance of performing a previously unperformed action given a particular visual pattern preventing its behaviour from becoming rigid. 
@#$#@#$#@
default
false
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

ant
true
0
Polygon -7500403 true true 136 61 129 46 144 30 119 45 124 60 114 82 97 37 132 10 93 36 111 84 127 105 172 105 189 84 208 35 171 11 202 35 204 37 186 82 177 60 180 44 159 32 170 44 165 60
Polygon -7500403 true true 150 95 135 103 139 117 125 149 137 180 135 196 150 204 166 195 161 180 174 150 158 116 164 102
Polygon -7500403 true true 149 186 128 197 114 232 134 270 149 282 166 270 185 232 171 195 149 186
Polygon -7500403 true true 225 66 230 107 159 122 161 127 234 111 236 106
Polygon -7500403 true true 78 58 99 116 139 123 137 128 95 119
Polygon -7500403 true true 48 103 90 147 129 147 130 151 86 151
Polygon -7500403 true true 65 224 92 171 134 160 135 164 95 175
Polygon -7500403 true true 235 222 210 170 163 162 161 166 208 174
Polygon -7500403 true true 249 107 211 147 168 147 168 150 213 150

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bee
true
0
Polygon -1184463 true false 151 152 137 77 105 67 89 67 66 74 48 85 36 100 24 116 14 134 0 151 15 167 22 182 40 206 58 220 82 226 105 226 134 222
Polygon -16777216 true false 151 150 149 128 149 114 155 98 178 80 197 80 217 81 233 95 242 117 246 141 247 151 245 177 234 195 218 207 206 211 184 211 161 204 151 189 148 171
Polygon -7500403 true true 246 151 241 119 240 96 250 81 261 78 275 87 282 103 277 115 287 121 299 150 286 180 277 189 283 197 281 210 270 222 256 222 243 212 242 192
Polygon -16777216 true false 115 70 129 74 128 223 114 224
Polygon -16777216 true false 89 67 74 71 74 224 89 225 89 67
Polygon -16777216 true false 43 91 31 106 31 195 45 211
Line -1 false 200 144 213 70
Line -1 false 213 70 213 45
Line -1 false 214 45 203 26
Line -1 false 204 26 185 22
Line -1 false 185 22 170 25
Line -1 false 169 26 159 37
Line -1 false 159 37 156 55
Line -1 false 157 55 199 143
Line -1 false 200 141 162 227
Line -1 false 162 227 163 241
Line -1 false 163 241 171 249
Line -1 false 171 249 190 254
Line -1 false 192 253 203 248
Line -1 false 205 249 218 235
Line -1 false 218 235 200 144

bird1
false
0
Polygon -7500403 true true 2 6 2 39 270 298 297 298 299 271 187 160 279 75 276 22 100 67 31 0

bird2
false
0
Polygon -7500403 true true 2 4 33 4 298 270 298 298 272 298 155 184 117 289 61 295 61 105 0 43

boat1
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

boat2
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 157 54 175 79 174 96 185 102 178 112 194 124 196 131 190 139 192 146 211 151 216 154 157 154
Polygon -7500403 true true 150 74 146 91 139 99 143 114 141 123 137 126 131 129 132 139 142 136 126 142 119 147 148 147

boat3
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 37 172 45 188 59 202 79 217 109 220 130 218 147 204 156 158 156 161 142 170 123 170 102 169 88 165 62
Polygon -7500403 true true 149 66 142 78 139 96 141 111 146 139 148 147 110 147 113 131 118 106 126 71

box
true
0
Polygon -7500403 true true 45 255 255 255 255 45 45 45

butterfly1
true
0
Polygon -16777216 true false 151 76 138 91 138 284 150 296 162 286 162 91
Polygon -7500403 true true 164 106 184 79 205 61 236 48 259 53 279 86 287 119 289 158 278 177 256 182 164 181
Polygon -7500403 true true 136 110 119 82 110 71 85 61 59 48 36 56 17 88 6 115 2 147 15 178 134 178
Polygon -7500403 true true 46 181 28 227 50 255 77 273 112 283 135 274 135 180
Polygon -7500403 true true 165 185 254 184 272 224 255 251 236 267 191 283 164 276
Line -7500403 true 167 47 159 82
Line -7500403 true 136 47 145 81
Circle -7500403 true true 165 45 8
Circle -7500403 true true 134 45 6
Circle -7500403 true true 133 44 7
Circle -7500403 true true 133 43 8

circle
false
0
Circle -7500403 true true 35 35 230

person
false
0
Circle -7500403 true true 155 20 63
Rectangle -7500403 true true 158 79 217 164
Polygon -7500403 true true 158 81 110 129 131 143 158 109 165 110
Polygon -7500403 true true 216 83 267 123 248 143 215 107
Polygon -7500403 true true 167 163 145 234 183 234 183 163
Polygon -7500403 true true 195 163 195 233 227 233 206 159

spacecraft
true
0
Polygon -7500403 true true 150 0 180 135 255 255 225 240 150 180 75 240 45 255 120 135

thin-arrow
true
0
Polygon -7500403 true true 150 0 0 150 120 150 120 293 180 293 180 150 300 150

truck-down
false
0
Polygon -7500403 true true 225 30 225 270 120 270 105 210 60 180 45 30 105 60 105 30
Polygon -8630108 true false 195 75 195 120 240 120 240 75
Polygon -8630108 true false 195 225 195 180 240 180 240 225

truck-left
false
0
Polygon -7500403 true true 120 135 225 135 225 210 75 210 75 165 105 165
Polygon -8630108 true false 90 210 105 225 120 210
Polygon -8630108 true false 180 210 195 225 210 210

truck-right
false
0
Polygon -7500403 true true 180 135 75 135 75 210 225 210 225 165 195 165
Polygon -8630108 true false 210 210 195 225 180 210
Polygon -8630108 true false 120 210 105 225 90 210

turtle
true
0
Polygon -7500403 true true 138 75 162 75 165 105 225 105 225 142 195 135 195 187 225 195 225 225 195 217 195 202 105 202 105 217 75 225 75 195 105 187 105 135 75 142 75 105 135 105

wolf-left
false
3
Polygon -6459832 true true 117 97 91 74 66 74 60 85 36 85 38 92 44 97 62 97 81 117 84 134 92 147 109 152 136 144 174 144 174 103 143 103 134 97
Polygon -6459832 true true 87 80 79 55 76 79
Polygon -6459832 true true 81 75 70 58 73 82
Polygon -6459832 true true 99 131 76 152 76 163 96 182 104 182 109 173 102 167 99 173 87 159 104 140
Polygon -6459832 true true 107 138 107 186 98 190 99 196 112 196 115 190
Polygon -6459832 true true 116 140 114 189 105 137
Rectangle -6459832 true true 109 150 114 192
Rectangle -6459832 true true 111 143 116 191
Polygon -6459832 true true 168 106 184 98 205 98 218 115 218 137 186 164 196 176 195 194 178 195 178 183 188 183 169 164 173 144
Polygon -6459832 true true 207 140 200 163 206 175 207 192 193 189 192 177 198 176 185 150
Polygon -6459832 true true 214 134 203 168 192 148
Polygon -6459832 true true 204 151 203 176 193 148
Polygon -6459832 true true 207 103 221 98 236 101 243 115 243 128 256 142 239 143 233 133 225 115 214 114

wolf-right
false
3
Polygon -6459832 true true 170 127 200 93 231 93 237 103 262 103 261 113 253 119 231 119 215 143 213 160 208 173 189 187 169 190 154 190 126 180 106 171 72 171 73 126 122 126 144 123 159 123
Polygon -6459832 true true 201 99 214 69 215 99
Polygon -6459832 true true 207 98 223 71 220 101
Polygon -6459832 true true 184 172 189 234 203 238 203 246 187 247 180 239 171 180
Polygon -6459832 true true 197 174 204 220 218 224 219 234 201 232 195 225 179 179
Polygon -6459832 true true 78 167 95 187 95 208 79 220 92 234 98 235 100 249 81 246 76 241 61 212 65 195 52 170 45 150 44 128 55 121 69 121 81 135
Polygon -6459832 true true 48 143 58 141
Polygon -6459832 true true 46 136 68 137
Polygon -6459832 true true 45 129 35 142 37 159 53 192 47 210 62 238 80 237
Line -16777216 false 74 237 59 213
Line -16777216 false 59 213 59 212
Line -16777216 false 58 211 67 192
Polygon -6459832 true true 38 138 66 149
Polygon -6459832 true true 46 128 33 120 21 118 11 123 3 138 5 160 13 178 9 192 0 199 20 196 25 179 24 161 25 148 45 140
Polygon -6459832 true true 67 122 96 126 63 144

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
