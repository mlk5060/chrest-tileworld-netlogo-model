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
  deliberation-finished-time                            ;Stores the time (in milliseconds) that the CHREST turtle will finish deliberation on the current plan. Controls plan execution for planning agents and action execution for non-planning agents.
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
  next-action-to-perform                                ;Stores a list and is only used for non-planning CHREST turtles: 
                                                        ; - First element contains the action-pattern that the turtle is to perform
                                                        ; - Second element contains whether the action-pattern was generated using pattern-recognition.
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
      ( list ("can-plan?") )
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
     ifelse(can-plan?)[
       output-debug-message (word "Checking to see if my 'generate-plan?' turtle variable is set to true, if so, I should plan if not, I should execute the next action in my plan...") (who)
       ifelse(generate-plan?)[
         output-debug-message (word "My 'generate-plan?' turtle variable is set to 'true' so I should plan...") (who)
         generate-plan
       ]
       [
         output-debug-message (word "My 'generate-plan?' turtle variable is set to 'false' so I should execute the next action in my 'plan' turtle variable...") (who)
         chrest:learn-scene (chrest:Scene.new (get-observable-environment) ("")) (number-fixations) (report-current-time) 
         execute-next-planned-action
       ]
     ]
     ;=========================;
     ;== TURTLE CAN NOT PLAN ==;
     ;=========================;
     [
       chrest:learn-scene (chrest:Scene.new (get-observable-environment) ("")) (number-fixations) (report-current-time)
       
       ifelse(deliberation-finished-time = -1)[
         let action-deliberationTime-patternRecUsed (deliberate (get-observable-environment))
         set next-action-to-perform (list (item (0) (action-deliberationTime-patternRecUsed)) (item (2) (action-deliberationTime-patternRecUsed)))
         set deliberation-finished-time (item (1) (action-deliberationTime-patternRecUsed))
       ]
       [
         if(report-current-time >= deliberation-finished-time)[
           set deliberation-finished-time (-1)
           
           ;=========================================;
           ;== PREPARE ACTION FOR "perform-action" ==;
           ;=========================================;
           
           let action-to-perform (item (0) (next-action-to-perform))
           
           ;=========================================;
           ;== PREPARE VISION FOR "perform-action" ==;
           ;=========================================;
           
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
           
           let result-of-performing-action (perform-action (list (action-to-perform) (item (1) (next-action-to-perform))) (observable-environment))
           let action-performed-successfully (false)
           
           if (
             ;An empty list is reported by 'perform-action' if the action is scheduled for performance but hasn't been performed yet.
             (is-list? result-of-performing-action and not empty? result-of-performing-action) or
             (not is-list? result-of-performing-action)
           )[
        
             output-debug-message ( word "Checking to see if the local 'result-of-performing-action' variable is a list.  If this is the case then the action was performed and the action must have been a 'push-tile' action so the first element of the list will be whether the action was performed successfully whilst the second element will indicate whether or not a hole was filled..." ) (who)
             ifelse( is-list? (result-of-performing-action))[
          
               output-debug-message ( word "The local 'result-of-performing-action' variable is a list so I'll set the first element of this list to the local 'action-performed-successfully' variable..." ) (who)
               set action-performed-successfully ( item (0) (result-of-performing-action) )
             ]
             [
               output-debug-message ( word "The local 'result-of-performing-action' variable is not a list so I'll set the local 'action-performed-successfully' variable to its value..." ) (who)
               set action-performed-successfully (result-of-performing-action)
             ]
        
             ;=========================================;
             ;== CHECK SUCCESS OF ACTION PERFORMANCE ==;
             ;=========================================;
        
             output-debug-message ( word "Checking the value of the local 'action-performed-successfully' variable (" action-performed-successfully ")..." ) (who)
             ifelse( action-performed-successfully )[
          
               output-debug-message ( word "Checking to see if the local 'result-of-performing-action' variable is a list.  If it is then the action performed must have been a 'push-tile' action so the first element of the list will be whether the action was performed successfully whilst the second element will indicate whether or not a hole was filled...") (who)
               if( is-list? (result-of-performing-action) ) [
            
                 output-debug-message ( word "The local 'result-of-performing-action' variable is a list so I'll check the value of its second element (" item (1) (result-of-performing-action) ").  If this is 'true' I'll increment my score and reinforce the episodes in my 'episodic-memory'..." ) (who)
                 if( item (1) (result-of-performing-action) )[
              
                   output-debug-message ( word "The second element of the local 'result-of-performing-action' variable is 'true' so I'll reinforce all episodes in my 'episodic-memory'..." ) (who)
                   reinforce-productions
                   set episodic-memory ([])
                 ]
               ]
             ]
             [
               output-debug-message ( word "The action was not performed successfully..." ) (who)
               set episodic-memory ([])
             ]
           ]
         ]
       ]
       
     ]
     
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
    output-debug-message (word "Scene to scan: " chrest:Scene.get-as-netlogo-list (chrest-scene)) (who)

    ;=========================;
    ;== PATTERN-RECOGNITION ==;
    ;=========================;

    output-debug-message (word "If 'scene' isn't empty and I can use pattern-recognition (" pattern-recognition? "), I'll use pattern-recognition to select an action to perform...") (who)
    if( pattern-recognition? and (not empty? scene) )[
      
      output-debug-message (word "My 'pattern-recognition?' variable is set to 'true' and 'scene' isn't empty so I'll get any productions for visual chunks I recognise in the scene, along with their optimality ratings...") (who)
      let productions-for-recognised-visual-chunks-in-scene []
      
      output-debug-message (word "My visual STM will be cleared before the scene is scanned so that any visual chunks recognised definitely originate from the scene passed.") (who)
      let recognised-scene (chrest:scan-scene(chrest-scene) (number-fixations) (true) (report-current-time) (false))
      output-debug-message (word "Setting the local 'scanned-scene-during-pattern-recognition' variable to true.") (who)
      set scanned-scene-during-pattern-recognition (true)
      
      let visual-stm (chrest:get-stm-contents-by-modality ("visual"))
      output-debug-message (word "I've recognised the following visual chunks by scanning the scene: " (map ([ chrest:ListPattern.get-as-string (chrest:Node.get-image (?)) ]) (visual-stm))) (who)

      foreach(visual-stm)[
        let visual-chunk ( chrest:Node.get-image (?) )
        
        output-debug-message (word "Getting any productions associated with the recognised visual chunk: " ( chrest:ListPattern.get-as-string (visual-chunk) ) "..." ) (who)
        let productions (chrest:get-productions (visual-chunk) (report-current-time))
        output-debug-message (word "Productions found: " map ([ ( list (chrest:ListPattern.get-as-string (chrest:Node.get-image (item (0) (?)))) (item (1) (?)) ) ]) (productions) ".") (who)
        
        ;===============================================================================================================;
        ;== CONVERT EACH PRODUCTION'S ACTION LIST-PATTERN INTO A FORM SUITABLE FOR USE BY ACTION-SELECTION PROCEDURES ==;
        ;===============================================================================================================;
        
        output-debug-message ("Converting each action in the productions found from a jchrest.lib.ListPattern to a Netlogo list containing 3 elements: the action token, the heading to adopt when performing the action and the patches to shift when performing the action") (who)
        foreach(productions)[ 
          let action-in-production (item (0) (?))
          set action-in-production (chrest:ListPattern.get-as-netlogo-list (chrest:Node.get-image (action-in-production)))
          set action-in-production (item (0) (action-in-production)) ; There will only ever be one ItemSquarePattern in the ListPattern.
          set action-in-production (list
            (chrest:ItemSquarePattern.get-item (action-in-production))
            (chrest:ItemSquarePattern.get-column (action-in-production))
            (chrest:ItemSquarePattern.get-row (action-in-production))
          )
          
          set productions-for-recognised-visual-chunks-in-scene (lput 
            (list
              (action-in-production)
              (item (1) (?))
            )
            (productions-for-recognised-visual-chunks-in-scene)
          )
        ]
      ]
      
      ;=========================;
      ;== SELECT A PRODUCTION ==;
      ;=========================;
      
      output-debug-message (word "Checking to see if there are any productions recognised.  If not, pattern-recognition is impossible so I won't continue with pattern-recognition...") (who)
      if(not empty? productions-for-recognised-visual-chunks-in-scene)[
        output-debug-message (word "I have recognised some productions so I'll continue pattern-recognition...") (who)
        
        output-debug-message (word "Selecting an action to perform from the productions recognised using the specified action-selection procedure (" action-selection-procedure ")...") (who)        
        let action-selected ( runresult (word action-selection-procedure "( productions-for-recognised-visual-chunks-in-scene )" ) )

        output-debug-message (word "Checking to see if the action selected (" action-selected ") is not empty, if it isn't then I'll continue with pattern-recognition...") (who)
        if( not empty? action-selected )[
          
          output-debug-message (word "The action selected is not empty.  Checking to see if it indicates that I should use problem-solving to deliberate further, if not, I'll set my 'used-pattern-recognition' variable to 'true'...") (who)
          
          if( (item (0) (action-selected)) != (problem-solving-token))[
            output-debug-message ("Action selected indicates that I shouldn't use problem-solving so I'll set the local 'used-pattern-recognition' variable to 'true'...") (who)
            set used-pattern-recognition (true)
            
            set action (action-selected)
          
            output-debug-message (word "Since I have used pattern-recognition I'll set the local 'time-taken-to-deliberate' variable to my 'time-taken-to-use-pattern-recognition' value (" time-taken-to-problem-solve ")...") (who)
            set time-taken-to-deliberate (time-taken-to-deliberate + time-taken-to-use-pattern-recognition)
            output-debug-message (word "My 'time-taken-to-deliberate' variable is now equal to: " time-taken-to-deliberate "...") (who)
            
            output-debug-message (word "Since I generated an action using pattern recognition, I will increment my 'frequency-of-pattern-recognitions' variable (" frequency-of-pattern-recognitions ") by 1...") (who)
            set frequency-of-pattern-recognitions (frequency-of-pattern-recognitions + 1)
            output-debug-message (word "My 'frequency-of-pattern-recognitions' variable is now equal to: " frequency-of-pattern-recognitions "...") (who)
          ]
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
    let reset-variables (false)
    
    output-debug-message ( word "Checking to see if my 'plan' turtle variable is empty (contents: '" plan "')...") (who)
    ifelse( not (empty? (plan)) )[
      
      output-debug-message ( word "My 'plan' turtle variable isn't empty so I'll check to see if I am still deliberating i.e. is the current time (" report-current-time ") greater or equal to than the value of my 'deliberation-finished-time' turtle variable (" deliberation-finished-time ")...") (who)
      if(report-current-time >= deliberation-finished-time)[
        
        output-debug-message (word "Setting a local 'action-performed-successfully' variable to boolean false.  This will be used to determine what to do after the action has been executed..." ) (who)
        let action-performed-successfully (false)
        
        ;=================================================================;
        ;== GET AND PREPARE OBSERVABLE ENVIRONMENT FOR 'perform-action' ==;
        ;=================================================================;
        
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
        
        ;=================================;
        ;== PERFORM NEXT PLANNED ACTION ==;
        ;=================================;
        
        output-debug-message ( word "The current model time is greater than or equal to the value of my 'deliberation-finished-time' turtle variable so I'll attempt to perform the first action in my 'plan' and set the result of this to a local 'result-of-performing-action' variable..." ) (who)
        let plan-element (first (plan))
        let action-to-perform ( item (0) (plan-element) )
        let action-generated-using-pattern-recognition? ( item (1) (plan-element) )
        set action-to-perform (list
          (chrest:ItemSquarePattern.get-item (action-to-perform))
          (chrest:ItemSquarePattern.get-column (action-to-perform))
          (chrest:ItemSquarePattern.get-row (action-to-perform))
        )
        let result-of-performing-action ( perform-action (list (action-to-perform) (action-generated-using-pattern-recognition?)) (observable-environment) )
        
        output-debug-message ( word "Checking to see if the action has been performed.  If it has, this procedure will continue otherwise the action is scheduled for performance but hasn't been performed yet so this procedure will exit") (who)
        if (
          ;An empty list is reported by 'perform-action' if the action is scheduled for performance but hasn't been performed yet.
          (is-list? result-of-performing-action and not empty? result-of-performing-action) or
          (not is-list? result-of-performing-action)
        )[
        
          output-debug-message ( word "Checking to see if the local 'result-of-performing-action' variable is a list.  If this is the case then the action was performed and the action must have been a 'push-tile' action so the first element of the list will be whether the action was performed successfully whilst the second element will indicate whether or not a hole was filled..." ) (who)
          ifelse( is-list? (result-of-performing-action))[
          
            output-debug-message ( word "The local 'result-of-performing-action' variable is a list so I'll set the first element of this list to the local 'action-performed-successfully' variable..." ) (who)
            set action-performed-successfully ( item (0) (result-of-performing-action) )
          ]
          [
            output-debug-message ( word "The local 'result-of-performing-action' variable is not a list so I'll set the local 'action-performed-successfully' variable to its value..." ) (who)
            set action-performed-successfully (result-of-performing-action)
          ]
        
          ;=========================================;
          ;== CHECK SUCCESS OF ACTION PERFORMANCE ==;
          ;=========================================;
        
          output-debug-message ( word "Checking the value of the local 'action-performed-successfully' variable (" action-performed-successfully ")..." ) (who)
          ifelse( action-performed-successfully )[
          
            output-debug-message ( word "The local 'action-performed-successfully' variable value is set to 'true' so the action was performed successfully. remove the action from 'plan' and continue plan execution..." ) (who)
            set plan (remove-item (0) (plan))
            output-debug-message ( word "After removing the action from 'plan', this variable is now equal to: '" plan "'..." ) (who)
          
            output-debug-message ( word "Checking to see if the local 'result-of-performing-action' variable is a list.  If it is then the action performed must have been a 'push-tile' action so the first element of the list will be whether the action was performed successfully whilst the second element will indicate whether or not a hole was filled...") (who)
            if( is-list? (result-of-performing-action) ) [
            
              output-debug-message ( word "The local 'result-of-performing-action' variable is a list so I'll check the value of its second element (" item (1) (result-of-performing-action) ").  If this is 'true' I'll increment my score and reinforce the episodes in my 'episodic-memory'..." ) (who)
              if( item (1) (result-of-performing-action) )[
              
                output-debug-message ( word "The second element of the local 'result-of-performing-action' variable is 'true' so I'll reinforce all episodes in my 'episodic-memory'..." ) (who)
                reinforce-productions
                set reset-variables (true)
              ]
            ]
          ]
          [
            output-debug-message ( word "The action was not performed successfully so I should abandon this plan and construct a new one..." ) (who)
            set reset-variables (true)
          ]
        ]
      ]
    ]
    [
      output-debug-message ("My 'plan' turtle variable is empty.") (who)
      set reset-variables (true)
    ]
    
    ;===========================================;
    ;== RESET VARIABLES TO RE-ENABLE PLANNING ==;
    ;===========================================;
    
    if(reset-variables)[
      output-debug-message ( word "Resetting my 'generate-plan?' and 'construct-visual-spatial-field?' turtle variables to 'true' along with my episodic memory and plan to empty so that I can re-plan correctly..." ) (who)
      set generate-plan? (true)
      set construct-visual-spatial-field? (true)
      set plan ([])
      set episodic-memory ([])
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
          output-debug-message (word "Checking to see if I was pushing a tile that has been pushed into a hole or no longer exists in my visual-spatial field. The latter may be true if:\n"
             "1. The tile has been pushed out of the visual-spatial field\n" 
             "2. Its visual-spatial field object representation has decayed\n"
             "If this isn't checked, further planning may occur which should not be done since, when planning. I should be fixated on a tile and if it disappears or fills a hole I should execute the plan as-is..."
          ) (who)
          
          if( (not empty? who-of-tile-last-pushed-in-plan) )[
            
            output-debug-message (word "I've been pushing a tile so I'll check to see if it still exists or has been pushed onto a hole") (who)
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
          output-debug-message (word "The final plan is set to: '" map ([ (list (chrest:ItemSquarePattern.get-as-string item (0) (?)) (item (1) (?)))  ]) (plan) "'.") (who)
        ]
      ];construct-visual-spatial-field? check
    ];attention check
  ];CHREST turtle breed check
  
  set debug-indent-level (debug-indent-level - 2)
end

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
      ]      
      output-debug-message (word "Checking to see if " object " is on coordinates " tile-location " in my visual-spatial field...") (who)
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
          
          output-debug-message (word "My 'who-of-tile-last-pushed-in-plan' variable is now equal to: " who-of-tile-last-pushed-in-plan) (who)
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
  
  let original-location (list (xcor) (ycor))
  
  let patches-moved 0
  while [patches-moved < patches-to-move][
    
    ifelse( not (any? (turtles-on (patch-ahead (1))) with [hidden? = false]) )[
      output-debug-message (word "The patch immediately ahead of me along heading " heading " is clear (no visible turtles on it) so I'll move onto it...") (who)
      forward 1
    ]
    [
      output-debug-message (word "Move was unsuccessful since there is something blocking me along the heading specified, resetting my location and reporting that this is the case...") (who)
      setxy (item (0) (original-location)) (item (1) (original-location))
      set debug-indent-level (debug-indent-level - 2)
      report false
    ]
    
    set patches-moved (patches-moved + 1)
  ]
  
  output-debug-message (word "Move was successful, reporting that this is the case...") (who)
  set debug-indent-level (debug-indent-level - 2)
  report true
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
;@return  -                 List/Boolean             If the action was not a "push-tile" action then a boolean 
;                                                    value is returned (true if the action was performed 
;                                                    successfully, false if not).  If the action is a "push-tile"
;                                                    action then a list is returned (see documentation for the
;                                                    "push-tile" procedure to see what is returned and why).
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
  
  let action-performance-result []
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CHECK FOR VALID ACTION ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ifelse(member? (action-identifier) (possible-actions))[
    
    if(time-to-perform-next-action = 0)[
      output-debug-message (word "My 'time-to-perform-next-action' turtle variable is set to 0 so I'll set it to the current time (" report-current-time ") plus my 'action-performance-time' (" time-to-perform-next-action ")") (who)
      set time-to-perform-next-action (report-current-time + action-performance-time)
    ]
    
    output-debug-message (word "The action to perform (" action-identifier ") is a valid action.  Checking to see if the current time (" report-current-time ") is >= my 'time-to-perform-next-action' turtle variable (" time-to-perform-next-action ")") (who)
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;; ACTION PERFORMANCE TIME CHECK ;;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if(report-current-time >= time-to-perform-next-action)[
      
      output-debug-message (word "The current time is >= my 'time-to-perform-next-action' turtle variable so I'll attempt to perform the action and reset my 'time-to-perform-next-action' turtle variable to 0") (who)
      set time-to-perform-next-action (0)
      
      ;;;;;;;;;;;;;;;;;;;;;;
      ;;; PERFORM ACTION ;;;
      ;;;;;;;;;;;;;;;;;;;;;;
      
      ifelse(action-identifier = push-tile-token)[
        output-debug-message (word "The local 'action-identifier' variable is equal to: '" action-identifier "' so I should execute the 'push-tile' procedure...") (who)
          set action-performance-result ( push-tile (action-heading) )
      ]
      [
        output-debug-message (word "The local 'action-identifier' variable is equal to: '" action-identifier "' so I should execute the 'move' procedure...") (who)
          set action-performance-result ( move (action-heading) (action-patches) )
      ]
      
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;; ASSIGN ACTION PERFORMANCE SUCCESS VARIABLE ;;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      
      let action-performed-successfully (false)
      ifelse( is-list? (action-performance-result) )[
        set action-performed-successfully ( item (0) (action-performance-result) )
      ]
      [
        set action-performed-successfully (action-performance-result)
      ]
      
      output-debug-message (word "Was the action performed successfully: " action-performed-successfully) (who)
      
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
        let action-recognised ( chrest:recognise-and-learn-list-pattern (action-to-learn) (report-current-time) )
        if (action-recognised != "")[
          set action-recognised ( chrest:Node.get-image (action-recognised) )
          output-debug-message (word "Recognised " chrest:ListPattern.get-as-string (action-recognised) " given action " chrest:ListPattern.get-as-string (action-to-learn)) (who)
          
          ;Learn explicit action if problem-solving action already learned.
          if( 
            ( (chrest:ListPattern.get-as-string (action-to-learn)) = (chrest:ListPattern.get-as-string (problem-solving-action)) ) and 
            ( (chrest:ListPattern.get-as-string (action-recognised)) = (chrest:ListPattern.get-as-string (problem-solving-action)) ) 
          )[
            output-debug-message ("The action to learn is the problem-solving action but I've already learned it so I'll learn the explicit action instead") (who)
            set action-to-learn (explicit-action)
          ]
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
        let visual-list-pattern (chrest:ListPattern.new ("visual") (current-view-as-list-of-item-square-patterns))
        output-debug-message (word "Visual list-pattern before domain normalisation: " chrest:ListPattern.get-as-string (visual-list-pattern)) (who)
        
        set visual-list-pattern ( chrest:DomainSpecifics.normalise-list-pattern (visual-list-pattern) )
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
            
            let productions (chrest:get-productions (visual-list-pattern) (report-current-time))
            output-debug-message (word "Productions associated with " chrest:ListPattern.get-as-string (visual-list-pattern) ": " map ([chrest:ListPattern.get-as-string (chrest:Node.get-image (item (0) (?)))]) (productions)) (who)
            
            foreach(productions)[
              let action-node (item (0) (?))
              let action-node-contents ( chrest:ListPattern.get-as-netlogo-list (chrest:Node.get-image (action-node)) )
              foreach(action-node-contents)[
                let action (chrest:ItemSquarePattern.get-item (?))
                output-debug-message (word "Checking if '" action "' is equal to '" problem-solving-token "'" ) (who)
                if(action = problem-solving-token)[
                  output-debug-message (word "Action '" action "' is equal to '" problem-solving-token "' so there is already a problem-solving production for " chrest:ListPattern.get-as-string (visual-list-pattern) "!") (who)
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
  ]
  [
    error (word "The action to perform specified by turtle " who " is not a valid action (does not occur in the global 'possible-actions' list: " possible-actions ").")
  ]
  
  output-debug-message ( word "Reporting the result of performing the action (" action-performance-result ")..." ) (who)
  set debug-indent-level (debug-indent-level - 2)
  report action-performance-result
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
    ask self [
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
;to that indicated by the parameter passed to this procedure.  The procedure then
;branches in one of two ways depending on whether there is a tile, T, on the patch 
;immediately adjacent to the calling turtle's location along the heading specified.
;
; 1. There is no tile on the patch immediately ahead of the calling turtle along the 
;    heading specified.  The procedure will exit and indicate that the action was 
;    unsuccessful and a hole was not filled.
; 2. There is a tile on the patch immediately ahead of the calling turtle along the 
;    heading specified.  The tile, T, is asked to set its heading to that specified
;    by the input paramater too.  The procedure will then continue.
;
;The procedure then branches in one of two ways depending on whether there is a hole 
;on the patch ahead of T along its new heading:
;
;  1. There is a hole on the patch immediately ahead of T:
;     a. T moves forward by 1 patch.
;     b. The hole is asked to die.
;     c. T is asked to die.
;     d. The pusher's 'score' turtle variable is incremented by 1.
;
;  2. There isn't a hole on the patch immediately ahead of T. A check is made to see if 
;     there are any other visible turtles on the patch ahead of T.
;     a. There is a visible turtle on the patch ahead of T so T does not move.
;     b. There is no visible turtle on the patch ahead of T so T moves forward 1 patch.
;
;The pusher then checks to see if T has moved.
;
;  1. T has not moved so the pusher remains stationary.  The procedure will exit and 
;     indicate that the action was unsuccessful and a hole was not filled.
;  2. T has moved so it must have been pushed; pusher also moves forward one patch.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@param   push-heading      Number        The heading that the pusher should set its heading
;                                         to in order to push the tile in question.
;@return  -                 List          Contains two boolean values:
;                                         1) Whether the tile was pushed successfully.
;                                         2) Whether a hole was filled.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to-report push-tile [push-heading]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'push-tile' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  let push-tile-successful (false)
  let hole-filled (false)
  output-debug-message ( word "Two local 'push-tile-successful' and 'hole-filled' variables are set to: '" push-tile-successful "' and '" hole-filled "'..." ) (who)
  
  output-debug-message( word "Setting my heading to the value contained in the local 'push-heading' variable: " push-heading "...") (who)
  set heading (push-heading)
  output-debug-message (word "My 'heading' variable is now set to: " heading ".  Checking to see if there is a tile immediately ahead...") (who)
  
  if(any? tiles-on patch-at-heading-and-distance (heading) (1))[
    output-debug-message (word "There is a tile immediately ahead along heading " heading ".  Pushing this tile...") (who)
    
    ask tiles-on patch-at-heading-and-distance (heading) (1)[
      output-debug-message ("I am the tile to be pushed.") (who)
      output-debug-message (word "Setting my 'heading' variable value to that of the pusher (" [heading] of myself ")...") (who)
      set heading [heading] of myself
      output-debug-message (word "My 'heading' variable value is now set to: " heading ".") (who)
      output-debug-message (word "Checking to see if there are any visible holes immediately ahead of me with this heading...") (who)
    
      ifelse( any? (holes-on (patch-ahead (1))) with [hidden? = false] )[
        output-debug-message (word "There is a visible hole 1 patch ahead with my current heading (" heading ") so I'll move onto that patch, the hole will die, the 'hole-filled' variable will be set to true and I will die.") (who)
        forward 1
        ask holes-here with [hidden? = false][ die ]
        set hole-filled (true) 
        die
      ]
      [
        output-debug-message ("There are no visible holes ahead so I'll check to see if there are any other visible turtles ahead, if there is, I won't move...") (who)
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
  
  if(hole-filled)[
    output-debug-message ("A hole has been filled so I'll increment by 'score' turtle variable by 1") (who)
    set score (score + 1)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "REINFORCE-PRODUCTIONS" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;CHREST turtles only.
;
;Uses a CHREST turtle's reinforcement learning theory to reinforce productions
;identified by using the current contents of the turtle's episodic memory.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
to reinforce-productions
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'reinforce-productions' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  if(breed = chrest-turtles and (reinforce-problem-solving? or reinforce-actions?))[
    let rlt ("null")
    set rlt (chrest:get-reinforcement-learning-theory)
  
    output-debug-message (word "Checking to see if my reinforcement learning theory is set to 'null' (" rlt ").  If so, I won't continue with this procedure...") (who)
    if(rlt != "null")[
      
      output-debug-message ("Retrieving each of the items in my 'episodic-memory'and reinforcing relevant productions...") (who)
      output-debug-message (word "Time that reward was awarded: " report-current-time "s.") (who)
      output-debug-message (word "The contents of my 'episodic-memory' list is: " map ([ 
        (list
          (chrest:ListPattern.get-as-string (item (0) (?)))
          (chrest:ListPattern.get-as-string (item (1) (?)))
          (item (2) (?)) 
          (item (3) (?)) 
        )
      ]) 
      (episodic-memory)) (who)
      
      foreach(episodic-memory)[
        output-debug-message (word "Processing episode: " 
            (chrest:ListPattern.get-as-string (item (0) (?))) " "
            (chrest:ListPattern.get-as-string (item (1) (?))) " "
            (item (2) (?)) " "
            (item (3) (?))
        "...") (who)
        
        let visual-pattern (item (0) (?))
        let action-pattern (item (1) (?))
        let time-episode-performed (item (2) (?))
        let episode-generated-using-pattern-recognition? (item (3) (?))
        
        output-debug-message (word "Visual pattern is: " chrest:ListPattern.get-as-string (visual-pattern)) (who)
        output-debug-message (word "Action pattern is: " chrest:ListPattern.get-as-string (action-pattern)) (who)
        output-debug-message (word "Episode was performed at time " time-episode-performed) (who)
        output-debug-message (word "Was pattern-recognition used to generate this episode: " episode-generated-using-pattern-recognition?) (who)
        
        ; When reinforcing a production, it may be the case that a problem-solving production is viable for reinforcement;
        ; the following table indicates when this should occur.  Note that rows where both the "Reinf PS?" and "Reinf Action?"
        ; columns are equal to "No" are not shown since the CHREST turtle must be capable of reinforcing either problem-solving
        ; or pattern-recognition to get to this point.
        ;
        ; |----------------------|-----------|---------------|----------------------------------------------------|
        ; | PS Generate Episode? | Reinf PS? | Reinf Action? | Outcome                                            |
        ; |----------------------|-----------|---------------|----------------------------------------------------|
        ; | Yes                  | Yes       | Yes           | Choice between reinforcing PS or action production |
        ; |                      |           | No            | Reinforce PS production                            |
        ; |                      | No        | Yes           | Reinforce action production                        |
        ; | No                   | Yes       | Yes           | Reinforce action production                        |
        ; |                      |           | No            | Checked below                                      |
        ; |                      | No        | Yes           | Reinforce action                                   |
        ; |----------------------|-----------|---------------|----------------------------------------------------|
        ;
        ; If it is the case that the turtle should reinforce a problem-solving production but can also reinforce actions
        ; then the CHREST turtle checks to see if it has learned the problem-solving production for the visual pattern 
        ; yet.  If it hasn't, it will fall-back to try and reinforce the explicit action production instead (if the 
        ; explicit action production doesn't exist then nothing is reinforced). 
        
        if(not (episode-generated-using-pattern-recognition? and not reinforce-actions?))[
          output-debug-message ("Its not the case that the current episode contains an explicit action generated using pattern-recognition and I can't reinforce explicit actions so I'll try to reinforce the production indicated by this episode...") (who) 

          let problem-solving-pattern (chrest:ListPattern.new ("action") (list chrest:ItemSquarePattern.new (problem-solving-token) (0) (0)))
          let action-pattern-to-reinforce (action-pattern)
          
          if(not episode-generated-using-pattern-recognition?)[
            if(reinforce-problem-solving?)[
              ifelse(reinforce-actions?)[
                if( (random-float 1.0) < 0.5)[
                  set action-pattern-to-reinforce (problem-solving-pattern)
                ]
              ]
              [
                set action-pattern-to-reinforce (problem-solving-pattern)
              ]
            ]
          ]
          output-debug-message (word "The action pattern to reinforce is: " chrest:ListPattern.get-as-string (action-pattern-to-reinforce)) (who)
          
          if(
            (chrest:ListPattern.get-as-string (action-pattern-to-reinforce) = chrest:ListPattern.get-as-string (problem-solving-pattern)) and 
            reinforce-actions?
          )[
            output-debug-message (word "Since the action pattern to reinforce is the problem-solving action and I can reinforce explicit actions too, I'll check to see if a production exists between the visual pattern in this episode and the problem-solving action") (who)
            let problem-solving-production-learned? (false)
            let productions (chrest:get-productions (visual-pattern) (report-current-time))
          
            foreach (productions)[
              let production (?)
              let production-action-pattern (chrest:Node.get-image ((item (0) (production))))
              let production-value (item (1) (production))
              output-debug-message (word "Processing production with action " chrest:ListPattern.get-as-string (production-action-pattern)) (who)
              
              if( chrest:ListPattern.get-as-string (production-action-pattern) = chrest:ListPattern.get-as-string (problem-solving-pattern) )[
                output-debug-message ("This is a problem-solving action so I've learned a problem-solving production for the visual pattern in the episode") (who)
                set problem-solving-production-learned? (true)
              ]
            ]
          
            if(not problem-solving-production-learned?)[
              output-debug-message ("I've not learned a problem-solving production for the visual pattern in this episode and I was supposed to reinforce such a production so I'll try to reinforce the explicit action instead") (who)
              set action-pattern-to-reinforce (action-pattern)
            ]
          ]
          
          output-debug-message (word "Attempting to reinforce production between visual pattern " chrest:ListPattern.get-as-string (visual-pattern) " and action pattern " chrest:ListPattern.get-as-string (action-pattern-to-reinforce)) (who)
          output-debug-message (word "The variables used to calculate the reinforcement value are as follows: 'reward-value' = '" reward-value "', 'discount-rate' = '" discount-rate "', current-time = '" report-current-time "' and 'time-episode-performed' = '" time-episode-performed "'") (who)
          chrest:reinforce-production 
            (visual-pattern) 
            (action-pattern-to-reinforce) 
            (list 
              (reward-value) 
              (discount-rate) 
              (report-current-time) 
              (time-episode-performed) 
            )
            (report-current-time)
        ]
      ]
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
;@param   actions-and-weights  List          [
;                                              [
;                                                [action-token heading patches]
;                                                value
;                                              ]
;                                              [
;                                                [action-token heading patches]
;                                                value
;                                              ]
;                                            ]
;@return  -                    String        The action pattern to perform formatted as:
;                                            "[act-token heading patches]".
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to-report roulette-selection [actions-and-values]
 set debug-indent-level (debug-indent-level + 1)
 output-debug-message ("EXECUTING THE 'roulette-selection' PROCEDURE...") ("")
 set debug-indent-level (debug-indent-level + 1)
 output-debug-message (word "The actions and values to work with are: " actions-and-values ) (who)
 
 ;==============================================;
 ;== CHECK FOR ACTIONS THAT HAVE VALUES > 0.0 ==;
 ;==============================================;
 
 ; The "roulette-selection" algorithm can not operate if the actions passed to it all have values of
 ; 0 so at least one action must have a value greater than this.  A check is performed here for such 
 ; a situation.
 
 output-debug-message (word "Adding actions that have a value > 0.0 to a local 'candidate-actions-and-values' list." ) (who)
 let candidate-actions-and-values []
 foreach(actions-and-values)[
   if( (item (1) (?)) > 0.0 )[
     output-debug-message (word (item (1) (?)) " is greater than 0.0, adding it to the 'candidate-actions-and-values' list...") (who)
     set candidate-actions-and-values (lput (?) (candidate-actions-and-values))
   ]
 ]
 
 ifelse(empty? candidate-actions-and-values)[
   output-debug-message ("The 'candidate-actions-and-values' list is empty, reporting an empty list...") (who)
   set debug-indent-level (debug-indent-level - 2)
   report []
 ]
 [
   output-debug-message ("The 'candidate-actions-and-values' list is not empty, processing its items...") (who)
   output-debug-message (word "The 'candidate-actions-and-values' list contains: " candidate-actions-and-values ".") (who)
   
   ;=========================;
   ;== SUM TOGETHER VALUES ==;
   ;=========================;
   
   output-debug-message ("First, I'll sum together the values in 'candidate-actions-and-values'") (who)
   let sum-of-values 0
   foreach(candidate-actions-and-values)[
     set sum-of-values ( sum-of-values + (item (1) (?)) )
   ]
   output-debug-message (word "The sum of all values is: " sum-of-values ".")  (who)
   
   output-debug-message ("Now, I need to build normalised ranges of values for the actions in the 'candidate-actions-and-values' list...") (who)
   let action-value-ranges []
   let range-min 0
   foreach(candidate-actions-and-values)[
     output-debug-message (word "The minimum range for action " (item (0) (?)) " is currently set to: " range-min "...") (who)
     let range-max (range-min + ( (item (1) (?)) / sum-of-values) )
     output-debug-message (word "The max range for action " (item (0) (?)) " is currently set to: " range-max "...") (who) 
     set action-value-ranges (lput (list (item (0) (?)) (range-min) (range-max) ) (action-value-ranges) )
     set range-min (range-max)
   ]
   output-debug-message (word "After processing each 'candidate-actions-and-values' item, the 'action-value-ranges' variable is equal to: " action-value-ranges "...") (who)
   
   output-debug-message (word "The maximum max range value should be equal to 1.0 (" (item (2) (last action-value-ranges)) "), checking if this is the case...") (who)
   ifelse((item (2) (last action-value-ranges)) = 1.0)[
     output-debug-message ("The maximum max range value is equal to 1.0.  Generating a random float, 'r', that is >= 0 and < 1.0.  This will be used to select an action...") (who)
     let r (random-float 1.0)
     output-debug-message (word "The variable 'r' = " r) (who)
     
     output-debug-message ("Checking each item in the 'action-value-ranges' variable to see if 'r' is between its min and max range.  If it is, that action will be selected...") (who)
     foreach(action-value-ranges)[
       output-debug-message (word "Processing item: " ? "...") (who)
       output-debug-message (word "Checking if 'r' (" r ") is >= " (item (1) (?)) " and < " (item (2) (?)) "...") (who)
       if( ( r >= (item (1) (?)) ) and ( r < (item (2) (?)) ) )[
         output-debug-message (word "'r' is in the range of values for action " (item (0) (?)) ", reporting this as the action to perform..." ) (who)
         set debug-indent-level (debug-indent-level - 2)
         report (item (0) (?))
       ]
       output-debug-message (word "'r' is not in the range of values for action " (item (0) (?)) ".  Processing next item...") (who)
     ]
   ]
   [
     output-debug-message ("The max range value is not equal to 1.0, reporting an empty list") (who)
     set debug-indent-level (debug-indent-level - 2)
     report []
   ]
 ]
end

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
    set time-to-perform-next-action 0
    set episodic-memory []
    set sight-radius-colour (color + 2)
    set generate-plan? true
    set current-search-iteration 0
    set who-of-tile-last-pushed-in-plan ""
    
    set deliberation-finished-time -1
    if(can-plan?)[
      set deliberation-finished-time 0
    ]
    
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
T
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
148
336
Run Procedure Tests
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
