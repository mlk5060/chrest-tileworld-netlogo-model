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
;TODO: Extract test procedures into Netlogo extension.
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
  java
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
  colors-used                    ;Stores a list of the colors used by CHREST turtles: used to ensure colour uniqueness to make graphs easier to interpret.
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
  move-token                     ;Stores the string used to indicate that the calling turtle should move.
  movement-headings              ;Stores headings that agents can move along.
  ;output-interval                ;Stores the interval of time that must pass before data is output to the model's output area.
  possible-actions               ;Stores a list of action identifier strings.  If adding a new action, include its identifier in this list.
  push-tile-token                ;Stores the string used to indicate that the calling turtle pushed a tile in action-patterns.
  reward-value                   ;Stores the value awarded to turtles when they push a tile into a hole.
  save-interface?                ;Stores a boolean value that indicates whether the user wishes to save an image of the interface when running the model.
  save-output-data?              ;Stores a boolean value that indicates whether the user wishes to save output data when running the model.
  save-training-data?            ;Stores a boolean value that indicates whether or not data should be saved when training completes.
  save-world-data?               ;Stores a boolean value that indicates whether the user wishes to save world data when running the model.
  opponent-token                 ;Stores the string used to indicate an opponent in scene instances.
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
  tuition?                       ;Boolean: true if the game is currently in tuition mode, false if not.
  unknown-patch-token            ;Stores the string used to indicate an unknown patch (patch whose object status is unknown) for Scene instances created from a CHREST turtle's VisualSpatialField instance.
]
     
chrest-turtles-own [
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;; ACTING VARIABLES ;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  deliberation-finished-time                            ; Stores the time (in milliseconds) that the turtle will finish deliberating.     ; No
                                                        ; Controls plan execution for planning turtles and action execution for           ;
                                                        ; non-planning turtles.                                                           ;
  episode-to-learn-from                                 ; Stores a number indicating the index of the episode to learn from with respect  ; No
                                                        ; to 'episodic-memory'                                                            ;
  episode-to-reinforce                                  ; Stores a number indicating the index of the episode to reinforce with respect   ; No
                                                        ; to 'episodic-memory'                                                            ; 
  execute-actions?                                      ; Stores whether or not actions should be executed                                ; No
  fixate-on-reality?                                    ; Stores a boolean value that indicates if the turtle should make fixations on    ; No
                                                        ; reality, i.e. fixate on what it can see in the Tileworld itself                 ;
  fixate-on-visual-spatial-field?                       ; Stores a boolean value that indicates if the turtle should make fixations on    ; No
                                                        ; its visual-spatial field                                                        ;
  generate-plan?                                        ; Stores a boolean value that indicates if the turtle should generate a plan      ; No
  learn-action-sequence?
  learn-action-sequence-as-production?
  learn-episode-action?                                 ; Stores a boolean value that indicates if the turtle should learn the action in  ; No
                                                        ; the episode indicated by 'episode-to-learn-from'                                ;
  learn-episode-vision?                                 ; Stores a boolean value that indicates if the turtle should learn the vision in  ; No
                                                        ; the episode indicated by 'episode-to-learn-from'                                ;
  learn-episode-as-production?                          ; Stores a boolean value that indicates if the turtle should learn the episode    ; No
                                                        ; indicated by 'episode-to-learn-from' as a production                            ;
  learn-from-episodic-memory?                           ; Stores a boolean value that indicates if the turtle should learn from its       ; No
                                                        ; 'episodic-memory'                                                               ;
  reinforce-productions?                                ; Boolean switch used to control whether the turtle should be reinforcing the     ; No
                                                        ; productions represented by its episodes in its episodic memory.                 ;
  time-visual-spatial-field-can-be-used-for-planning    ; Stores the time that the visual-spatial field can be used for planning          ; No
  
  ;=========================================================================================;=================================================================================;=====================;
  ; VARIABLE NAME                                                                           ; DESCRIPTION                                                                     ; SET IN SET-UP FILE? ;
  ;=========================================================================================;=================================================================================;=====================;
  actions-to-perform                                                                        ; Stores the actions the CHREST turtle is scheduled to perform                    ; No
  add-production-time                                                                       ; Stores the length of time (in milliseconds) that it takes to add a production   ; Yes
                                                                                            ; in LTM.                                                                         ;
  can-create-semantic-links?                                                                ; Stores a boolean value indicating whether the turtle can create semantic links  ; Yes
                                                                                            ; in long-term memory.                                                            ;
  can-create-templates?                                                                     ; Stores a boolean value indicating whether the turtle can create templates in    ; Yes
                                                                                            ; long-term memory.                                                               ;
  can-plan?                                                                                 ; Stores a boolean value indicating whether the turtle is capable of planning.    ; Yes
  can-use-pattern-recognition?                                                              ; Stores a boolean value that indicates whether pattern-recognition can be used   ; Yes
                                                                                            ; by the calling turtle or not.                                                   ;
  CHREST                                                                                    ; Stores an instance of the CHREST architecture.                                  ; No                                        ;
  current-search-iteration                                                                  ; Stores the number of search iterations the turtle has made in the current       ; No
                                                                                            ; planning cycle.                                                                 ;
  discount-rate                                                                             ; Stores the discount rate used for the "profit-sharing-with-discount-rate"       ; Yes
                                                                                            ; reinforcement learning algorithm.                                               ;
  discrimination-time                                                                       ; Stores the length of time (in milliseconds) that it takes for this turtle to    ; Yes
                                                                                            ; create a new node in CHREST's LTM.                                              ;
  episodic-memory                                                                           ; Stores visual patterns generated, action patterns generated in response to that ; No
                                                                                            ; visual pattern, the time the action was performed and whether problem-solving   ; 
                                                                                            ; was used to determine the action in a FIFO list data structure.                 ;
  familiarisation-time                                                                      ; Stores the length of time (in milliseconds) that it takes to extend the image   ; Yes
                                                                                            ; of a node in the LTM of the CHREST architecture.                                ;
  fixation-field-of-view                                                                    ; The number of squares that can be seen around a fixation point in each cardinal ; Yes
                                                                                            ; and primary inter-cardinal compass point                                        ;
  frequency-of-problem-solving                                                              ; Stores the total number of times problem-solving has been used to generate an   ; No
                                                                                            ; action for the turtle.                                                          ;
  frequency-of-pattern-recognitions                                                         ; Stores the total number of times pattern recognition has been used to generate  ; No
                                                                                            ; an action for the CHREST turtle.                                                ;
  heading-when-plan-execution-begins                                                        ; Stores the heading of the CHREST turtle when the first action in the current    ; No
                                                                                            ; plan is performed.  This allows the turtle to orientate itself correctly when   ;
                                                                                            ; performing a sequence of planned actions, i.e. if the turtle is facing south    ;
                                                                                            ; when it starts executing the actions in its current plan and it is to perform 3 ;
                                                                                            ; move actions along headings 0, 180 and 270 the turlte should move south, north  ;
                                                                                            ; and east rather than south, north and west as it would if its current heading   ;
                                                                                            ; is used to determine the action heading after each action is performed          ;                                                        ;
  initial-fixation-threshold                                                                ; Stores the number of Fixations that can be made before the turtle is no longer  ; Yes
                                                                                            ; considered to be making initial fixations in a set.                             ;
  ltm-link-traversal-time                                                                   ; Stores the time (milliseconds) it takes for the CHREST turtle to traverse a     ; Yes
                                                                                            ; link in its long-term memory.                                                   ;
  max-fixations-in-set                                                                      ; Stores the maximum number of Fixations the turtle can make in a set.            ; Yes
;  max-length-of-episodic-memory                                                              Stores the maximum length of the turtle's "episodic-memory" list.               ; ---
  max-search-iteration                                                                      ; Stores the maximum number of search iterations the turtle can make in a         ; Yes
                                                                                            ; planning cycle.                                                                 ;
  maximum-semantic-link-search-distance                                                     ; Stores the maximum number of Nodes traversed along when following the semantic  ; Yes
                                                                                            ; links of a Node retrieved from long-term memory during recognition.             ;
  minimum-depth-of-node-in-network-to-be-a-template                                         ; Stores how deep a Node must be in long-term memory before it can become a       ; Yes
                                                                                            ; template                                                                        ;
  minimum-item-or-position-occurrences-in-node-images-to-be-a-slot-value                    ; Stores how many times an item or position must occur in the                     ; Yes
                                                                                            ; jchrest.lib.ItemSquarePatterns constituting a Node's image before that item or  ;
                                                                                            ; position can become a slot value in the Node's parent that is a template.       ;
  node-comparison-time                                                                      ; Stores the time (milliseconds) taken to compare two Nodes during cognitive      ; Yes
                                                                                            ; operations                                                                      ;
  node-image-similarity-threshold                                                           ; Stores the number of jchrest.lib.PrimitivePatterns in a jchrest.lib.ListPattern ; Yes
                                                                                            ; that must be shared by the images of two nodes before they are considered       ;
                                                                                            ; similar enough to have a semantic link created between them.                    ;
  peripheral-item-fixation-max-attempts                                                     ; Stores the maximum number of attempts this turtle will make to fixate on a      ; Yes
                                                                                            ; square containing an item when making a                                         ;
                                                                                            ; jchrest.domainSpecifics.fixations.PeripheralItemFixation.                       ;
  play-time                                                                                 ; Stores the length of time (in milliseconds) that the turtle plays for after     ; Yes
                                                                                            ; training.                                                                       ;
  probability-of-using-problem-solving                                                      ; Stores the probability of a CHREST turtle using problem-solving when            ; Yes
                                                                                            ; deliberating                                                                    ;
  recognised-visual-spatial-field-object-lifespan                                           ; Stores the length of time (in milliseconds) that a recognised visual-spatial    ; Yes
                                                                                            ; field object will persist in the turtle's visual-spatial field for before it    ;
                                                                                            ; decays after having attention focused on it.                                    ;
  reinforce-production-time                                                                 ; Stores the time (milliseconds) it takes for the turtle to reinforce a           ; Yes
                                                                                            ; production in long-term memory                                                  ;
  reinforcement-learning-theory                                                             ; Stores the name of the jchrest.lib.ReinforcementLearning class the turtle will  ; Yes
                                                                                            ; use to reinforce productions.                                                   ;
  rho                                                                                       ; Stores how likely it is that the turtle will refuse to learn input passed to it.; Yes
                                                                                            ; Should be between 0.0 and 1.0.                                                  ;
  saccade-time                                                                              ; Stores the time (millisecond) it takes for the turtle to perform a saccade when ; Yes
                                                                                            ; fixating on the environment/its visual-spatial field.                           ;
  save-ltm-state?                                                                           ; Stores a boolean that indicates if this turtle's long-term memory should be     ; Yes
                                                                                            ; saved at the conclusion of its "life".                                          ;
  score                                                                                     ; Stores the score of the turtle (the number of holes that have been filled by    ; No
                                                                                            ; it).                                                                            ; 
  sight-radius                                                                              ; Stores the number of patches that can be seen to the north/east/south/west of   ; Yes
                                                                                            ; the turtle.                                                                     ;
  sight-radius-colour                                                                       ; Stores the colour that patches which fall within the turtle's sight-radius will ; No
                                                                                            ; be set to if debugging is switched on.                                          ;
  time-last-hole-filled                                                                     ; Stores the time that the last hole was filled by the turtle.  Used to calculate ; No
                                                                                            ; reinforcement values.                                                           ;
  time-spent-deliberating                                                                   ; Stores the total amount of time spent deliberating by the turtle                ; No
  time-taken-to-decide-upon-ahead-of-agent-fixations
  time-taken-to-decide-upon-movement-fixations
  time-taken-to-decide-upon-peripheral-item-fixations
  time-taken-to-decide-upon-peripheral-square-fixations
  time-taken-to-decide-upon-salient-object-fixations
  time-taken-to-move                                                                        ; Stores the length of time (in milliseconds) required for the turtle to move     ; Yes
                                                                                            ; itself.                                                                         ;
  time-taken-to-push-tile                                                                   ; Stores the length of time (in milliseconds) required for the turtle to push     ; Yes
                                                                                            ; a tile.                                                                         ;                                      
  time-to-access-visual-spatial-field                                                       ; Stores the length of time (in milliseconds) required to access the turtle's     ; Yes
                                                                                            ; visual-spatial field.                                                           ;
  time-to-create-semantic-link                                                              ; Stores the time (milleseconds) that it takes the turtle to create a semantic    ; Yes
                                                                                            ; link in long-term memory.
  time-to-encode-recognised-visual-spatial-field-object                                     ; Stores the length of time (in milliseconds) that it takes to encode a           ; Yes
                                                                                            ; recognised scene object as a visual-spatial field object during visual-spatial  ;
                                                                                            ; field construction.                                                             ;
  time-to-encode-unrecognised-empty-square-as-visual-spatial-field-object                   ; Stores the length of time (in milliseconds) that it takes to encode an          ; Yes
                                                                                            ; unrecognised scene object representing an empty square as a visual-spatial      ;
                                                                                            ; field object during visual-spatial field construction.                          ;                                   ;
  time-to-encode-unrecognised-visual-spatial-field-object                                   ; Stores the length of time (in milliseconds) that it takes to encode an          ; Yes
                                                                                            ; unrecognised scene object representing a non-empty square (a turtle) as a       ;
                                                                                            ; visual-spatial field object during visual-spatial field construction.           ;              ;
  time-to-generate-action-when-no-tile-seen                                                 ; Stores the time taken to generate an action when no tile can be seen            ; Yes
  time-to-generate-action-when-tile-seen                                                    ; Stores the time taken to generate an action when a tile can be seen             ; Yes
  time-to-move-visual-spatial-field-object                                                  ; Stores the length of time (in milliseconds) that it takes to move a             ; Yes
                                                                                            ; visual-spatial field object on the turtle's visual-spatial field.               ;
  time-to-process-unrecognised-scene-object-during-visual-spatial-field-construction        ; Stores the length of time (in milliseconds) that it takes to process an         ; Yes
                                                                                            ; unrecognised scene object during visual-spatial field construction (in addition ;
                                                                                            ; to encoding this as an empty/non-empty square).                                 ;  
  time-to-perform-next-action                                                               ; Stores the time that the action-pattern stored in the "next-action-to-perform"  ; No
                                                                                            ; turtle variable should be performed.                                            ;
  time-to-retrieve-fixation-from-perceiver                                                  ; Stores the time taken to retrieve a Fixation from the                           ; Yes
                                                                                            ; jchrest.architecture.Perceiver associated with the jchrest.architecture.Chrest  ;
                                                                                            ; instance for the calling turtle.                                                ;
  time-to-retrieve-item-from-stm                                                            ; Stores the time (milliseconds) taken to retrieve a Node from any STM modality   ; Yes
  time-to-update-stm                                                                        ; Stores the time (milliseconds) taken to put a Node into any STM modality        ; Yes
  training-time                                                                             ; Stores the length of time (in milliseconds) that the turtle can train for.      ; Yes
  tutees                                                                                    ; Stores a list of turtle "who" numbers that are the tutees of this turtle (if it ; Yes
                                                                                            ; is a tutor, see the "tutor?" variable).                                         ;
  tutor?                                                                                    ; Stores a boolean indicating whether the turtle is a tutor or not; true if it    ; Yes
                                                                                            ; is, false if it isn't.                                                          ;
  unknown-visual-spatial-field-object-replacement-probabilities                             ; Stores a list of lists of the form [[probability object-token]] used as input   ; Yes
                                                                                            ; to the "get-visual-spatial-field-as-scene" CHREST extension primitive.          ;
  unrecognised-visual-spatial-field-object-lifespan                                         ; Stores the length of time (in milliseconds) that an unrecognised visual-spatial ; Yes
                                                                                            ; field object will persist in the turtle's visual-spatial field for before it    ;
                                                                                            ; decays after having attention focused on it.                                    ;
  who-of-tile-last-pushed-in-plan                                                           ; Stores the 'who' variable value of the tile last pushed during planning; allows ; No
                                                                                            ; the turtle to "concentrate" on this tile so that, if multiple tiles can be      ;
                                                                                            ; seen, planning will end when this tile is pushed out of the visual-spatial      ;
                                                                                            ; field or pushed into a hole.  Also, allows for precise reversals of             ;
                                                                                            ; visual-spatial field moves that result in invalid visual-spatial field states.  ;
]
   
tiles-own [ 
  lifespan
  time-created
]
     
holes-own [ 
  lifespan
  time-created
]

;******************************;
;******************************;
;********* PROCEDURES *********;
;******************************;
;******************************;
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "ADD-EPISODE-TO-EPISODIC-MEMORY" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Adds an episode to the calling turtle's "episodic-memory" list.
;
;An episode is a Netlogo list with the following structure:
;
; - Element 1: The visual information that generated the action(s) 
;              in the episode.  Can be any type of data structure.
; - Element 2: The action(s) that was generated in response to the
;              visual part of the episode.  Can be any type of
;              data structure.
; - Element 3: The time the episode was generated.  This is a
;              number
; - Element 4: The time the action is to be/was performed, set 
;              to -1 initially. This is a number.
;
;         Name                Data Type                                Description
;         ----                ---------                                -----------
;@param   vision              chrest-turtles: jchrest.lib.ListPattern  The visual part of the episode.
;@param   action              chrest-turtles: jchrest.lib.ListPattern  The action part of the episode.
;@param   time-generated      Number                                   The time the episode was generated.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to add-episode-to-episodic-memory [vision action time-generated]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'add-episode-to-episodic-memory' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
;  
;  if(breed = chrest-turtles)[
;  
;    let rlt ("null")
;    if(breed = chrest-turtles)[
;      set rlt (chrest:get-reinforcement-learning-theory)
;    ]
;    
;    output-debug-message (word "Checking to see if my reinforcement learning theory is set to 'null' (" rlt ").  If so, I won't continue with this procedure...") (who)
;    if(rlt != "null")[
;      
;      output-debug-message (word "Before modification my 'episodic-memory' is set to: '" episodic-memory "'." ) (who)
;      output-debug-message (word "Checking to see if the length of my 'episodic-memory' (" length episodic-memory ") is greater than or equal to the value specified for the 'max-length-of-episodic-memory' variable (" max-length-of-episodic-memory ")...") (who)
;      if( (length (episodic-memory)) >= max-length-of-episodic-memory )[
;        output-debug-message ("The length of the 'episodic-memory' list is greater than or equal to the value specified for the 'max-length-of-episodic-memory' variable...") (who)
;        set episodic-memory (but-first episodic-memory)
;        output-debug-message (word "After removing the first (oldest) item, my 'episodic-memory' is set to: '" episodic-memory "'." ) (who)
;      ]
;      
      let episode (list (vision) (action) (time-generated) (-1))
      set episodic-memory (lput (episode) (episodic-memory))
      output-debug-message (word "State of 'episodic-memory' after addition: '" episodic-memory "'.") (who)
;    ]
;  ]
  
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
  ask tiles [
    if( (abs (time-created - report-current-time)) >= lifespan )[
      die
    ]
  ]
  
  ask holes [
    if( (abs (time-created - report-current-time)) >= lifespan )[
      die
    ]
  ]
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

;Checks to see if all variable values that need to be set are set and 
;are valid.
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
;  let number-global-variable-names-min-and-max-values (list 
;    ( list ("hole-birth-prob") (false) (0.0) (1.0) )
;    ( list ("hole-born-every") (true) (1) (false) )
;    ( list ("hole-lifespan") (true) (1) (false) )
;    ( list ("reward-value") (false) (0.0) (false) )
;    ( list ("tile-birth-prob") (false) (0.0) (1.0) )
;    ( list ("tile-born-every") (true) (1) (false) )
;    ( list ("tile-lifespan") (true) (1) (false) )
;  )
;  
;  foreach(number-global-variable-names-min-and-max-values)[
;    check-number-variables ("") (item (0) (?)) (runresult (item (0) (?))) (item (1) (?)) (item (2) (?)) (item (3) (?))
;  ]
  
  ;Boolean type variables
  
  ;=============================;
  ;== CHREST-TURTLE VARIABLES ==;
  ;=============================;
  
  ask chrest-turtles[
    
    let max-time ( max (list (play-time) (training-time)) )
    
    ;Number type variables.
    let number-type-chrest-turtle-variables (list
      ( list ("add-production-time") (true) (1) (max-time) )
      ( list ("discount-rate") (false) (0.0) (1.0) )
      ( list ("discrimination-time") (true) (1) (max-time) )
      ( list ("familiarisation-time") (true) (1) (max-time) )
      ( list ("fixation-field-of-view") (true) (0) (min (list (max-pxcor) (max-pycor))) )
      ( list ("initial-fixation-threshold") (true) (1) (max-fixations-in-set - 1) )
      ( list ("ltm-link-traversal-time") (true) (1) (max-time) )
      ( list ("max-fixations-in-set") (true) (1) (false) )
      ( list ("max-search-iteration") (true) (1) (false) )
      ( list ("maximum-semantic-link-search-distance") (true) (0) (false) )
      ( list ("minimum-depth-of-node-in-network-to-be-a-template") (true) (1) (false) )
      ( list ("minimum-item-or-position-occurrences-in-node-images-to-be-a-slot-value") (true) (1) (false) )
      ( list ("node-comparison-time") (true) (1) (max-time) )
      ( list ("node-image-similarity-threshold") (true) (1) (false) )
      ( list ("peripheral-item-fixation-max-attempts") (true) (1) (false) )
      ( list ("play-time") (true) (1) (false) )
      ( list ("probability-of-using-problem-solving") (false) (0.0) (1.0) )
      ( list ("recognised-visual-spatial-field-object-lifespan") (true) (1) (max-time) )
      ( list ("reinforce-production-time") (true) (1) (max-time) )
      ( list ("rho") (false) (0.0) (1.0) )
      ( list ("saccade-time") (true) (1) (max-time) )
      ( list ("sight-radius") (true) (1) (min (list (max-pxcor) (max-pycor))) )
      ( list ("time-taken-to-decide-upon-ahead-of-agent-fixations") (true) (1) (max-time) )
      ( list ("time-taken-to-decide-upon-movement-fixations") (true) (1) (max-time) )
      ( list ("time-taken-to-decide-upon-peripheral-item-fixations") (true) (1) (max-time) )
      ( list ("time-taken-to-decide-upon-peripheral-square-fixations") (true) (1) (max-time) )
      ( list ("time-taken-to-decide-upon-salient-object-fixations") (true) (1) (max-time) )
      ( list ("time-taken-to-move") (true) (1) (max-time) )
      ( list ("time-taken-to-push-tile") (true) (1) (max-time) )
      ( list ("time-to-access-visual-spatial-field") (true) (1) (max-time) )
      ( list ("time-to-create-semantic-link") (true) (1) (max-time) )
      ( list ("time-to-encode-recognised-visual-spatial-field-object") (true) (1) (max-time) )
      ( list ("time-to-encode-unrecognised-empty-square-as-visual-spatial-field-object") (true) (1) (max-time) )
      ( list ("time-to-encode-unrecognised-visual-spatial-field-object") (true) (1) (max-time) )
      ( list ("time-to-generate-action-when-no-tile-seen") (true) (1) (max-time) )
      ( list ("time-to-generate-action-when-tile-seen") (true) (1) (max-time) )
      ( list ("time-to-move-visual-spatial-field-object") (true) (1) (max-time) )
      ( list ("time-to-process-unrecognised-scene-object-during-visual-spatial-field-construction") (true) (1) (max-time) )
      ( list ("time-to-retrieve-fixation-from-perceiver") (true) (1) (max-time) )
      ( list ("time-to-retrieve-item-from-stm") (true) (1) (max-time) )
      ( list ("time-to-update-stm") (true) (1) (max-time) )
      ( list ("training-time") (true) (0) (false) )
      ( list ("unrecognised-visual-spatial-field-object-lifespan") (true) (1) (false) )
    )
    
    foreach(number-type-chrest-turtle-variables)[
      check-number-variables (who) (item (0) (?)) (runresult (item (0) (?))) (item (1) (?)) (item (2) (?)) (item (3) (?))
    ]
    
    ;Boolean type variables
    let boolean-type-chrest-turtle-variables (list
      ( list ("can-create-semantic-links?") )
      ( list ("can-create-templates?") )
      ( list ("can-plan?") )
      ( list ("can-use-pattern-recognition?") )
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
     
     ;====================;
     ;== MAKE FIXATIONS ==;
     ;====================;
     
     make-fixation
     
     ;===================;
     ;== GENERATE PLAN ==;
     ;===================;
     
     ifelse(can-plan? and chrest:is-attention-free? (report-current-time))[
       output-debug-message (word "I can plan so I'll see if I should generate a new plan or add to the exisiting one...") (who)
       generate-plan
     ]
     [
       output-debug-message ("I am not capable of planning") (who)
     ]

     ;=========================;
     ;== EXECUTE NEXT ACTION ==;
     ;=========================;
     
     output-debug-message (word 
       "Checking if I should attempt to schedule/execute my next action, i.e. is the current-time >= my "
       "'deliberation-finished-time' variable (" (report-current-time >= deliberation-finished-time) ")") 
     (who)
     if(report-current-time >= deliberation-finished-time)[
       output-debug-message (word "I should attempt to schedule/execute my next action...") (who)
       schedule-or-execute-next-episode-actions
     ]
           
     ;=================================;
     ;== LEARN FROM EXECUTED ACTIONS ==;
     ;=================================;
     
     output-debug-message (word 
       "Checking if my 'learn-from-episodic-memory?' variable is set to true (" learn-from-episodic-memory? "). "
       "If so, I'll attempt to learn from the current state of my 'episodic-memory'"
     ) (who)
     if(learn-from-episodic-memory? and chrest:is-attention-free? (report-current-time))[
         learn-from-episodic-memory
     ]
     
     ;===========================;
     ;== REINFORCE PRODUCTIONS ==;
     ;===========================;
     
     output-debug-message (word 
       "If I should reinforce productions (" reinforce-productions? ") and my "
       "'reinforcement-learning-theory' turtle variable is not an empty string "
       "(current value: '" reinforcement-learning-theory "'), I'll attempt to " 
       "reinforce my productions"
     ) (who)
     if(
       reinforce-productions? and 
       not empty? reinforcement-learning-theory and
       chrest:is-attention-free? (report-current-time)
     )[
       reinforce-productions
     ]
     
     ;==================;
     ;== UPDATE PLOTS ==;
     ;==================;
     
     output-debug-message ("Updating my plots...") (who)
     update-plot-no-x-axis-value ("Scores") (score)
     update-plot-no-x-axis-value ("Time spent deliberating") (time-spent-deliberating)
     update-plot-no-x-axis-value ("Production Count") (chrest:get-production-count (report-current-time))
     update-plot-with-x-axis-value ("Problem-Solving Frequency") (who) (frequency-of-problem-solving)
     update-plot-with-x-axis-value ("Pattern-Recognition Frequency") (who) (frequency-of-pattern-recognitions)
     update-plot-no-x-axis-value ("Visual STM Node Count") (chrest:Stm.get-count (chrest:Modality.value-of("VISUAL")) (report-current-time))
     update-plot-no-x-axis-value ("Visual LTM Size") (chrest:get-ltm-modality-size (chrest:Modality.value-of("VISUAL")) (report-current-time))
     update-plot-no-x-axis-value ("Visual LTM Avg. Depth")(chrest:get-ltm-avg-depth (chrest:Modality.value-of("VISUAL")) (report-current-time))
     update-plot-no-x-axis-value ("Action STM Node Count") (chrest:Stm.get-count (chrest:Modality.value-of("ACTION")) (report-current-time))
     update-plot-no-x-axis-value ("Action LTM Size") (chrest:get-ltm-modality-size (chrest:Modality.value-of("ACTION")) (report-current-time))
     update-plot-no-x-axis-value ("Action LTM Avg. Depth")(chrest:get-ltm-avg-depth (chrest:Modality.value-of("ACTION")) (report-current-time))
   ]
  ]
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
        set heading (0)
        set time-created (report-current-time)
        set lifespan (tile-lifespan)
        set color (yellow)
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
        set heading (0)
        set time-created (report-current-time)
        set lifespan (hole-lifespan)
        set color (blue)
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
;By default, all turtles can use problem-solving.  Essentially, problem-solving proceeds as 
;follows:
; 
; 1. If any tiles have been "seen" by the turtle, invoke the "generate-action-when-tile-can-be-seen"
;    procedure.
; 2. If no tiles have been "seen by the turtle, move randomly. 
;
;Since the "generate-action-when-tile-can-be-seen" procedure is used, each turtle breed needs to
;prepare a data structure containing tiles it has seen appropriately.
;
;Breed specific deliberation:
;
; 1. CHREST turtles
;    - Pattern-recognition will be attempted before problem-solving.  If the CHREST turtle can't use
;      pattern-recognition or no action is returned after using pattern-recognition, problem-solving 
;      will be used instead.  To use pattern-recognition, the visual STM of a CHREST turtle needs to 
;      contain Nodes that have productions at the current time this procedure is invoked.
;    - To prepare the data structure used to problem-solve, CHREST turtles will first attempt to 
;      extract the location of any tiles present in the contents, image and filled slots of its visual 
;      STM hypothesis at the time this procedure is invoked in the model.  If there is no visual STM
;      hypothesis for the calling turtle, the squares Fixated on in the turtle's last Fixation performed
;      are searched for tiles.
;
;         Name          Data Type            Description
;         ----          ---------            -----------
;@return  -             Number               The time taken to deliberate.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk> 
to-report deliberate
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'deliberate' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  output-debug-message ("Creating four local variables: 'action', 'time-taken-to-deliberate', 'used-pattern-recognition' and 'patches-looked-at'...") (who)
  output-debug-message ("The 'action' variable will be populated with a 3 element list representing the action decided upon, the heading I should adopt when performing the action and how many patches the object to be actioned should be shifted along the heading specified...") (who) 
  output-debug-message ("The 'time-taken-to-deliberate' variable will store the length of time taken to deliberate...") (who)
  output-debug-message ("The 'used-pattern-recognition' variable controls whether problem-solving will be used (if set to false then problem-solving will be used).  Should only be set to true if I'm a CHREST turtle and I select an action using pattern-recogniition. Setting value to 'false' since this is a fresh deliberation...") (who)
  output-debug-message ("The 'patches-looked-at' variable will store what patches are looked at for problem-solving.  Should contain values representing the number of patches along the x and y axis that the patch looked at is from the deliberating turtle...") (who)
  
  let time-taken-to-deliberate (0)
  let used-pattern-recognition? (false)
  let patches-seen-with-tiles-on []
  
  let vision []
  let action []
  
  ;===================================;
  ;== CHECK BREED OF CALLING TURTLE ==;
  ;===================================;
  
  output-debug-message ("Checking my breed to deliberate accordingly") (who)
  
  if(breed = chrest-turtles)[
    output-debug-message ("I am a chrest-turtle so I will deliberate accordingly") (who)
    
    ;=========================;
    ;== PATTERN RECOGNITION ==;
    ;=========================;
    
    output-debug-message (word "Checking if I can use pattern-recognition to select an action to perform (" can-use-pattern-recognition? ")") (who)
    if(can-use-pattern-recognition? and (random-float 1.0 > probability-of-using-problem-solving) )[
      output-debug-message (word "My 'can-use-pattern-recognition?' variable is set to 'true' and I shouldn't use problem-solving so I'll use visual pattern-recognition to select an action to perform") (who)
      
      let production-selected (chrest:generate-action-using-visual-pattern-recognition (report-current-time))
      ifelse( not empty? production-selected )[
        
        set used-pattern-recognition? (true)
        set vision (chrest:Node.get-contents (item (0) (production-selected)))
        set action (chrest:Node.get-contents (item (1) (production-selected)))
        
        output-debug-message (word 
          "A production has been selected.  Vision: " (chrest:ListPattern.get-as-string (vision))
          ", action: " (chrest:ListPattern.get-as-string (action))
        ) (who)
        
        output-debug-message (word "Since I generated an action using pattern recognition, I will increment my 'frequency-of-pattern-recognitions' variable (" frequency-of-pattern-recognitions ") by 1...") (who)
        set frequency-of-pattern-recognitions (frequency-of-pattern-recognitions + 1)
        output-debug-message (word "My 'frequency-of-pattern-recognitions' variable is now equal to: " frequency-of-pattern-recognitions "...") (who)
      ]
      [
        output-debug-message (word "Pattern-recognition didn't yield an action") (who)
      ]
    ]
    
    ;===============================================;
    ;== PREPARE INFO REQUIRED FOR PROBLEM-SOLVING ==;
    ;===============================================;
    
    ;Need to generate a list of lists.  Each inner list should contain the
    ;location of a tile fixated on using coordinates relative to the current
    ;location of the calling turtle.  To generate this, two methods may be
    ;used:
    ;
    ; 1. If a visual STM hypothesis is present and is not the visual LTM root
    ;    Node, use the information in its contents, image and filled slots.
    ;
    ;    NOTE: There is a major assumption here, namely that the CHREST turtle 
    ;          has not moved since the hypothesis was added to visual STM.  If
    ;          this is not the case, the relative locations in the hypothesis' 
    ;          information will have changed and will no longer be applicable.
    ;
    ; 2. If there is no visual STM hypothesis, try to use the information in 
    ;    the last Fixation performed
    if(not used-pattern-recognition?)[
      output-debug-message (word "I didn't generate an action using pattern-recognition so I'll use problem-solving instead...") (who)
      
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;; 1. Use information in visual STM hypothesis ;;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      
      output-debug-message ("Getting my visual STM hypothesis to decide on what to do.") (who)

      let visual-stm-hypothesis (chrest:get-stm-item (chrest:Modality.value-of("VISUAL")) (1) (report-current-time))
      ifelse(not is-string? visual-stm-hypothesis)[
        output-debug-message (word "Reference of Node in visual STM hypothesis position: " chrest:Node.get-reference (visual-stm-hypothesis)) (who)

        set vision (chrest:Node.get-all-information (visual-stm-hypothesis) (report-current-time))
        output-debug-message("Getting tile locations from its contents/image/filled-slots") (who)
        let visual-stm-hypothesis-items (chrest:ListPattern.get-as-netlogo-list (vision))
        
        ;Extract tile locations relative to agent.
        foreach(visual-stm-hypothesis-items)[
          output-debug-message (word "Checking if visual STM hypothesis ItemSquarePattern " chrest:ItemSquarePattern.get-as-string (?) " indicates a tile") (who)
          if(chrest:ItemSquarePattern.get-item (?) = tile-token)[
            
            let location-of-tile (list (chrest:ItemSquarePattern.get-column (?)) (chrest:ItemSquarePattern.get-row (?))) 
            output-debug-message (word 
              "Visual STM hypothesis ItemSquarePattern does indicate a tile, adding ItemSquarePattern column and row to the "
              "'patches-seen-with-tiles-on' variable if not already present (current contents:" patches-seen-with-tiles-on ")"
            ) (who)
            
            if(not member? (location-of-tile) (patches-seen-with-tiles-on))[
              output-debug-message("ItemSquarePattern column and row not present in 'patches-seen-with-tiles-on' currently, adding them") (who)
              set patches-seen-with-tiles-on (lput (location-of-tile) (patches-seen-with-tiles-on))
            ]
          ]
        ]
      ]
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      ;;; 2. Use information in last Fixation performed ;;;
      ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      [
      
        output-debug-message ("Can't get visual STM hypothesis so I'll decide what to do based on my Fixations") (who)
        
        let fixations-performed (chrest:Perceiver.get-fixations-performed (report-current-time))
        ifelse(not empty? fixations-performed)[
          output-debug-message ("I have performed some Fixations so I'll see if I saw a tile when the last one was performed") (who)

          let last-fixation-performed (chrest:get-fixation-performed (1) (report-current-time))
          ifelse(not is-string? last-fixation-performed)[
            output-debug-message (word "Last Fixation performed: " chrest:Fixation.to-string (last-fixation-performed)) (who)
            
            set vision (chrest:Perceiver.get-objects-seen-in-fixation-field-of-view (last-fixation-performed) (true))
            let non-empty-squares-fixated-on (chrest:ListPattern.get-as-netlogo-list (vision))
            output-debug-message (word "Non-empty squares fixated on: " map ([chrest:ItemSquarePattern.get-as-string (?)]) (non-empty-squares-fixated-on)) (who)
            
            foreach(non-empty-squares-fixated-on)[ 
              if( (chrest:ItemSquarePattern.get-item (?)) = tile-token )[
                
                ;The column and row values of the ItemSquarePattern returned by 
                ;"chrest:Perceiver.get-objects-seen-in-fixation-field-of-view"
                ;will be relative to the location of the calling turtle when the
                ;Fixation being processed was generated so the column and row can
                ;just be extracted with no other processing here.
                let location-of-tile (list 
                  (chrest:ItemSquarePattern.get-column (?))
                  (chrest:ItemSquarePattern.get-row (?))
                  )
                output-debug-message (word "A tile was seen " location-of-tile " from me, adding this to my 'patches-seen-with-tiles-on' variable") (who)
                set patches-seen-with-tiles-on (lput (location-of-tile) (patches-seen-with-tiles-on))
              ]
            ]
          ]
          [
            output-debug-message ("Can't get the last Fixation performed") (who)
          ]
        ]
        [
          output-debug-message ("I have not performed any Fixations") ("who")
        ]
      ]
    ]
  ];chrest-turtle breed check
  
  ;=====================;
  ;== PROBLEM-SOLVING ==;
  ;=====================;
  
  if(not used-pattern-recognition?)[
    output-debug-message ("Using problem-solving to deliberate...") (who)
    output-debug-message (word "Checking to see if I've seen any tiles (" not empty? patches-seen-with-tiles-on ")") (who)
    
    ;====================;
    ;== WHEN TILE SEEN ==;
    ;====================;
    ifelse( not empty? patches-seen-with-tiles-on )[
      
      output-debug-message (word 
        "Since I saw one or more tiles, I'll select one of the patches I fixated on that "
        "contains a tile to generate an action in context of"
      ) (who)
      let patch-with-tile-on (one-of (patches-seen-with-tiles-on))
      output-debug-message (word "I selected the following patch: " patch-with-tile-on) (who)
      
      set action ( generate-action-when-tile-can-be-seen (item (0) (patch-with-tile-on)) (item (1) (patch-with-tile-on)) )
      
      ifelse(breed = chrest-turtles)[
        output-debug-message (word 
          "Since I'm a CHREST-turtle, I'll advance my attention clock by my "
          "'time-to-generate-action-when-tile-seen' variable"
        ) (who)
        chrest:advance-attention-clock (time-to-generate-action-when-tile-seen)
        output-debug-message (word "My attention clock is now equal to " chrest:get-attention-clock) (who)
      ]
      [
        output-debug-message (word 
          "Incrementing the local 'time-taken-to-deliberate' variable (" time-taken-to-deliberate ") "
          "by my 'time-to-generate-action-when-tile-seen' (" time-to-generate-action-when-tile-seen ") "
          "variable"
          ) (who)
        set time-taken-to-deliberate (time-taken-to-deliberate + time-to-generate-action-when-tile-seen)
        output-debug-message (word "My 'time-taken-to-deliberate' variable is now equal to: " time-taken-to-deliberate "...") (who)
      ]
    ]
    ;========================;
    ;== WHEN TILE NOT SEEN ==;
    ;========================;
    [
      output-debug-message ("I didn't see any tiles, I'll try to select a random heading to move 1 patch forward along...") (who)
      set action ( list (move-token) (one-of (movement-headings)) (1) )
      
      ifelse(breed = chrest-turtles)[
        output-debug-message (word 
          "Since I'm a CHREST-turtle, I'll advance my attention clock by my "
          "'time-to-generate-action-when-no-tile-seen' variable"
        ) (who)
        chrest:advance-attention-clock (time-to-generate-action-when-no-tile-seen)
        output-debug-message (word "My attention clock is now equal to " chrest:get-attention-clock) (who)
      ]
      [
        output-debug-message (word 
          "Incrementing the local 'time-taken-to-deliberate' variable (" time-taken-to-deliberate ") "
          "by my 'time-to-generate-action-when-no-tile-seen' (" time-to-generate-action-when-no-tile-seen ") "
          "variable"
          ) (who)
        set time-taken-to-deliberate (time-taken-to-deliberate + time-to-generate-action-when-no-tile-seen)
        output-debug-message (word "My 'time-taken-to-deliberate' variable is now equal to: " time-taken-to-deliberate "...") (who)
      ]
    ]
    
    output-debug-message (word "Since I am generating an action using problem-solving, I will increment my 'frequency-of-problem-solving' variable (" frequency-of-problem-solving ") by 1...") (who)
    set frequency-of-problem-solving (frequency-of-problem-solving + 1)
    output-debug-message (word "My 'frequency-of-problem-solving' variable is now equal to: " frequency-of-problem-solving "...") (who)
  ]
  
  ;====================================;
  ;== ADD EPISODE TO EPISODIC-MEMORY ==;
  ;====================================;
  
  output-debug-message ("Adding episode to episodic-memory. Need to set episode action/vision and time created first.") (who)
  let episode-vision []
  let episode-action []
  let time-episode-created ""
  
  ;== CONVERT VISION EPISODIC-MEMORY ACCORDING TO BREED ==;
  
  output-debug-message ("Setting 'episode-vision'") (who)
  
  if(breed = chrest-turtles)[
    output-debug-message (word 
      "I'm a CHREST turtle so I need to check if 'vision' is a Netlogo "
      "list. Since my episodes should be composed of jchrest.lib.ListPatterns, "
      "if 'vision' is a list, it will need to be converted (is 'action' a "
      "Netlogo list: " is-list? vision ")" 
      ) (who)
    
    ifelse(is-list? vision)[
      output-debug-message ("The 'vision' is a Netlogo list, converting to a jchrest.lib.ListPattern") (who)
      set episode-vision (chrest:ListPattern.new 
        (vision)
        (chrest:Modality.value-of ("VISUAL"))
        )
    ]
    [
      output-debug-message (word 
        "The 'vision' is not a Netlogo list so it must be a jchrest.lib.ListPattern. Setting it to "
        "'episode-vision' as it is"
        ) (who)
      
      set episode-vision (vision)
    ]
    
;    chrest:ListPattern.set-finished (episode-vision)
    output-debug-message (word "The 'episode-vision' is now set to: " chrest:ListPattern.get-as-string (episode-vision)) (who)
  ]
  
  ;== CONVERT ACTION FOR EPISODIC-MEMORY ACCORDING TO BREED ==;
  
  output-debug-message("Setting 'episode-action'") (who)
  
  ;For CHREST turtles, the 'episode-action' may need to be converted
  ;if it is a list (indicative of problem-solving).  The conversion
  ;should be to a jchrest.lib.ListPattern.
  if(breed = chrest-turtles)[
    output-debug-message (word 
      "I'm a CHREST turtle so I need to check if 'action' was generated"
      "using problem-solving.  If so, it'll be a Netlogo list and my "
      "episodes should be composed of jchrest.lib.ListPatterns so will "
      "need to be converted (is 'action' a Netlogo list: " is-list? action ")" 
    ) (who)
    
    ifelse(is-list? action)[
      output-debug-message ("The 'action' is a Netlogo list, converting to a jchrest.lib.ListPattern") (who)
      set episode-action (chrest:ListPattern.new 
        (list 
          chrest:ItemSquarePattern.new 
          (item (0) (action))
          (item (1) (action))
          (item (2) (action)) 
          )
        (chrest:Modality.value-of ("ACTION"))
      )
    ]
    [
      output-debug-message (word 
        "The 'action' is not a Netlogo list so it must be a jchrest.lib.ListPattern. Setting it to "
        "'episodic-action' as it is"
      ) (who)
      
      set episode-action (action)
    ]
    
;    chrest:ListPattern.set-finished (episode-action)
    output-debug-message (word "The 'episode-action' is now set to: " chrest:ListPattern.get-as-string (episode-action)) (who)
  ]
  
  ;== SET TIME EPISODE CREATED ==;
  
  output-debug-message ("Setting the time the episode was created") (who)
  ifelse(breed = chrest-turtles)[
    output-debug-message (word "Since I'm a CHREST turtle, this will be set to the time my attention is free") (who)
    set time-episode-created (chrest:get-attention-clock)
  ]
  [
    output-debug-message (word 
      "Setting this to the current time (" report-current-time ") + the local "
      "'time-taken-to-deliberate' variable (" time-taken-to-deliberate ")"
    ) (who)
    set time-episode-created (report-current-time + time-taken-to-deliberate)
  ]
  
  output-debug-message (word 
    "Adding 'episode-vision' (" episode-vision "), 'episode-action' (" episode-action ") " 
    "and 'time-episode-created' (" time-episode-created ") to my 'episodic-memory'"
  ) (who)
  
  add-episode-to-episodic-memory (episode-vision) (episode-action) (time-episode-created)
  
  ;============;
  ;== REPORT ==;
  ;============;
  
  output-debug-message (word "Reporting the time-taken to decide upon this action (" time-taken-to-deliberate ")") (who)
  set debug-indent-level (debug-indent-level - 2)
  report time-taken-to-deliberate
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "SCHEDULE-OR-EXECUTE-NEXT-EPISODE-ACTIONS" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Schedules/executes the next action(s) to be performed by the calling turtle.
;
;An episode's actions will be scheduled for execution if the turtle's 
;'actions-to-perform' list is empty and an episode's 'performed' status is 
;set to 'false'.  Actions are scheduled according to the time taken to 
;perform them.  Since there are only two actions that can be performed ('move' 
;and 'push-tile') the time an action is scheduled for performance is based 
;upon the current time, the number of actions to be performed in the episode 
;and the types of actions, i.e. the values of the turtle's 'time-taken-to-move'
;and 'time-taken-to-push-tiles' variables.  So, if this procedure is invoked by
;a turtle at time 0, the turtle's 'actions-to-perform' list is empty and the 
;next unperformed episode in the turtle's 'episodic-memory' is the second 
;episode and has 2 actions to perform: 'move' and 'push-tile', the 
;'actions-to-perform' list will be set to the following (not exactly since the
;key:value parings will not explictly exist, just the values):
;
;[
;  [
;    episode-index: 1 (episodic-memory is zero-indexed)
;    action: move
;    performance-time: 0 + 'time-taken-to-move'
;    performed: false
;  ]
;  [
;    episode-index: 1 (episodic-memory is zero-indexed)
;    action: push-tile
;    performance-time: 0 + 'time-taken-to-move' + 'time-taken-to-push-tile'
;    performed: false
;  ]
;]
;
;If the turtle's 'actions-to-perform' list is not empty, the next action in 
;the turtle's 'actions-to-perform' list whose 'performed' status is set to
;'false' will be attempted.  The attempt will only be made if the action's
;'execution-time' is equal to the current time.  If all of these conditions
;hold, four scenarios can occur and this procedure handles each one accordingly:
;
; - Scenario 1
;   ~ Action performed successfully, hole not filled, actions still scheduled 
;     to be performed in episode.
;     + Action's 'performed' status set to 'true'
;
; - Scenario 2
;   ~ Action performed successfully, hole not filled, no actions scheduled to 
;     be performed in episode.
;     + Episode's performance time set to the time this action was performed.
;     + Turtle's 'actions-to-perform' data structure cleared.
;     + The action's 'performance' status will be set to 'true' but, since the 
;       turtle's 'actions-to-perform' status is reset, this modification will 
;       have no effect.
;
; - Scenario 3
;   ~ Action performed successfully, hole filled.
;     + Episode's performance time set to the time this action was performed.
;     + Turtle's 'actions-to-perform' data structure cleared.
;     + Any episodes following this episode in 'episodic-memory' are cleared.
;     + The action's 'performance' status will be set to 'true' but, since the 
;       turtle's 'actions-to-perform' status is reset, this modification will 
;       have no effect.
;     + If the turtle is a CHREST turtle, its 'reinforce-productions' switch 
;       will be turned on, its 'episode-to-reinforce' variable will be set to
;       the most recent episode and its 'time-last-hole-filled' variable will
;       be set to the current time. 
;
; - Scenario 4
;   ~ Action not performed successfully.
;     + Turtle's 'actions-to-perform' data structure cleared.
;     + Any episodes following this episode in 'episodic-memory' are cleared.
;
;Finally, if an action is performed, the procedure will check to see if all 
;the actions in all the calling turtle's episodes have now been performed.  If
;this is the case, the calling turtle's 'execute-actions' switch is turned off.
;If the turtle is a CHREST turtle, its 'fixate-on-reality' switch will also be
;turned on so that it can begin a new planning cycle.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
to schedule-or-execute-next-episode-actions
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'schedule-or-execute-next-episode-actions' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  output-debug-message (word 
    "Checking if my 'execute-actions?' variable is set to 'true'.  If so, I'll attempt to "
    "schedule/execute the next action to perform otherwise, I won't"
  ) (who)
  ifelse(execute-actions?)[
  
    output-debug-message (word "Checking the contents of my 'actions-to-perform' turtle variable (current contents: " actions-to-perform ")") (who)
    
    ;==========================================;
    ;== SCHEDULE NEXT EPISODIC MEMORY ACTION ==;
    ;==========================================;
    
    ;Do this if the turtle's 'actions-to-perform' data structure
    ;is empty.
    if(empty? actions-to-perform)[
      output-debug-message ("My 'actions-to-perform' turtle variable is empty so I'll schedule the actions in my next unperformed episode.") (who)
      
      ;Need to keep track of the episode index so its performance
      ;time can be set later.
      let episode-index (0)
      while[not empty? episodic-memory and episode-index < length episodic-memory][
        let episode (item (episode-index) (episodic-memory))
        
        ;If the episode's performance time has not been set,
        ;schedule its actions for performance.  No need to
        ;worry if the episode's actions are being performed
        ;and this loop being run since the 'actions-to-perform'
        ;data structure needs to be empty for program control
        ;to get to here and this block of code populates that
        ;structure.
        ifelse(item (3) (episode) = -1)[
          
          ;Get the episode's actions.  Assume that this is a list but
          ;check if it is a jchrest.lib.ListPattern.  If it is, it needs
          ;to be converted to a list so the actions can be scheduled 
          ;correctly.
          let episodic-memory-actions (item (1) (episode))
          if(java:Class.get-canonical-name (episodic-memory-actions) = "jchrest.lib.ListPattern")[
            set episodic-memory-actions (chrest:ListPattern.get-as-netlogo-list (episodic-memory-actions))
          ]
          
          ;Process each episode's action.  First, initialise a variable
          ;that will keep track of the performance time for each action
          ;in the sequence.  This will be initialised with the current 
          ;time and will be incremented for each action in the sequence
          ;accordingly.
          let time-to-perform-action (report-current-time)
          foreach(episodic-memory-actions)[
            let episodic-memory-action (?)
            
            ;Assume that the action is a list but check for other
            ;data types.  If its a jchrest.lib.ItemSquarePattern,
            ;convert it into a list for the "perform-action" 
            ;procedure.
            if(java:Class.get-canonical-name (episodic-memory-action) = "jchrest.lib.ItemSquarePattern")[
              set episodic-memory-action (list 
                chrest:ItemSquarePattern.get-item (episodic-memory-action)
                chrest:ItemSquarePattern.get-column (episodic-memory-action)
                chrest:ItemSquarePattern.get-row (episodic-memory-action)
                )
            ]
            
            ;Set the time that the action should be performed.
            let action-performance-time (0)
            let action (item (0) (episodic-memory-action))
            
            if(action = move-token)[
              set action-performance-time (time-taken-to-move)
            ]
            
            if(action = push-tile-token)[
              set action-performance-time (time-taken-to-push-tile)
            ]
            
            set time-to-perform-action (time-to-perform-action + action-performance-time) 
            
            ;Create an entry for the 'actions-to-perform' data structure.  
            ;This should be a list with three elements:
            ;
            ; - Element 1: The episode's index (so the episode's performance 
            ;              time can be set later when all of its actions have 
            ;              been performed).
            ; - Element 2: The action to perform.
            ; - Element 3: The time the action should be performed.
            ; - Element 4: Has the action been performed.
            let action-to-perform-entry (list
              episode-index 
              episodic-memory-action
              time-to-perform-action
              false
            )
            
            set actions-to-perform  (lput (action-to-perform-entry) (actions-to-perform))
          ]
          
          ;Stop the while loop.
          set episode-index (length episodic-memory)
        ]
        [
          set episode-index (episode-index + 1)
        ]
      ]
    ]
    
    ;==============================================;
    ;== ATTEMPT TO PERFORM NEXT SCHEDULED ACTION ==;
    ;==============================================;

    output-debug-message (word "Attempting to perform the next action in my 'actions-to-perform' turtle variable") (who)
      
    let action-to-perform-index (0)
    let action-to-perform [] 
    while[action-to-perform-index < length actions-to-perform and empty? action-to-perform][
      let action-to-maybe-perform (item (action-to-perform-index) (actions-to-perform))
      
      output-debug-message (word 
        "Checking if " action-to-maybe-perform " is to be performed now, i.e. has it not been "
        "performed yet (" ((item (3) (action-to-maybe-perform)) = false) ") and is its "
        "performance time (" (item (2) (action-to-maybe-perform)) ") equal to the current time (" 
        report-current-time ")"
      ) (who)
      
      ;If the episode hasn't been performed yet, and it should be performed now, 
      ;set it for performance, this will cause the while loop to end and the 
      ;action to perform index will be set so that it can be used later in the 
      ;procedure.
      ifelse( 
        ((item (2) (action-to-maybe-perform)) = report-current-time) and 
        ((item (3) (action-to-maybe-perform)) = false)
      )[
        output-debug-message ("Action should be performed so it will be") (who)
        set action-to-perform (action-to-maybe-perform)
        
        output-debug-message (word 
          "Checking if this is the first action in the first planned episode ("
          (action-to-perform-index = 0 and (item (0) (action-to-perform)) = 0) "). "
          "If so, my 'heading-when-plan-execution-begins' turtle variable will "
          "be set"
        ) (who)
        
        if((action-to-perform-index = 0) and ((item (0) (action-to-perform)) = 0))[
          output-debug-message (word 
            "This is the first action of the first episode so my "
            "'heading-when-plan-execution-begins' will be set to my "
            "current heading (" heading ")"
          ) (who)
          set heading-when-plan-execution-begins (heading)
        ]
      ]
      [
        set action-to-perform-index (action-to-perform-index + 1)
      ]
    ]
      
    ;===================================;
    ;== PERFORM NEXT SCHEDULED ACTION ==;
    ;===================================;
    
    ifelse(not empty? action-to-perform)[
      output-debug-message (word "Performing action: " action-to-perform) (who)
      let action-performance-result ( perform-action (item (1) (action-to-perform)) )
      output-debug-message (word "Action performance result: " action-performance-result) (who)
      
      output-debug-message ( word "Checking if the action was performed successfully" ) (who)
      let action-performed-successfully? (ifelse-value (is-list? (action-performance-result)) 
        [item (0) (action-performance-result)] 
        [action-performance-result]
      )
      
      ;Set variables that will be used to alter the episode's actions and 
      ;episodes generally depending on the outcome of the action.
      let clear-actions-to-perform? (false)
      let clear-subsequent-episode-actions-and-episodes? (false)
      let action-to-keep-up-to-in-episode (action-to-perform-index)
        
      ;===================================;
      ;== ACTION PERFORMANCE SUCCESSFUL ==;
      ;===================================;
      ifelse(action-performed-successfully?)[
        
        output-debug-message ( word "The action was performed successfully.") (who)
        output-debug-message ("Setting this action's 'performed' status to true") (who)
        set action-to-perform (replace-item (3) (action-to-perform) (true))
        set actions-to-perform (replace-item (action-to-perform-index) (actions-to-perform) (action-to-perform))
        
        output-debug-message ("Setting the episode's performance time to the current time") (who)
        let episode-index (item (0) (action-to-perform))
        let episode (item (episode-index) (episodic-memory))
        set episode (replace-item (3) (episode) (report-current-time))
        set episodic-memory (replace-item (episode-index) (episodic-memory) (episode)) 
        
        ;=========================;
        ;== CHECK FOR HOLE-FILL ==;
        ;=========================;
          
        ;The action may have caused a tile to be pushed into a hole. If this is the case,
        ;and the turtle is a CHREST turtle, the turtle should turn on production reinforcement,
        ;set the episode to start reinforcement on to be this episode (the most recent), save
        ;the time the hole was filled (the current time) and turn on its 'fixate-on-reality' 
        ;switch so that it starts a new planning cycle.
        ;
        ;It may be that this was expected (the last action in the last episode of a plan) or
        ;unexpected (due to the stochastity of Tileworld).  In either case, the current episode's
        ;performance time will be set and all subsequent actions in this episode and all episodes
        ;subsequent to this episode will be removed (if this is the last action of the last episode,
        ;there will be no effect).
        output-debug-message ("Checking to see if I just filled a hole.") (who)
        ifelse( is-list? (action-performance-result) and (item (1) (action-performance-result)) )[
          output-debug-message (word "I just filled a hole") (who)
          
          if(breed = chrest-turtles)[
            set reinforce-productions? (true)
            set episode-to-reinforce (item (0) (action-to-perform))
            set time-last-hole-filled (report-current-time)
            
            output-debug-message (word 
              "Since I am a CHREST turtle, my 'reinforce-productions?' turtle variable "
              "is now set to '" reinforce-productions? "', my 'time-last-hole-filled' "
              "turtle variable is set to '" time-last-hole-filled "', and my "
              "'episode-to-reinforce' variable is set to '" episode-to-reinforce "'"
              ) (who)
          ]
          
          set clear-actions-to-perform? (true)
          set clear-subsequent-episode-actions-and-episodes? (true)
        ]
        ;==================;
        ;== NO HOLE FILL ==;
        ;==================;
        [
          output-debug-message ("No hole was filled") (who)
          
          ;Check if all episode actions have now been performed.
          let all-actions-in-episode-performed (true)
          foreach(actions-to-perform)[
            if(item (3) (?) = false)[
              set all-actions-in-episode-performed (false)
            ]
          ]
          
          ifelse(all-actions-in-episode-performed)[
            output-debug-message ("All of the episode's actions have now been performed.") (who)
            set clear-actions-to-perform? (true)
          ]
          [
            output-debug-message ("Not all of the episode's actions have been performed.") (who)
          ]
        ]
      ]
      ;=====================================;
      ;== ACTION PERFORMANCE UNSUCCESSFUL ==;
      ;=====================================;
      [
        output-debug-message ( word "The action was not performed successfully.") (who)
        set clear-actions-to-perform? (true)
        set clear-subsequent-episode-actions-and-episodes? (true)
        set action-to-keep-up-to-in-episode (action-to-perform-index - 1)
      ]
        
      ;==============;
      ;== CLEAN-UP ==;
      ;==============;
      
      if(clear-actions-to-perform?)[ 
        output-debug-message ("Clearing my 'actions-to-perform' data structure") (who)
        set actions-to-perform [] 
      ]
        
      if(clear-subsequent-episode-actions-and-episodes?)[
        output-debug-message ("Clearing subsequent actions in this episode and subsequent episodes in my 'episodic-memory'") (who)
        output-debug-message (word "My episodic-memory is set to the following before starting: " (map 
          ([( list
            chrest:ListPattern.get-as-string (item (0) (?))
            chrest:ListPattern.get-as-string (item (1) (?))
            (item (2) (?))
            (item (3) (?))
          )]) 
          (episodic-memory)
        )) (who)
          
        let episode-index (item (0) (action-to-perform))
        let episode-to-remove-until (episode-index)
            
        output-debug-message (word 
          "Checking if this is the first action in the episode, i.e. is the local 'action-to-perform-index' "
          "variable (" action-to-perform-index ") equal to 0. If so, the whole episode will be removed from "
          "episodic-memory"
        ) (who)
            
        ifelse(action-to-perform-index = 0 and not action-performed-successfully?)[
          output-debug-message ("This is the first action in the episode and it was unsuccessful, removing the episode from episodic memory") (who)
          set episodic-memory (remove-item (episode-to-remove-until) (episodic-memory))
          ;Leave 'episode-to-remove-until' alone since this will now equal the episode that came after the
          ;one just removed.  Thus, this episode will be removed by the while loop below.
        ]
        [
          output-debug-message (word 
            "Either, this isn't the first action in the episode or it is but it was performed successfully. "
            "Removing all subsequent actions from the episode"
          ) (who)
            
          ;Get the episode's actions (if its a jchrest.lib.ListPattern it
          ;needs to be turned into a list).
          let episode (item (episode-index) (episodic-memory))
          let episode-actions (item (1) (episode))
          if(java:Class.get-canonical-name (episode-actions) = "jchrest.lib.ListPattern")[
            set episode-actions (chrest:ListPattern.get-as-netlogo-list (episode-actions))
          ]
            
          ;Keep all actions up until this one in the episode, discard the rest.
          ;Convert the actions back into their original form.
          let actions-to-keep []
          let action-to-process-index (0)
          while[action-to-process-index <= action-to-keep-up-to-in-episode][
            set actions-to-keep (lput (item (action-to-process-index) (episode-actions)) (actions-to-keep))
            set action-to-process-index (action-to-process-index + 1)
          ]
            
          if(breed = chrest-turtles)[
            set actions-to-keep (chrest:ListPattern.new (actions-to-keep) (chrest:Modality.value-of ("ACTION")))
          ]
            
          ;Set the episode's actions to those performed and replace the episode in
          ;episodic memory.
          set episode (replace-item (1) (episode) (actions-to-keep))
          set episodic-memory (replace-item (episode-index) (episodic-memory) (episode))
          
          ;Want to keep this episode so remove episodes up until this one in episodic memory.
          set episode-to-remove-until (episode-to-remove-until + 1)
        ]
            
        output-debug-message (word "My episodic-memory is set to the following after removing actions from the episode but before removing episodes: " (map 
          ([( list
            chrest:ListPattern.get-as-string (item (0) (?))
            chrest:ListPattern.get-as-string (item (1) (?))
            (item (2) (?))
            (item (3) (?))
            )]) 
          (episodic-memory)
        )) (who)
            
        ;Remove episodes from episodic memory starting with the most recent, working
        ;backwards. When the episode to remove until has been removed, the while loop
        ;will stop.  So, if all episodes are to be removed (episode-to-remove-until = 0), 
        ;they will be since the loop will stop when episode-to-remove-until = -1. If episode
        ;0 is to be kept, episode-to-remove-until will be equal to 1 so every episode until
        ;index 0 is removed.
        let episode-to-remove (length episodic-memory - 1)
        while [episode-to-remove != episode-to-remove-until - 1][
          set episodic-memory (but-last episodic-memory)
          set episode-to-remove (episode-to-remove - 1)
        ]
          
        output-debug-message (word "My episodic-memory is set to the following after removing all episodes after the one whose action was unperformed successfully: " (map 
          ([( list
            chrest:ListPattern.get-as-string (item (0) (?))
            chrest:ListPattern.get-as-string (item (1) (?))
            (item (2) (?))
            (item (3) (?))
            )]) 
          (episodic-memory)
        )) (who)
      ];Clear subsequent actions and episodes
    ];Check on whether 'action-to-perform' is empty.
    [
      output-debug-message ("No action is to be performed now, exiting") (who)
    ]
    
    ;==========================================================;
    ;== CHECK IF THIS IS THE LAST ACTION IN THE LAST EPISODE ==;
    ;==========================================================;
    
    ;Now that the 'actions-to-perform' and 'episodic-memory' variables have been
    ;modified, check if this was the last action of the last episode, if so,
    ;set the 'end-action-execution-and-restart-planning?' variable to true.
    let end-action-execution-and-restart-planning? (false)
    if(not empty? action-to-perform)[
      
      ;Get the index of the episode that the action just performed belongs to.
      ;If this is less than the maximum index in 'episodic-memory', this is not
      ;the last action in the last episode so don't continue.
      let index-of-episode-that-action-belongs-to (item (0) (action-to-perform))
      if(index-of-episode-that-action-belongs-to >= (length (episodic-memory) - 1))[
      
        ;First, check if the episode index for the action just performed is still
        ;applicable.  If not, the episode must have just been removed so action
        ;execution should end and planning should restart.
        ifelse( index-of-episode-that-action-belongs-to > (length (episodic-memory) - 1) )[
          set end-action-execution-and-restart-planning? (true)
        ]
        ;If program control gets to here, the episode must be the last episode in episodic
        ;memory. To determine if all actions in the episode have now been performed, get 
        ;the number of actions in the episode itself and subtract 1 from it, this is the 
        ;maximum index in the episode's actions.  
        ;
        ;If the action just performed was successful and was the last action in the 
        ;episode, the 'action-to-perform-index' should equal the maximum index in 
        ;the episode's actions. Similarly, if the action just performed resulted in 
        ;a tile being unexpectedly pushed into a hole, all subsequent actions will 
        ;have been removed from the episode so the 'action-to-perform-index' would 
        ;again be equal to the maximum index in the episode's actions.
        ;
        ;If the action just performed was not successful, the 'action-to-perform-index'
        ;will be either equal to the number of actions in the episode (if this was the
        ;last action in the episode) or greater than the number of actions in the episode
        ;(if this was not the last action in the episode).
        ;
        ;Therefore, to cover all situations, check to see if the 'action-to-perform-index'
        ;is either greater than, or equal to, the number of actions in the episode.
        [
          let episode-actions (item (1) (item (index-of-episode-that-action-belongs-to) (episodic-memory)))
          let number-episode-actions (chrest:ListPattern.size (episode-actions))
          let maximum-action-index-in-episode (number-episode-actions - 1)
          
          if(action-to-perform-index >= maximum-action-index-in-episode)[
            set end-action-execution-and-restart-planning? (true)
          ]
        ]
      ]
    ]
        
    ;=============================================================;
    ;== END ACTION EXECUTION AND RESTART PLANNING, IF NECESSARY ==;
    ;=============================================================;
        
    output-debug-message (word 
      "Checking if action execution should end and planning should restart, i.e "
      "was an end plan generation and restart planning condition met when I "
      "performed my last action (" end-action-execution-and-restart-planning? ") "
      "or is my 'episodic-memory' empty since plan generation failed (" empty? 
      episodic-memory ")"
    ) (who)
    
    ifelse( (end-action-execution-and-restart-planning?) or (empty? episodic-memory) )[
      output-debug-message ( "Ending action execution and restarting planning") (who)
      
      set execute-actions? (false)
      
      if(breed = chrest-turtles)[
        output-debug-message ("Since I am a CHREST-turtle, I will fixate on reality again") (who)
        set fixate-on-reality? (true)
      ]
    ]
    [
      output-debug-message ("I will not end action execution and restart planning yet.") (who)
    ]
  ]
  [
    output-debug-message ("My 'execute-actions?' variable is set to false, exiting procedure") (who)
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
      set potential-actions (lput (list (move-token) (90) (1)) (potential-actions))
      set potential-actions (lput (list (move-token) (270) (1)) (potential-actions))
      set potential-actions (lput (list (push-tile-token) (0) (1)) (potential-actions))
    ]
    
    if(tile-xcor = 1 and tile-ycor = 0)[
      output-debug-message ("Tile is east of me so I could move north or south around it or push it east...") (who)
      set potential-actions (lput (list (move-token) (0) (1)) (potential-actions))
      set potential-actions (lput (list (move-token) (180) (1)) (potential-actions))
      set potential-actions (lput (list (push-tile-token) (90) (1)) (potential-actions))
    ]
    
    if(tile-xcor = 0 and tile-ycor = -1)[
      output-debug-message ("Tile is south of me so I could move east or west around it or push it south...") (who)
      set potential-actions (lput (list (move-token) (90) (1)) (potential-actions))
      set potential-actions (lput (list (move-token) (270) (1)) (potential-actions))
      set potential-actions (lput (list (push-tile-token) (180) (1)) (potential-actions))
    ]
    
    if(tile-xcor = -1 and tile-ycor = 0)[
      output-debug-message ("Tile is west of me so I could move north or south around it or push it west...") (who)
      set potential-actions (lput (list (move-token) (0) (1)) (potential-actions))
      set potential-actions (lput (list (move-token) (180) (1)) (potential-actions))
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
    
    set action (list (move-token) (one-of (potential-headings)) (1))
  ]
  
  output-debug-message (word "The action I'm going to perform is: " action) (who)
  set debug-indent-level (debug-indent-level - 2)
  report action
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "GENERATE-PLAN" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;CHREST-turtle only procedure, determines if plan generation should start, 
;continue or end.
;
;Plan generation should start when the turtle's 
;'time-visual-spatial-field-can-be-used-for-planning'
;variable is not set to its initial value, i,e. a visual-spatial field has
;been constructed, and is greater than the current model time, i.e. objects
;can be moved and the validity of actions can be ascertained to construct
;a sound plan.
;
;Plan generation should continue if the following are all true:
; 
; 1. Attention is free.
; 2. The turtle's maximum search iteration variable has not been reached.
; 3. The turtle's visual-spatial field avatar still exists on its 
;    visual-spatial field.
; 4. A tile that is the current focus of the turtle's attention (has been
;    pushed in the past) still exists as an object in the turtle's 
;    visual-spatial field.
;
;If any of the above statements evaluates to false, plan generation will end
;and action execution will begin.
;
;If the statements above all evaluate to true, a new action will be planned
;if the turtle is not supposed to be fixating on its visual-spatial field.
;
;NOTE: plan-generation is undertaken in a 3rd person perspective due to the 
;      way jchrest.architecture.VisualSpatialFields are constructed and used
;      rather than the more 1st person perspective nature of Tileworld 
;      operations. Essentially, this means that all actions created during
;      planning have headings relative to the heading of the CHREST turtle 
;      when planning begins, this has implications for performing actions later.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to generate-plan
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'generate-plan' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  if(breed = chrest-turtles)[
      
    ;=================================================;
    ;== CHECK FOR VISUAL-SPATIAL FIELD CONSTRUCTION ==;
    ;=================================================;
      
    output-debug-message (word  
      "If my 'generate-plan?' variable is set to true (value: " generate-plan? 
      ") and the current model time (" report-current-time ") is greater than "
      "or equal to my 'time-visual-spatial-field-can-be-used-for-planning' "
      "variable (" time-visual-spatial-field-can-be-used-for-planning "), I'll "
      "continue planning"
    ) (who)
    
    if(
      generate-plan? and 
      report-current-time >= time-visual-spatial-field-can-be-used-for-planning
    )[
      output-debug-message (word "I should continue planning") (who)
      
      ;===================================================;
      ;== RESET EPISODE VARIABLES IF THIS IS A NEW PLAN ==;
      ;===================================================;
      
      if(current-search-iteration = 0)[
        output-debug-message ("Since this is a new plan, I'll reset all variables concerned with episodes") (who)
        set episode-to-learn-from (0)
        set episode-to-reinforce (-1)
        set learn-action-sequence? (false)
        set learn-action-sequence-as-production? (false)
        set learn-episode-action? (true)
        set learn-episode-vision? (false)
        set learn-episode-as-production? (false)
        set learn-from-episodic-memory? (true)
        set reinforce-productions? (false)
        set episodic-memory ([])
        chrest:Stm.clear (chrest:Modality.value-of ("ACTION")) (report-current-time)
      ]
          
      ;================;
      ;== DELIBERATE ==;
      ;================;

      let ignore (deliberate)
      
      ;=====================================================;
      ;== GENERATE AND PERFORM VISUAL-SPATIAL FIELD MOVES ==;
      ;=====================================================;
      
      let most-recent-episode (last episodic-memory)
      let planned-actions (chrest:ListPattern.get-as-netlogo-list (item (1) (most-recent-episode)))
      let planned-action-index (0)
      let invalid-action-encountered (false)
      
      output-debug-message (word
        "Generating and performing visual-spatial field moves using the action(s) I decided upon "
        "until all moves are performed, one produces an invalid visual-spatial field state or my "
        "visual-spatial field avatar is not present on the visual-spatial field"
      ) (who)
      
      while[ 
        (planned-action-index < length planned-actions) and 
        (not invalid-action-encountered) and 
        not empty? (chrest:get-visual-spatial-field-object-locations (chrest:get-attention-clock) (word who) (false))
      ][
        let planned-action (item (planned-action-index) (planned-actions))
        output-debug-message (word "Planned action " planned-action-index " to perform: " chrest:ItemSquarePattern.get-as-string (planned-action)) (who)
        
        output-debug-message ( word 
          "Moving objects in the visual-spatial field.  The time at which this is done is equal to the current "
          "value of my CHREST model's attention clock (" chrest:get-attention-clock ") since attention will "
          "have been consumed deliberating. If this is not the first move in an action sequence, visual-spatial "
          "field object movement should still be performed at my CHREST model's attention clock value since a "
          "previous visual-spatial field move will have been performed and this will have consumed attention "
          "so this move should be performed afterwards"
        ) (who)
        chrest:move-visual-spatial-field-objects 
          (generate-visual-spatial-field-moves (planned-action) (false) (chrest:get-attention-clock)) 
          (chrest:get-attention-clock) 
          (ifelse-value (planned-action-index = 0) [true] [false])
        output-debug-message ( word "Completed moving objects in the visual-spatial-field") (who)
      
        ;=================================================================================================================;
        ;== CHECK THAT LAST ACTION PERFORMED IN VISUAL-SPATIAL FIELD CREATES A VALID VISUAL-SPATIAL FIELD CONFIGURATION ==;
        ;=================================================================================================================;
        
        output-debug-message (word 
          "I'll check that there are no illegal configurations of objects on my visual-spatial field "
          "as a result of the object move. If there are, the previous planned action must have caused "
          "this and thus, the planned action will be unsuccessful if performed in reality. Consequently, "
          "the move should be reversed in my visual-spatial field"
          ) (who)
        
        ;To check that the last planned action produces a valid visual-spatial field, the
        ;turtle needs to "cheat" and get the visual-spatial field at the time when the last 
        ;planned action has actually been performed, i.e the time the CHREST turtle's 
        ;attention clock is set to.
        let last-action-valid? (are-visual-spatial-field-squares-valid-at-time? (chrest:get-attention-clock))
      
        ;============================;
        ;== REVERSE INVALID ACTION ==;
        ;============================;
        
        ifelse(not last-action-valid?)[

          ;To reverse the move, we need to "cheat" and pass the current attention free time of the model 
          ;as a parameter to the "VisualSpatialField.move-objects" extension primitive so that the move 
          ;is actually reversed (using the current model time would result in the reversal not being 
          ;performed because attention would be consumed at this time as far as the turtle's CHREST 
          ;model is concerned).
          output-debug-message ("The last action planned produces an invalid visual-spatial field state so I should reverse the action..." ) (who)
          chrest:move-visual-spatial-field-objects 
            (generate-visual-spatial-field-moves (planned-action) (true) (chrest:get-attention-clock)) 
            (chrest:get-attention-clock)
            (false)
          output-debug-message ( word "Completed reversing the move in the visual-spatial-field...") (who)
          
          if(chrest:ItemSquarePattern.get-item (planned-action) = push-tile-token)[
            output-debug-message ( word 
              "The action just reversed was a 'push-tile' action so I'll reset my 'who-of-tile-last-pushed-in-plan'. "
              "This is because I shouldn't have pushed the tile and therefore shouldn't consider it further." 
            ) (who)
            set who-of-tile-last-pushed-in-plan ""
          ]
          
          ;If this is the first action then remove the episode from episodic memory since no further actions
          ;should be performed from this episode.
          ifelse(planned-action-index = 0)[
            output-debug-message (word 
              "This is the first action in the most recent episode so I'll remove the last episode "
              "added to my 'episodic-memory' since all subsequent actions will fail"
            ) (who)
            set episodic-memory (but-last (episodic-memory))
          ]
          ;If this is not the first action then all previous actions to this point must have been OK otherwise,
          ;program flow wouldn't have gotten here.  In this case, keep all the valid actions from this episode
          ;(all actions up to this one) and remove the rest.
          [
            output-debug-message (word 
              "This is not the first action in the most recent episode so I'll remove this action and "
              "all subsequent ones but keep all previous actions in the episode"
            ) (who)
            let valid-actions (chrest:ListPattern.new 
              (sublist (planned-actions) (0) (planned-action-index)) 
              (chrest:Modality.value-of("ACTION"))
            )
            set most-recent-episode (replace-item (1) (most-recent-episode) (valid-actions))
            set episodic-memory (replace-item ((length episodic-memory) - 1) (episodic-memory) (most-recent-episode))
          ]
          
          output-debug-message ("Since an invalid planned action was encountered, I'll stop processing planned actions in the most recent episode") (who)
          set invalid-action-encountered (true)
        ]
        [
          output-debug-message (word "Planned action " planned-action-index " valid, performing next planned action (" (planned-action-index + 1) ") in my visual-spatial field") (who)
          set planned-action-index (planned-action-index + 1)
        ]
      ]
        
      output-debug-message (word 
        "Completed applying moves deliberated on. I'll fixate on my visual-spatial "
        "field again since I'll either need to rethink what to do if none/some of my "
        "actions were valid (to consider visual information I may have missed) or "
        "to start deliberating on a new set of actions to perform.  Also setting my "
        "'generate-plan?' variable to false so that I don't continue plan generation "
        "until I've finished fixating on my visual-spatial field"
      ) (who)
      set fixate-on-visual-spatial-field? (true)
      set generate-plan? (false)
      
      output-debug-message ("Incrementing my 'current-search-iteration' turtle variable by 1") (who)
      set current-search-iteration (current-search-iteration + 1)
      
      output-debug-message (word
        "Setting my 'time-spent-deliberating' variable to its current value ("
        time-spent-deliberating ") plus the product of the value of my CHREST "
        "model's attention clock (" chrest:get-attention-clock ") minus the current "
        "model time (" report-current-time ")"
      ) (who)
      set time-spent-deliberating (time-spent-deliberating + (chrest:get-attention-clock - report-current-time))
      output-debug-message (word "My 'time-spent-deliberating' variable is now set to: " time-spent-deliberating) (who)
      
      ;========================================================;
      ;== CHECK FOR END PLAN GENERATION CONDITIONS BEING MET ==;
      ;========================================================;
      
      ;Check this now since, if "generate-plan" has been called before, the visual-spatial field
      ;for the CHREST turtle will change when visual-spatial field objects are moved.  A previous
      ;"generate-plan" invocation will have scheduled this change so, when the scheduled time for
      ;object movement comes, the turtle shouldn't then go on to deliberate since a hole may have
      ;been filled, its avatar may no longer exist in the visual-spatial field etc.
      ;
      ;Implicitly, its assumed that the turtle will have fixated on the tile it pushed last since
      ;it will always be ahead of it and this is the intial Fixation made in a set and this Fixation
      ;should always succeed since attention is always free when the initial Fixation is generated.  
      ;This may have to be an explicit check in future though if such Fixations are not always 
      ;performed.
      output-debug-message ("Checking to see if any end plan generation conditions have been met...") (who)
      let end-plan-generation? (false)
    
      ;++++++++++++++++++++++++++++;
      ;++ CHECK SEARCH ITERATION ++;
      ;++++++++++++++++++++++++++++;
      
      if(current-search-iteration = max-search-iteration)[
        output-debug-message (word "I've reached my maximum search bound: my 'current-search-iteration' variable (" current-search-iteration ") is > my 'max-search-iteration' variable (" max-search-iteration ").  Ending plan generation...") (who)
        set end-plan-generation? (true)
      ]
      
      ;++++++++++++++++++++++++++++++++++++++++++++;
      ;++ CHECK FOR SELF ON VISUAL-SPATIAL FIELD ++;
      ;++++++++++++++++++++++++++++++++++++++++++++;
      
      if(not end-plan-generation?)[
        if( empty? (chrest:get-visual-spatial-field-object-locations (chrest:get-attention-clock) (word who) (false)) )[
          output-debug-message (word "I can't currently see myself in my visual-spatial field. Ending plan generation...")  (who)
          set end-plan-generation? true
        ]
      ]
      
      ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
      ;++ CHECK FOR TILE BEING PUSHED STILL EXISTING IN VISUAL-SPATIAL FIELD OR BEING PUSHED ONTO SAME COORDINATE AS HOLE ++;
      ;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++;
    
      if(not end-plan-generation?)[  
        output-debug-message (word "Checking to see if I was pushing a tile that has been pushed into a hole or no longer exists in my visual-spatial field.") (who)
        output-debug-message ("The latter may be true if the tile has been pushed out of the visual-spatial field or its visual-spatial field object representation has decayed.") (who)
        output-debug-message ("If this isn't checked, further planning may occur which should not be done since, when planning, I should be fixated on a tile and if it disappears or fills a hole I should execute the plan as-is...") (who)
        
        if(not empty? who-of-tile-last-pushed-in-plan)[
          output-debug-message (word "I've been pushing a tile so I'll check to see if it still exists or has been pushed onto a hole") (who)
          let locations-of-tile-last-pushed (chrest:get-visual-spatial-field-object-locations (chrest:get-attention-clock) (who-of-tile-last-pushed-in-plan) (false))
          ifelse(empty? locations-of-tile-last-pushed)[
            output-debug-message (word "There is no tile with a 'who' value of " who-of-tile-last-pushed-in-plan " in my visual-spatial field so the 'end-plan-generation?' turtle variable should be set to true") (who)
            set end-plan-generation? (true)
          ]
          [
            let location-of-tile-last-pushed ( item (0) (locations-of-tile-last-pushed) )
            output-debug-message (word "There is a tile with a 'who' value of " who-of-tile-last-pushed-in-plan " on coordinates " location-of-tile-last-pushed " in my visual-spatial field so I'll check to see if there is also a hole on this location...")  (who)
            
            let hole-locations (chrest:get-visual-spatial-field-object-locations (chrest:get-attention-clock) (hole-token) (true))
            
            foreach(hole-locations)[
              if( ? = location-of-tile-last-pushed)[
                output-debug-message (word "There is a hole on the same coordinates as the tile so the local 'end-plan-generation?' variable will be set to true...")  (who)
                set end-plan-generation? (true)
              ]
            ]  
          ]
        ]
      ]
      
      output-debug-message ("Resetting 'who-of-tile-last-pushed-in-plan'") (who)
      set who-of-tile-last-pushed-in-plan ("")
      
      ;=========================;
      ;== END PLAN GENERATION ==;
      ;=========================;
      if(end-plan-generation?)[ 
        output-debug-message ( word "The local 'end-plan-generation?' variable is set to true so I should not plan any more.  To do this I need to set my 'generate-plan?' turtle variable to false..."  ) (who)
        set generate-plan? (false)
        
        output-debug-message ( word "I also need to set my 'deliberation-finished-time' turtle variable to the value of my attention clock" ) (who)
        set deliberation-finished-time (chrest:get-attention-clock) 
        
        output-debug-message ( word "I'll also set my 'current-search-iteration' turtle variable to 0 now since it should be reset for the next planning cycle..." ) (who)
        set current-search-iteration 0
        
        output-debug-message ( word "I'll also set my 'who-of-tile-last-pushed-in-plan' turtle variable to '' now since it should be reset for the next planning cycle..." ) (who)
        set who-of-tile-last-pushed-in-plan ""
        
        output-debug-message (word "Setting my 'fixate-on-visual-spatial-field?' to false" ) (who)
        set fixate-on-visual-spatial-field? (false)
        
        output-debug-message ("Setting my 'execute-actions?' variable to true") (who)
        set execute-actions? (true)
      ]
    ];Visual-spatial field constructed? check        
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
to-report generate-visual-spatial-field-moves [ action-pattern reverse? time-to-get-visual-spatial-field-at ]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'generate-visual-spatial-field-moves' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  let visual-spatial-field (chrest:get-visual-spatial-field (time-to-get-visual-spatial-field-at))
  
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
    let location-of-self (chrest:VisualSpatialField.get-object-locations (time-to-get-visual-spatial-field-at) (word who) (false))
    output-debug-message (word "Result of getting my location in my visual-spatial field: " location-of-self) (who)
    
    ifelse(not empty? location-of-self)[
      set location-of-self (item (0) (location-of-self))
      let self-who (word who)
      let self-xcor ( item (0) (location-of-self) )
      let self-ycor ( item (1) (location-of-self) )
      output-debug-message ( word "My xcor '" self-xcor "' and ycor '" self-ycor "' in visual-spatial field.  Adding this to the data structure containing my moves...") (who)
      
      let self-moves ( list (chrest:ItemSquarePattern.new (self-who) (self-xcor) (self-ycor)) )
      output-debug-message ( word "My moves is now equal to: " (map ([ chrest:ItemSquarePattern.get-as-string (?) ]) (self-moves)) ) (who)
      
      output-debug-message (word "Now I'll calculate my new location in the visual-spatial field after applying action " chrest:ItemSquarePattern.get-as-string (action-pattern) "...") (who)
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
      output-debug-message ( word "My new location in the visual-spatial field will be: '" (chrest:ItemSquarePattern.get-as-string (new-location-of-self)) "', appending this to the moves for myself..." ) (who)
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
        let search-term (tile-token)
        if(not empty? who-of-tile-last-pushed-in-plan)[
          set search-using-id? (true)
          set search-term (who-of-tile-last-pushed-in-plan)
        ]      
        
        output-debug-message (word "Checking to see if '" search-term "' is on coordinates " tile-location " in my visual-spatial field...") (who)
        let tile-on-location (false)
        let coordinate-contents (chrest:VisualSpatialField.get-coordinate-contents 
          (item (0) (tile-location)) 
          (item (1) (tile-location)) 
          (time-to-get-visual-spatial-field-at)
          (false)
          )
        
        foreach(coordinate-contents)[
          if( (ifelse-value (search-using-id?) [chrest:VisualSpatialFieldObject.get-identifier (?)] [chrest:VisualSpatialFieldObject.get-object-type (?)]) = search-term )[
            set tile-on-location (true)
          ]
        ]
        
        if(tile-on-location)[
          
          output-debug-message ( word "Object " search-term " is on coordinates " tile-location " in my visual-spatial field so I'll continue to generate a push/pull move...") (who)
          let current-xcor-of-tile ( item (0) (tile-location) )
          let current-ycor-of-tile ( item (1) (tile-location) )
          
          output-debug-message ( word "Since I need to specify an object's ID when performing visual-spatial moves, I need to set the tile to move's 'who' number so it can be pushed/pulled" ) (who)
          output-debug-message ( word "To do this, I'll first check to see if my 'who-of-tile-last-pushed-in-plan' turtle variable is empty (this will not be the case if this move is a reversal of a previously planned 'push-tile' action") (who)
          if(empty? who-of-tile-last-pushed-in-plan)[
            
            output-debug-message (word "My 'who-of-tile-last-pushed-in-plan' turtle variable is empty so I'll set the tile to move to the who of the tile on coordinates " tile-location) (who)
            ;This move isn't a reversal so there should only be one tile on the coordinates indicated.
            
            ;Get the identifier for the first tile on the coordinates.
            foreach(chrest:VisualSpatialField.get-coordinate-contents (current-xcor-of-tile) (current-ycor-of-tile) (time-to-get-visual-spatial-field-at) (false))[
              if(chrest:VisualSpatialFieldObject.get-object-type (?) = tile-token)[
                set who-of-tile-last-pushed-in-plan (chrest:VisualSpatialFieldObject.get-identifier (?))
              ] 
            ]
            
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
      error (word "The turtle's visual-spatial field avatar is not present in its visual-spatial field at time " time-to-get-visual-spatial-field-at)
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
      ask patch-at (xCorOffset) (yCorOffset) [
        set pcolor ([sight-radius-colour] of myself)
      ]
    ]
    
    let square-content (list (xCorOffset) (yCorOffset) ("") (empty-patch-token))
    let turtles-at-x-and-y-offset []
    
    ;=========================================================;
    ;== CONVERT PATCH LOOKED AT DEPENDING ON TURTLE HEADING ==;
    ;=========================================================;
    
    ;This is important since CHREST turtles need to make 
    ;"jchrest.domainSpecifics.fixations.AheadOfAgentFixations"
    ;and the "jchrest.lib.Square" fixated on needs to be the
    ;patch immediately ahead of the turtle in the 
    ;"jchrest.domainSpecifics.Scene" representation of the 
    ;current observable environment.  Thus, depending on the
    ;heading of the calling turtle, the x/yCorOffsets need to
    ;be modified (but not set as the values of xCorOffset and
    ;yCorOffset).
    ifelse(heading = 0)[
      set turtles-at-x-and-y-offset ( (turtles-at (xCorOffset) (yCorOffset)) with [hidden? = false] )
    ]
    [
      ifelse(heading = 90)[
        set turtles-at-x-and-y-offset ( (turtles-at (yCorOffset) (xCorOffset * (- abs(xCorOffset)))) with [hidden? = false] )
      ]
      [
        ifelse(heading = 180)[
          set turtles-at-x-and-y-offset ( (turtles-at (-1 * xCorOffset) (-1 * yCorOffset)) with [hidden? = false] )
        ]
        [
          ifelse(heading = 270)[
            set turtles-at-x-and-y-offset ( (turtles-at (yCorOffset * (- abs(yCorOffset))) (xCorOffset)) with [hidden? = false] )
          ]
          [
            error (word "The heading of turtle " who " (" heading ") is unsupported by the 'get-observable-environment' procedure.")
          ]
        ]
      ]
    ]
    
    ;===========================================================================;
    ;== ALTER OBJECT INFORMATION BASED ON WHAT'S PRESENT ON PATCH "LOOKED AT" ==;
    ;===========================================================================;
    
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
    
    ; Make "who" a string
    set square-content (replace-item (2) (square-content) (word (item (2) (square-content))))
    
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; "ARE-VISUAL-SPATIAL-FIELD-SQUARES-VALID-AT-TIME?" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Determines whether the calling turtle's visual-spatial field has a 
;valid configuration of objects upon it at the time specified.
;
;For a visual-spatial field square's object configuration to be valid, 
;all of the following must be false:
;
; 1) Two tiles exist on the same square.
; 2) A tile and an opponent both exist on the same square.
; 3) The calling turtle's avatar and a hole both exist on the same square.
; 4) The calling turtle's avatar and a tile both exist on the same square.
; 5) The calling turtle's avatar and an opponent both exist on the same 
;    square.
;
;Note that only the creator's avatar and tiles are checked since these 
;are the only objects that can be moved by a calling turtle in its 
;visual-spatial field.
;
;         Name              Data Type     Description
;         ----              ---------     -----------
;@param   state-at-time     Number        The time at which to check the 
;                                         validity of the visual-spatial
;                                         field at.
;@return  -                 Boolean       True if the visual-spatial field 
;                                         squares are valid at the time
;                                         specified, false if not.
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>
to-report are-visual-spatial-field-squares-valid-at-time? [state-at-time]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'are-visual-spatial-field-squares-valid-at-time?' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1) 
  
  let visual-spatial-field (chrest:get-visual-spatial-field (state-at-time))
  let col (0)
  let row (0)
  
  while[col < chrest:VisualSpatialField.get-width (visual-spatial-field)][
    while[row < chrest:VisualSpatialField.get-height (visual-spatial-field)][
      output-debug-message (word "Checking square (" col ", " row ")") (word)
    
      let square-contents (chrest:VisualSpatialField.get-coordinate-contents (col) (row) (state-at-time) (false))
  
      let hole-counter 0
      let opponent-counter 0
      let self-counter 0
      let tile-counter 0
    
      foreach(square-contents)[
        let object (?)
        let object-type (chrest:VisualSpatialFieldObject.get-object-type (object))
        
        if(object-type = hole-token)[
          set hole-counter (hole-counter + 1)
        ]
        
        if(object-type = opponent-token)[
          set opponent-counter (opponent-counter + 1)
        ]
        
        if(object-type = chrest:Scene.get-creator-token)[
          set self-counter (self-counter + 1)
        ]
        
        if(object-type = tile-token)[
          set tile-counter (tile-counter + 1)
        ]
      ]
      
      output-debug-message (word "There's " hole-counter " hole(s), " opponent-counter " opponent(s), " self-counter " of me and " tile-counter " tile(s) here" ) (who)
      if(
        (tile-counter > 1) or 
        ((tile-counter = 1 or self-counter = 1) and opponent-counter > 0) or
        (self-counter = 1 and (hole-counter > 0 or tile-counter > 0))
      )[
        output-debug-message (word "This indicates an invalid visual-spatial field square state so false will be reported." ) (who)
        set debug-indent-level (debug-indent-level - 2)
        report (false)
      ]
        
      set row (row + 1)
    ]
    set row (0)
    set col (col + 1)
  ]
  
  output-debug-message (word "The visual-spatial field squares specified have valid configurations at time " state-at-time " so true will be reported." ) (who)
  set debug-indent-level (debug-indent-level - 2)
  report (true)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "LEARN-FROM-EPISODIC-MEMORY ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to learn-from-episodic-memory
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'learn-from-episodic-memory' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  
  ;Add all episodes that have been generated at the current time to a list.
  let episodic-memory-at-time []
  foreach(episodic-memory)[
    if(report-current-time >= item (2) (?))[
      set episodic-memory-at-time (lput (?) (episodic-memory-at-time))
    ]
  ]
  
  output-debug-message (word 
    "If my 'episodic-memory' at the current time isn't empty (" not empty? episodic-memory-at-time 
    "), I'll attempt to learn the action in the episode stipulated by my 'episode-to-learn-from' "
    "variable (" episode-to-learn-from ").  If I have learned all the actions in my episodes, I'll "
    "attempt to learn my episodes as productions. If all my episodes have been learned as "
    "productions I'll attempt to reinforce the productions denoted by any episodes if I can."
    ) (who)
  
  output-debug-message ("Checking if my 'episodic-memory-at-time' is empty") (who)
  ifelse(not empty? episodic-memory-at-time)[
    
    output-debug-message (word 
      "My 'episodic-memory-at-time' isn't empty, checking if I'm to learn the "
      "sequence of actions in my episode as a production"
      ) (who)
    
    ;===============================;
    ;== CONSTRUCT ACTION-SEQUENCE ==;
    ;===============================;
    
    ;Get the action-sequence that may be learned as-is or as a production here, 
    ;instead of repeating it in both circumstances. First, get the indexes of
    ;all episodes with non-empty visions in episodic-memory.
    let indexes-of-episodes-with-non-empty-visions []
    let episodic-memory-index (0)
    while[episodic-memory-index < length episodic-memory][
      let episode (item (episodic-memory-index) (episodic-memory))
      
      if(not chrest:ListPattern.empty? (item (0) (episode)))[
        set indexes-of-episodes-with-non-empty-visions (lput (episodic-memory-index) (indexes-of-episodes-with-non-empty-visions))
      ]
      
      set episodic-memory-index (episodic-memory-index + 1)
    ]
    
    ;Now, collect the actions of all episodes from the first episode that
    ;has a non-empty vision: empty visions aren't learned so can't have
    ;productions created from them since there'd be no source Node for
    ;the production.
    let first-non-empty-vision-episode-index ("")
    let action-sequence (chrest:ListPattern.new (list) (chrest:Modality.value-of ("ACTION")))
    
    if(not empty? indexes-of-episodes-with-non-empty-visions)[
      set first-non-empty-vision-episode-index (item (0) (indexes-of-episodes-with-non-empty-visions))
      set episodic-memory-index (first-non-empty-vision-episode-index)
      
      while[episodic-memory-index < length episodic-memory][
        set action-sequence (chrest:ListPattern.append 
          (action-sequence) 
          (item (1) (item (episodic-memory-index) (episodic-memory)))
          )
        set episodic-memory-index (episodic-memory-index + 1)
      ]
    ]
    
    ;==================;
    ;== WHAT TO DO?! ==;
    ;==================;
    
    ifelse(not learn-action-sequence-as-production? and episode-to-learn-from < length episodic-memory)[
      output-debug-message (word
        "I'm not to learn the sequence of actions in my episode as a production, "
        "checking if I'm to learn an action sequence from my episodes or not"
        ) (who)
      
      ifelse(not learn-action-sequence?)[
        
        output-debug-message (word 
          "I'm not to learn an action sequence from my episodes so I'll learn the action/vision "
          "from episode " episode-to-learn-from "in my 'episodic-memory' or, if they've been "
          "learned, I'll attempt to learn them as a production"
          ) (who)
        
        let episode (item (episode-to-learn-from) (episodic-memory))
        let episode-vision (item (0) (episode))
        let episode-action (item (1) (episode))
        output-debug-message (word 
          "Episode vision: " chrest:ListPattern.get-as-string (episode-vision) ", "
          "episode action: " chrest:ListPattern.get-as-string (episode-action) ", "
          ) (who)
        
        ;== LEARN EPISODE ACTION ==;
        
        if(learn-episode-action?)[
          output-debug-message ("Attempting to learn episode action") (who)
          let learn-action-result (chrest:recognise-and-learn (episode-action) (report-current-time))
          output-debug-message (word "Learn action result: " java:Object.to-string (learn-action-result)) (who)
          
          if(learn-action-result = chrest:ChrestStatus.value-of ("INPUT_ALREADY_LEARNED"))[
            output-debug-message ("Action fully learned, I'll move onto trying to learn the episode's vision") (who)
            set learn-episode-action? (false)
            set learn-episode-vision? (true)
          ]
        ]
        
        ;== LEARN VISION IN EPISODE ==;
        
        output-debug-message (word "Checking if I should learn the episode's vision, i.e. have I learned the episode action (" learn-episode-vision? ")") (who)
        
        if(learn-episode-vision?)[
          output-debug-message ("I've learned the episode's action, checking if the episode's vision isn't empty") (who)
          
          ifelse((not chrest:ListPattern.empty? (episode-vision)))[
            output-debug-message ("The episode's vision isn't empty so I'll attempt to learn it") (who)
            
            if(chrest:recognise-and-learn (episode-vision) (report-current-time) = chrest:ChrestStatus.value-of("INPUT_ALREADY_LEARNED"))[
              output-debug-message ("Vision fully learned, I'll move onto learning the episode as a production") (who)
              set learn-episode-vision? (false)
              set learn-episode-as-production? (true)
            ]
          ]
          [
            output-debug-message ("The episode's vision is empty so I can't learn this episode as a production. I'll start learning from the next episode") (who)
            set learn-episode-action? (true)
            set learn-episode-vision? (false)
            set episode-to-learn-from (episode-to-learn-from + 1)
          ]
        ]
        
        ;== LEARN EPISODE AS PRODUCTION ==;
        
        output-debug-message (word "Checking if I should learn the episode as a production (" learn-episode-as-production? ")") (who)
        if(learn-episode-as-production?)[
          output-debug-message ("Attempting to learn episode as a production") (who)
          
          let learn-production-result (chrest:learn-production (episode-vision) (episode-action) (report-current-time))
          output-debug-message (word "Result of attempting to learn production: " java:Object.to-string (learn-production-result)) (who)
          
          if(
            learn-production-result = chrest:ChrestStatus.value-of ("EXACT_PRODUCTION_LEARNED") or
            learn-production-result = chrest:ChrestStatus.value-of ("PRODUCTION_ALREADY_LEARNED")
            )[
          output-debug-message ("Exact production learned, I'll start learning the next episode") (who)
            set episode-to-learn-from (episode-to-learn-from + 1)
            set learn-episode-as-production? (false)
            set learn-episode-action? (true)
            output-debug-message (word "Episode to learn from now set to " episode-to-learn-from) (who)
            ]
        ]
        
        ;== TURN ON ACTION SEQUENCE LEARNING ==;
        
        if(episode-to-learn-from >= length episodic-memory)[
          output-debug-message (word 
            "All individual episode visions/actions learned, attempting to either learn an "
            "action sequence from my episodes or learn said action sequence as a production"
            ) (who)
          set learn-action-sequence? (true)
        ]
      ]
      
      ;===========================;
      ;== LEARN ACTION SEQUENCE ==;
      ;===========================;
      [
        output-debug-message (word "I'm to learn the actions in my episode as a sequence.  Action sequence to learn: " (chrest:ListPattern.get-as-string (action-sequence))) (who)
        ifelse(chrest:ListPattern.size (action-sequence) > 1)[
          
          output-debug-message ("There is more than 1 action in the sequence so it is a 'sequence' and will therefore be learned") (who)
          let result-of-learning-action-sequence chrest:recognise-and-learn (action-sequence) (report-current-time)
          output-debug-message (word "Result of learning action sequence: " java:Object.to-string (result-of-learning-action-sequence)) (who)
          
          if(result-of-learning-action-sequence = chrest:ChrestStatus.value-of ("INPUT_ALREADY_LEARNED"))[
            
            output-debug-message (word 
              "Action sequence fully learned, I'll try to create a production between the "
              "first non-empty vision in episodic memory and the action sequence now"
              ) (who)
            
            set learn-action-sequence? (false)
            set learn-action-sequence-as-production? (true)
          ]
        ]
        [
          output-debug-message ("There are either no episodes with a non-empty vision or just 1 so an action sequence can not be constructed and learned") (who)
        ]
      ]
    ]
    ;=========================================;
    ;== LEARN ACTION SEQUENCE AS PRODUCTION ==;
    ;=========================================;
    [
      output-debug-message (word "I'm to learn the action sequence from my episodes as a production.  The sequence to potentially learn is: " (chrest:ListPattern.get-as-string (action-sequence))) (who)
      
      ifelse(chrest:ListPattern.size (action-sequence) > 1)[
        output-debug-message ("There is more than 1 action in the sequence so it is a 'sequence' and will therefore be learned as a production") (who)
        
        let first-non-empty-vision (item (0) (item (first-non-empty-vision-episode-index) (episodic-memory)))    
        let learn-production-result (chrest:learn-production (first-non-empty-vision) (action-sequence) (report-current-time))
        output-debug-message (word "Result of attempting to learn action sequence as production: " java:Object.to-string (learn-production-result)) (who)
        
        if(
          learn-production-result = chrest:ChrestStatus.value-of ("EXACT_PRODUCTION_LEARNED") or
          learn-production-result = chrest:ChrestStatus.value-of ("PRODUCTION_ALREADY_LEARNED")
          )[
        output-debug-message ("Exact production learned, I'll stop learning from my episodes now") (who)
          set learn-action-sequence-as-production? (false)
          set learn-from-episodic-memory? (false)
          ]
      ]
      [
        output-debug-message ("The action sequence is either empty or only contains 1 action so its not a 'sequence' and will not be learned as a production") (who)
      ]
    ]
  ]
  [
    output-debug-message ("Episodic memory is empty, can't learn from it") (who)
  ]
  
  set debug-indent-level (debug-indent-level - 2)
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "MAKE-FIXATION" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to make-fixation
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'make-fixation' PROCEDURE") (who)
  
  ifelse(breed = chrest-turtles)[
    output-debug-message (word
      "I am a CHREST turtle, checking if I should make a fixation, i.e. should I fixate "
      "on reality (" fixate-on-reality? ") or should I fixate on my visual-spatial field "
      "(" fixate-on-visual-spatial-field? ")"
    ) (who)
     
    ;Check that the 'fixate-on-reality?' and 'fixate-on-visual-spatial-field?' turtle variables
    ;are not both set to true since this will cause problems if left unchecked.
    if(fixate-on-reality? and fixate-on-visual-spatial-field?)[
      error (word 
        "Both the 'fixate-on-reality?' and 'fixate-on-visual-spatial-field?' turtle variables "
        "are set to true for turtle " who "; this should not occur."
      )
    ]
     
    ifelse(fixate-on-reality? or fixate-on-visual-spatial-field?)[
      
      let scene-to-fixate-on (ifelse-value (fixate-on-reality?) 
        [chrest:Scene.new (get-observable-environment) (word "Turtle " who " Reality @ Time: " report-current-time)] 
        [chrest:get-visual-spatial-field-as-scene (report-current-time) (unknown-visual-spatial-field-object-replacement-probabilities)]
      )
     
      ;A visual-spatial field should only be constructed when the turtle is fixating on reality and can plan.
      let construct-visual-spatial-field? (ifelse-value (fixate-on-reality? and can-plan?) [true] [false]) 
     
      output-debug-message (word 
        "Attempting to make a Fixation on scene with name '" (chrest:Scene.get-name 
        (scene-to-fixate-on) ) "' and the local 'construct-visual-spatial-field?' "
        "parameter is set to '" construct-visual-spatial-field? "'" 
      ) (who)
      
      let fixation-set-performance-result (chrest:schedule-or-make-next-fixation (scene-to-fixate-on) (true) (construct-visual-spatial-field?) (report-current-time))
      
      ;===========================;
      ;== FIXATION SET COMPLETE ==;
      ;===========================;
      ifelse(fixation-set-performance-result = chrest:ChrestStatus.value-of("FIXATION_SET_COMPLETE"))[
        output-debug-message (word "Fixation set now complete.") (who)
        
        if(fixate-on-reality?) [
          set fixate-on-reality? (false)
          output-debug-message (word
            "Since I was fixating on reality I should no longer do so.  Setting my 'fixate-on-reality?' turtle "
            "variable to 'false' (actual value of variable after setting: " fixate-on-reality? ")."
          ) (who)
        ]
        
        if(fixate-on-visual-spatial-field?) [
          set fixate-on-visual-spatial-field? (false)
          set time-visual-spatial-field-can-be-used-for-planning (report-current-time)
          output-debug-message (word 
            "Since I was fixating on my visual-spatial field I should no longer do so.  Setting my "
            "'fixate-on-visual-spatial-field?' turtle variable to 'false' (actual value of variable "
            "after setting: " fixate-on-visual-spatial-field? ") and my "
            "'time-visual-spatial-field-can-be-used-for-planning' variable to the current time."
          ) (who)
        ]
        
        if(construct-visual-spatial-field?) [
          set time-visual-spatial-field-can-be-used-for-planning (chrest:get-attention-clock)
          output-debug-message (word 
            "A visual-spatial field was constructed so my 'time-visual-spatial-field-can-be-used-for-planning' "
            "turtle variable has been set to the time attention is free (when visual-spatial field construction "
            "completes): " time-visual-spatial-field-can-be-used-for-planning "."
          ) (who)
        ]
        
        if(can-plan?)[
          set generate-plan? (true)
          output-debug-message (word
            "I can also plan so I'll set my 'generate-plan?' turtle variable to true (actual value of variable "
            "after setting: " generate-plan? ")."
          ) (who)
        ]
      ]
      [
        output-debug-message (word "Fixation set not yet complete.") (who)
      ]
    ]
    [
      output-debug-message ("I shouldn't make any fixations now") (who)
    ]
  ]
  [
    output-debug-message ("I'm not a CHREST turtle so this procedure should not be run") (who)
  ]
  
  set debug-indent-level (debug-indent-level - 2)
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
;
;         Name         Data Type                Description
;         ----         ---------                -----------
;@param   action       List                     The action to perform with the following form:
;                                               [
;                                                 action-token 
;                                                 heading 
;                                                 patches-moved
;                                               ]
;@return  -            List/Boolean             If the action was not a "push-tile" action then a boolean 
;                                               value is returned (true if the action was performed 
;                                               successfully, false if not).  If the action is a "push-tile"
;                                               action then a list is returned (see documentation for the
;                                               "push-tile" procedure to see what is returned and why).
;
;@author  Martyn Lloyd-Kelly <martynlk@liverpool.ac.uk>  
to-report perform-action [ action ]
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'perform-action' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message (word "The action to perform is: " action) (who)
  
  let action-identifier ( item (0) (action) )
  let action-heading ( item (1) (action) )
  let action-patches ( item (2) (action) )
  output-debug-message ( word 
    "After extracting information from the action passed to this procedure, three "
    "local variables 'action-identifier', 'action-heading' and 'action-patches' "
    "have been set to '" action-identifier "', '" action-heading "' and '" 
    action-patches "', respectively..." 
  ) (who)
  
  let action-performance-result []
  
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; CHECK FOR VALID ACTION ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ifelse(member? (action-identifier) (possible-actions))[
    
    output-debug-message (word "The action to perform (" action-identifier ") is a valid action.") (who)
    
    ;===================================================================================;
    ;== MODIFY ACTION HEADING ACCORDING TO TURTLE'S HEADING WHEN PLAN EXECUTION BEGAN ==;
    ;===================================================================================;
    
    ;Set the actual action heading since the action will have been decided 
    ;upon relative to the turtle's heading when plan generation was performed
    ;so all actions need to be performed in context of this. So, if the turtle's 
    ;'heading-when-plan-execution-begins' is:
    ;
    ;  - North (0), the turtle should move/push the tile according to the 
    ;    current 'action-heading' value.
    ;
    ;  - East (90), and 'action-heading' is set to:
    ;    + North (0), the turtle should move/push tile east (90).
    ;    + East (90), the turtle should move/push tile south (180).
    ;    + South (180), the turtle should move/push tile west (270).
    ;    + West (270), the turtle should move/push tile north (0).
    ;
    ;  - South (180), and 'action-heading' is set to:
    ;    + North (0), the turtle should move/push tile south (180).
    ;    + East (90), the turtle should move/push tile west (270).
    ;    + South (180), the turtle should move/push tile north (0).
    ;    + West (270), the turtle should move/push tile east (90).
    ;
    ;  - West (270) and 'action-heading' is set to:
    ;    + North (0), the turtle should move/push tile west (270).
    ;    + East (90), the turtle should move/push tile north (0).
    ;    + South (180), the turtle should move/push tile east (90).
    ;    + West (270), the turtle should move/push tile south (180).
    set action-heading (heading-when-plan-execution-begins + action-heading)
    
    if(action-heading >= 360)[
      set action-heading (action-heading - 360)
    ]
      
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
  ]
  [
    error (word "The action to perform is not a valid action (not a member of the global 'possible-actions' list: " possible-actions ").")
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
    
    if(debug-message-output-file != 0)[ 
      ask chrest-turtles [
        chrest:turn-on-debugging
        ]
    ]
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
    if(debug-message-output-file != 0)[ 
      ask chrest-turtles [chrest:turn-on-debugging]
    ]
  ]
  
  ;Check if the user has switched off debugging in between cycles.  If they have, set the 
  ;'debug-message-output-file' variable value to 0 so that if it is switched on again, the
  ;user is prompted to specify where debug files should be saved to.
  output-debug-message ("CHECKING TO SEE IF DEBUGGING HAS BEEN SWITCHED OFF IN BETWEEN CYCLES...") ("")
  if(not debug? and debug-message-output-file != 0)[
    output-debug-message ("DEBUGGING HAS BEEN SWITCHED OFF AND THE 'debug-message-output-file' VARIABLE VALUE HAS BEEN SET PREVIOUSLY.  CLOSING THE 'debug-message-output-file' AND SETTING THIS VARIABLES VALUE BACK TO 0...") ("")
    file-close
    set debug-message-output-file 0
    ask chrest-turtles [chrest:turn-off-debugging]
  ]
  
  ;Remove any players from the environment if the current time equals their 'training-time'
  ;or 'play-time' variables.
  remove-players
  
  ;===================;
  ;=== END OF PLAY ===;
  ;===================;
  
  output-debug-message (word "CHECKING TO SEE IF THERE ARE ANY PLAYER TURTLES STILL PLAYING (VISIBLE)...") ("")
  ifelse(player-turtles-finished?)[
    
    ;====================;
    ;== END OF TUITION ==;
    ;====================;
    if(tuition?)[
      set tuition? (false)
      ask turtles [
        set hidden? (false)
      ]
    ]
    
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
      output-print (word "Avg deliberation time: " (mean [time-spent-deliberating] of chrest-turtles) )
      output-print (word "Avg # productions: " (mean [chrest:get-production-count (report-current-time)] of chrest-turtles) )
;      output-print (word "Avg frequency of random behaviour: " (mean [frequency-of-random-behaviour] of chrest-turtles) )
      output-print (word "Avg frequency of problem-solving: " (mean [frequency-of-problem-solving] of chrest-turtles) )
      output-print (word "Avg frequency of pattern-recognition: " (mean [frequency-of-pattern-recognitions] of chrest-turtles) )
      output-print (word "Avg # visual LTM nodes: " (mean [chrest:get-ltm-modality-size (chrest:Modality.value-of ("VISUAL")) (report-current-time)] of chrest-turtles) )
      output-print (word "Avg depth visual LTM: " (mean [chrest:get-ltm-avg-depth (chrest:Modality.value-of ("VISUAL")) (report-current-time)] of chrest-turtles) )
      output-print (word "Avg # action LTM nodes: " (mean [chrest:get-ltm-modality-size (chrest:Modality.value-of ("ACTION")) (report-current-time)] of chrest-turtles) )
      
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
      
      ; Save LTM states of CHREST turtles.
      ask chrest-turtles[
        output-print (word "Turtle " who " score: " score)
      ]
      let top-score (max [score] of chrest-turtles)
      let ten-percent-cut-off ((top-score / 100) * 90)
      
      ask chrest-turtles with [save-ltm-state? = true and score >= ten-percent-cut-off][
        chrest:save-ltm-state 
          (word 
            setup-and-results-directory
            directory-separator
            "Scenario" current-scenario-number
            directory-separator
            "Repeat" current-repeat-number
            directory-separator
            "Turtle" who "LtmState.ser"
          ) 
          (report-current-time)
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
    
    ;=============;
    ;== TUITION ==;
    ;=============;
    
    if(tuition?)[
      teach-tutees
      
      ask turtles with [tutor? = false][
      
        ;================================;  
        ;== LEARN FROM EPISODIC MEMORY ==;
        ;================================;
        
        output-debug-message (word 
          "Checking if my attention is free, if so, I'll attempt to learn from the "
          "current state of my 'episodic-memory'"
        ) (who)
        
        if(chrest:is-attention-free? (report-current-time))[
          learn-from-episodic-memory
        ]
        
        ;===========================;
        ;== REINFORCE PRODUCTIONS ==;
        ;===========================;
        
        output-debug-message (word 
          "If I should reinforce productions (" reinforce-productions? ") and my "
          "'reinforcement-learning-theory' turtle variable is not an empty string "
          "(current value: '" reinforcement-learning-theory "'), I'll attempt to " 
          "reinforce my productions"
        ) (who)
        
        if(
          reinforce-productions? and 
          not empty? reinforcement-learning-theory and
          chrest:is-attention-free? (report-current-time)
        )[
          reinforce-productions
        ]
      ]
    ]
    
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
    set time-last-hole-filled (report-current-time)
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
  
  output-debug-message ( word "CHECKING TO SEE IF " value " IS A LIST" ) ("")
  ifelse(string:rex-match ("\\(?list.*") (value))[
    output-debug-message ( word value " IS A LIST, REPORTING IT AS-IS") ("")
    report value
  ]
  [
    output-debug-message ( word value "IS NOT A LIST, CHECKING TO SEE IF IT IS AN INTEGER OR FLOATING POINT NUMBER...") ("")
    ifelse(string:rex-match ("-?[0-9]+\\.?[0-9]*|") (value) )[
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
  ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; "REINFORCE-PRODUCTIONS" PROCEDURE ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to reinforce-productions
  set debug-indent-level (debug-indent-level + 1)
  output-debug-message ("EXECUTING THE 'reinforce-productions' PROCEDURE...") ("")
  set debug-indent-level (debug-indent-level + 1)
    
  ;Productions to reinforce are episodes and are learned from most recently
  ;performed to least recently performed so, the episode-to-reinforce index
  ;decrements as productions in episodes are reinforced hence the check for
  ;the index being >= 0.  This is because the most recent episode in the 
  ;turtle's episodic-memory is the size of the episodic-memory - 1.
  output-debug-message (word "Checking my 'episode-to-reinforce' variable (" episode-to-reinforce ")") (who)
  ifelse(episode-to-reinforce >= 0)[
    output-debug-message (word 
      "Since my 'episode-to-reinforce' variable is >= 0, I'll continue attempting to reinforce "
      "my productions. Getting the most recent episode from my 'episodic-memory' whose vision "
      "isn't empty, has been performed and that hasn't been reinforced in this acting cycle yet"
    ) (who)
    
    let lastest-episode-performance-time (max (map ([item (3) (?)]) (episodic-memory)))
    ifelse(lastest-episode-performance-time <= report-current-time)[
    
      ;=================================================;
      ;== GET FIRST EPISODE WHOSE VISION IS NON-EMPTY ==;
      ;=================================================;
    
      let reinforce-production? (true)
    
      let episode (item (episode-to-reinforce) (episodic-memory))
      let episode-vision (item (0) (episode))
      let episode-performance-time (item (3) (episode))
    
      ;Check to see if a search for a new episode to reinforce needs to occur.
      if(chrest:ListPattern.empty? (episode-vision))[
        let search-for-non-empty-vision? (true)
        set reinforce-production? (false)
        
        while[search-for-non-empty-vision?][
          set episode-to-reinforce (episode-to-reinforce - 1)
        
          ifelse(episode-to-reinforce >= 0)[
            set episode (item (episode-to-reinforce) (episodic-memory))
            set episode-vision (item (0) (episode))
          
            if(not chrest:ListPattern.empty? (episode-vision))[
              set search-for-non-empty-vision? (false)
              set reinforce-production? (true)
            ]
          ]
          [
            set search-for-non-empty-vision? (false)
          ]
        ]
      ]
    
      ;==========================;
      ;== REINFORCE PRODUCTION ==;
      ;==========================;
      
      ifelse(reinforce-production?)[
        output-debug-message (word 
          "Most recent episode whose vision is not empty that hasn't been reinforced in this "
          "acting cycle yet: "
          (list
            (chrest:ListPattern.get-as-string (item (0) (episode)))
            (chrest:ListPattern.get-as-string (item (1) (episode)))
            (item (2) (episode))
            (item (3) (episode))
            )
          ) (who)
    
        let episode-action (item (1) (episode))
        let reinforcement-variables (list 
          (1.0) 
          (discount-rate) 
          (time-last-hole-filled) 
          (item (2) (episode))
          )
        
        output-debug-message (word
          "Variables required for reinforcement are as follows: " 
          "reward = " (item (0) (reinforcement-variables)) ", "
          "discount-rate = " (item (1) (reinforcement-variables)) ", "
          "time last hole filled = " (item (2) (reinforcement-variables)) ", "
          "time episode performed = " (item (3) (reinforcement-variables))
          ) (who)
        
        let reinforcement-result (chrest:reinforce-production (episode-vision) (episode-action) (reinforcement-variables) (report-current-time))
        output-print (word "Result of reinforcement: " java:Object.to-string (reinforcement-result)) ;(who)
        
        ifelse(
          chrest:ChrestStatus.value-of ("NO_PRODUCTION_IDENTIFIED") = reinforcement-result or
          chrest:ChrestStatus.value-of ("EXACT_PRODUCTION_MATCH_REINFORCED") = reinforcement-result or
          chrest:ChrestStatus.value-of ("HIGH_PRODUCTION_MATCH_REINFORCED") = reinforcement-result or
          chrest:ChrestStatus.value-of ("MODERATE_PRODUCTION_MATCH_REINFORCED") = reinforcement-result or
          chrest:ChrestStatus.value-of ("LOW_PRODUCTION_MATCH_REINFORCED") = reinforcement-result
        )[
          output-debug-message (word "Reinforcing the next episode") (who)
          set episode-to-reinforce (episode-to-reinforce - 1)
        ]
        [
          output-debug-message (word "Continuing to attempt to reinforce the same episode") (who)
        ]
      ]
      [
        output-debug-message ("There are episodes with non-empty visions that have been performed at the current time in episodic-memory, exiting") (who)
      ]
    ]
    [
      output-debug-message ("Latest episode hasn't been performed yet, exiting procedure.") (who)
    ]
  ]
  [
    output-debug-message ("My 'episode-to-reinforce' variable is < 0 so I'll attempt to reinforce my productions ") (who)
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
  set move-token "MV"
  set push-tile-token "PT"
  
  ;Set object identifier strings.
  set blind-patch-token (chrest:Scene.get-blind-square-token)
  set empty-patch-token (chrest:Scene.get-empty-square-token)
  set hole-token (chrest:TileworldDomain.get-hole-token)
  set tile-token (chrest:TileworldDomain.get-tile-token)
  set opponent-token (chrest:TileworldDomain.get-opponent-token)
  set self-token (chrest:Scene.get-creator-token)
  
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
    (move-token)
    (push-tile-token)
  )
  set colors-used []
  set training? true
  
  setup-independent-variables
  setup-chrest-turtles (true)
  check-variable-values
  
  if(testing?)[
    set testing-debug-messages ""
    if(debug?)[
      ask chrest-turtles [chrest:turn-on-debugging]
    ]
  ]
  
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
    while[member? (color) (colors-used)][
      set color (one-of (base-colors))
    ]
    set colors-used (lput (color) (colors-used))
    if(length colors-used = length base-colors)[
      set colors-used ([])
    ]
    
    set actions-to-perform []
    set current-search-iteration (0)
    set deliberation-finished-time (ifelse-value (can-plan?) [0] [-1])
    set episode-to-learn-from (0)
    set episode-to-reinforce (-1)
    set episodic-memory ([])
    set execute-actions? (false)
    set fixate-on-reality? (true)
    set fixate-on-visual-spatial-field? (false)
    set generate-plan? (false)
    set heading (0)
    set learn-action-sequence? (false)
    set learn-action-sequence-as-production? (false)
    set learn-episode-action? (true)
    set learn-episode-vision? (false)
    set learn-episode-as-production? (false)
    set learn-from-episodic-memory? (true)
    set reinforce-productions? (false)
    set score (0)
    set sight-radius-colour (color + 2)
    set time-last-hole-filled (-1)
    set time-visual-spatial-field-can-be-used-for-planning (-1)
    set who-of-tile-last-pushed-in-plan ("")
    
    if(setup-chrest?)[
      chrest:new (report-current-time) (true)
      chrest:set-domain 
      ("jchrest.domainSpecifics.tileworld.TileworldDomain") 
      (list
        (list ("jchrest.architecture.Chrest") (CHREST))
        (list ("java.lang.Integer") (max-fixations-in-set))
        (list ("java.lang.Integer") (initial-fixation-threshold))
        (list ("java.lang.Integer") (peripheral-item-fixation-max-attempts))
        (list ("java.lang.Integer") (time-taken-to-decide-upon-movement-fixations))
        (list ("java.lang.Integer") (time-taken-to-decide-upon-salient-object-fixations))
      )
    ]
      
    chrest:set-add-production-time (add-production-time)
    chrest:set-can-create-semantic-links (can-create-semantic-links?)
    chrest:set-can-create-templates (can-create-templates?)
    chrest:set-discrimination-time (discrimination-time)
    chrest:set-familiarisation-time (familiarisation-time)
    chrest:Perceiver.set-fixation-field-of-view (fixation-field-of-view)
    chrest:set-ltm-link-traversal-time (ltm-link-traversal-time)
    chrest:set-maximum-semantic-link-search-distance (maximum-semantic-link-search-distance)
    chrest:set-node-comparison-time (node-comparison-time)
    chrest:set-node-image-similarity-threshold (node-image-similarity-threshold)
    chrest:set-reinforce-production-time (reinforce-production-time)
    if(not empty? reinforcement-learning-theory)[ 
      chrest:set-reinforcement-learning-theory (chrest:ReinforcementLearning.value-of (reinforcement-learning-theory)) 
    ]
    chrest:set-recognised-visual-spatial-field-object-lifespan (recognised-visual-spatial-field-object-lifespan)
    chrest:set-rho (rho)
    chrest:set-saccade-time (saccade-time)
    chrest:set-template-construction-parameters (minimum-depth-of-node-in-network-to-be-a-template) (minimum-item-or-position-occurrences-in-node-images-to-be-a-slot-value)
    chrest:set-time-taken-to-decide-upon-ahead-of-agent-fixations (time-taken-to-decide-upon-ahead-of-agent-fixations)
    chrest:set-time-taken-to-decide-upon-peripheral-item-fixations (time-taken-to-decide-upon-peripheral-item-fixations)
    chrest:set-time-taken-to-decide-upon-peripheral-square-fixations (time-taken-to-decide-upon-peripheral-square-fixations)
    chrest:set-time-to-access-visual-spatial-field (time-to-access-visual-spatial-field)
    chrest:set-time-to-create-semantic-link (time-to-create-semantic-link)
    chrest:set-time-to-encode-recognised-visual-spatial-field-object (time-to-encode-recognised-visual-spatial-field-object)
    chrest:set-time-to-encode-unrecognised-empty-square-as-visual-spatial-field-object (time-to-encode-unrecognised-empty-square-as-visual-spatial-field-object)
    chrest:set-time-to-encode-unrecognised-visual-spatial-field-object (time-to-encode-unrecognised-visual-spatial-field-object)
    chrest:set-time-to-move-visual-spatial-field-object (time-to-move-visual-spatial-field-object)
    chrest:set-time-to-process-unrecognised-scene-object-during-visual-spatial-field-construction (time-to-process-unrecognised-scene-object-during-visual-spatial-field-construction)
    chrest:set-time-to-retrieve-fixation-from-perceiver (time-to-retrieve-fixation-from-perceiver)
    chrest:set-time-to-retrieve-item-from-stm (time-to-retrieve-item-from-stm)
    chrest:set-time-to-update-stm (time-to-update-stm)
    chrest:set-unrecognised-visual-spatial-field-object-lifespan (unrecognised-visual-spatial-field-object-lifespan)
    
    place-randomly
    
    setup-plot-pen ("Scores") (0)
    setup-plot-pen ("Time Spent Deliberating") (0)
    setup-plot-pen ("Production Count") (0)
    setup-plot-pen ("Random Behaviour Frequency") (1)
    setup-plot-pen ("Problem-Solving Frequency") (1)
    setup-plot-pen ("Pattern-Recognition Frequency") (1)
    setup-plot-pen ("Visual STM Node Count") (0)
    setup-plot-pen ("Visual LTM Size") (0)
    setup-plot-pen ("Visual LTM Avg. Depth") (0)
    setup-plot-pen ("Action STM Node Count") (0)
    setup-plot-pen ("Action LTM Size") (0)
    setup-plot-pen ("Action LTM Avg. Depth") (0)
    
;    output-debug-message (word "My 'current-visual-pattern' variable is set to: '" current-visual-pattern "'.") (who)
    output-debug-message (word "My 'heading' variable is set to: '" heading "'.") (who)
    output-debug-message (word "My 'episodic-memory' variable is set to: '" episodic-memory "'.") (who)
    output-debug-message (word "My 'score' variable is set to: '" score "'.") (who)
    output-debug-message (word "My 'time-to-perform-next-action' variable is set to: '" time-to-perform-next-action "'.") (who)
    output-debug-message (word "My '_addProductionTime' CHREST variable is set to: '" chrest:get-add-production-time "' seconds.") (who)
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
                
                output-debug-message ("SPLITTING LINE ON FIRST COLON TO GET WHO(S) OF TURTLE(S) TO SET VALUE FOR AND THE VALUE") ("")
                let whos-and-value (string:rex-split (line) (":+?"))
                let whos (item (0) (whos-and-value))
                let value (item (1) (whos-and-value))
                
                output-debug-message ("CHECKING FOR MORE THAN ONE PAIR OF MATCHING PARENTHESIS IN WHO SPECIFICATION...") ("")
                if(
                  (check-for-substring-in-string-and-report-occurrences ("(") (whos)) = (check-for-substring-in-string-and-report-occurrences (")") (whos)) and 
                  (check-for-substring-in-string-and-report-occurrences ("(") (whos)) > 1
                  )
                [
                  error (word "ERROR: External model settings file line: '" line "' contains more than one pair of matching parenthesis in who specification!" )
                ]
                output-debug-message ("NO MORE THAN ONE PAIR OF MATCHING PARENTHESIS EXISTS IN WHO SPECIFICATION...") ("")
                
                output-debug-message ("CHECKING FOR A HYPHEN IN WHO SPECIFICATION IF MATCHING PARENTHESIS EXIST...") ("")
                if(
                  (check-for-substring-in-string-and-report-occurrences ("(") (whos)) = (check-for-substring-in-string-and-report-occurrences (")") (whos)) and 
                  (check-for-substring-in-string-and-report-occurrences ("(") (whos)) = 1 and
                  not member? "-" line 
                  )
                [
                  error (word "ERROR: External model settings file line: '" line "' does not contain a hyphen in group who specification!" )
                ]
                output-debug-message ("GROUP WHO SPECIFICATION CONTAINS A HYPHEN AND ONE PAIR OF MATCHING PARENTHESIS...") ("")
                
                output-debug-message (word "'" whos "' IS FORMATTED CORRECTLY.") ("")
                
                ifelse( member? "(" whos )[
                  output-debug-message (word "'" whos "' CONTAINS A '(' SO THE '" variable-name "' VARIABLE FOR A NUMBER OF TURTLES SHOULD BE SET...") ("")
                  
                  let current-who read-from-string ( substring whos ( (position "(" whos) + 1 ) (position "-" whos) )
                  let last-who read-from-string ( substring whos ( (position "-" whos) + 1 ) (position ")" whos) )
                  let value-specified ( quote-string-or-read-from-string (value) )
                  
                  while[current-who <= last-who][
                    output-debug-message (word "TURTLE " current-who "'s '" variable-name "' VARIABLE WILL BE SET TO: '" value-specified "'.") ("")
                    
                    ask turtle current-who[ 
                      print-and-run (word "set " variable-name " " value-specified)
                    ]
                    
                    set current-who (current-who + 1)
                  ]
                ]
                [
                  output-debug-message (word "'" whos "' DOES NOT CONTAIN A '(' SO THE '" variable-name "' VARIABLE FOR ONE TURTLE SHOULD BE SET...") ("")
                  
                  let turtle-who read-from-string ( whos )
                  let value-specified (quote-string-or-read-from-string (value))
                  output-debug-message (word "TURTLE " turtle-who "'s '" variable-name "' VARIABLE WILL BE SET TO: '" value-specified "'.") ("")
                  
                  ask turtle turtle-who[ 
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; "TEACH-TUTEES" PROCEDURE ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to teach-tutees
  ask chrest-turtles with [tutor? = true][
    foreach(tutees)[
      ask turtle ? [
        set episodic-memory ([episodic-memory] of myself)
      ]
    ]
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
  
  ;Remove any unneccessary white space so the test code i. quicker to run.
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
    output-debug-message (word "CHECKING IF '" ? "' IS A MEMBER OF '" expected "'") ("")
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
Production Count
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
Visual STM Node Count
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
Action STM Node Count
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
1
1
0
Number

INPUTBOX
7
70
147
130
total-number-of-repeats
1
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
4
460
709
673
12

PLOT
711
189
957
368
Time Spent Deliberating
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
