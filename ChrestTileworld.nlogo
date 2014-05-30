; ===========================
; ===========================
; ===== CHREST Tileword =====
; ===========================
; =========================== 
; by Martyn Lloyd-Kelly

;INPROG: Reinforce visual-action links in STM if a turtle successfully pushes a tile into a hole.

;TODO: Investigate 'get-stm-by-modality' primitive since the graphs being plotted are always at 5 on y-axis.
;TODO: Have turtles decide between using learnt action patterns or to deliberate about next action.
;      Currently, if a visual-pattern has:
;      - No associated action-pattern, the turtle it will deliberate about what to do.
;      - One associated action-pattern, the turtle will perform the action.
;      - More than one associated action-pattern: the turtle will pick one at random and perform it.
;TODO: Implement non-training game cycle.
;TODO: Determine how long it should take to reinforce a link between two patterns.
;TODO: Implement decision-making times for heuristics and add this to the time it takes to perform an action when
;      the action is loaded.
;TODO: Tidy up code layout.
;TODO: Should turtles generate visual patterns if they are scheduled to perform an action in the future?  Check with
;      Peter and Fernand.
;TODO: Extract action-pattern creation into independent procedures so code is DRY.
;TODO: Closest tile still throws an error since a dead tile is not removed from a turtle's closest-tile variable
;      despite the "fix" implemented.

;******************************************;
;******************************************;
;********* EXTENSION DECLARATIONS *********;
;******************************************;
;******************************************;

extensions [ chrest string ]

;**************************************;
;**************************************;
;********* BREED DECLARATIONS *********;
;**************************************;
;**************************************;

breed [ chrest-turtles ]
breed [ tiles ]
breed [ non-chrest-turtles ]
breed [ holes ]

;*****************************************;
;*****************************************;
;********* VARIABLE DECLARATIONS *********;
;*****************************************;
;*****************************************;

     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;;;; GLOBAL VARIABLES ;;;;;
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
     globals [
       current-game-time       ;Stores the length of time (in seconds) that the non-training game has run for.
       current-training-time   ;Stores the length of time (in seconds) that the training game has run for.
       debug-indent-level      ;Stores the current indent level (3 spaces per indent) for debug messages.
       hole-born-every         ;Stores the length of time (in seconds) that must pass before a hole may possibly be created.
       hole-birth-prob         ;Stores the probability that a hole will be created on each tick in the game.
       hole-lifespan           ;Stores the length of time (in seconds) that a hole lives for after creation. 
       hole-token              ;Stores the string used to indicate that a hole can be seen in visual-patterns.
       move-purposefully-token ;Stores the string used to indicate that the calling turtle moved purposefully in action-patterns.
       move-randomly-token     ;Stores the string used to indicate that the calling turtle moved randomly in action-patterns.
       movement-headings       ;Stores headings that agents can move.
       move-around-tile-token  ;Stores the string used to indicate that the calling turtle moved around a tile in action-patterns.
       move-to-tile-token      ;Stores the string used to indicate that the calling turtle moved to a tile in action-patterns.
       push-tile-token         ;Stores the string used to indicate that the calling turtle pushed a tile in action-patterns.
       remain-stationary-token ;Stores the string used to indicate that the calling turtle is remaining stationary.
       surrounded-token        ;Stores the string used to indicate that the calling turtle is surrounded.
       tile-born-every         ;Stores the length of time (in seconds) that must pass before a tile may possibly be created.
       tile-birth-prob         ;Stores the probability that a hole will be created on each tick in the game.
       tile-lifespan           ;Stores the length of time (in seconds) that a tile lives for after creation.
       tile-token              ;Stores the string used to indicate that a tile can be seen in visual-patterns.
       time-increment          ;Stores a value by which "current-training-time" and "current-game-time" should be incremented by when environment is updated.
       training?               ;Stores boolean true or false: true if the game is a training game, false if not (true by default).
       turtle-token            ;Stores the string used to indicate that a turtle can be seen in visual-patterns.
     ]

     ;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;;;; BREED VARIABLES ;;;;;
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
     chrest-turtles-own [ 
       action-performance-time                      ;Stores the length of time (in seconds) that the turtle takes to perform an action once selected.
       action-selection-pattern-recognition-time    ;Stores the length of time (in seconds) that the CHREST turtle takes to select an action using pattern-recognition.
       action-selection-heuristic-time              ;Stores the length of time (in seconds) that the turtle takes to select an action using a heuristic (used as the base in McCabe complexity).
       add-link-time                                ;Stores the length of time (in seconds) that the CHREST turtle takes to add a link between two nodes in LTM.
       chrest-instance                              ;Stores an instance of the CHREST architecture.
       closest-tile                                 ;Stores an agentset consisting of the closest tile to the calling turtle when the 'next-to-tile' procedure is called.
       current-visual-pattern                       ;Stores the current visual pattern that has been generated.
       destination-x                                ;Stores the x-coordinate the turtle is heading towards.
       destination-y                                ;Stores the y-coordinate the turtle is heading towards.
       discrimination-time                          ;Stores the length of time (in seconds) that the CHREST turtle takes to discriminate a new node in LTM.
       familiarisation-time                         ;Stores the length of time (in seconds) that the CHREST turtle takes to familiarise a node in LTM.
       next-action-to-perform                       ;Stores the action-pattern that the turtle is to perform next.
       play-time                                    ;Stores the length of time (in seconds) that the CHREST turtle can play a non-training game for.
       score                                        ;Stores the score of the agent (the number of holes that have been filled by the turtle).
       sight-radius                                 ;Stores the number of patches north, east, south and west that the turtle can see.
       sight-radius-colour                          ;Stores the colour that the patches a CHREST turtle can see will be set to (used for debugging). 
       time-to-perform-next-action                  ;Stores the time that the action-pattern stored in the "next-action-to-perform" turtle variable should be performed.
       training-time                                ;Stores the length of time (in seconds) that the turtle can train for.
       visual-pattern-used-to-generate-action       ;Stores the visual-pattern that was used to generate the action-pattern stored in the "next-action-to-perform" turtle variable.
     ]
     
     non-chrest-turtles-own[
       action-performance-time               ;Stores the length of time (in seconds) that the turtle takes to perform an action once selected.
       action-selection-heuristic time       ;Stores the length of time (in seconds) that the turtle takes to select an action using a heuristic (used as the base in McCabe complexity).
       destination-x                         ;Stores the x-coordinate the turtle is heading towards.
       destination-y                         ;Stores the y-coordinate the turtle is heading towards.
       next-action-to-perform                ;Stores the action-pattern that the turtle is to perform next.
       play-time                             ;Stores the length of time (in seconds) that a CHREST turtle can play a non-training game for.
       score                                 ;Stores the score of the agent (the number of holes that have been filled by the turtle).
       sight-radius                          ;Stores the number of patches north, east, south and west that the turtle can see.
       time-to-perform-next-action           ;Stores the time that the action-pattern stored in the "next-action-to-perform" turtle variable should be performed.
       training-time                         ;Stores the length of time (in seconds) that the turtle can train for.
     ]
     
     tiles-own [ 
       time-to-live    ;Stores the time (in seconds) that a tile has left before it dies.
     ]
     
     holes-own [ 
       time-to-live    ;Stores the time (in seconds) that a hole has left before it dies.
     ]

;************************************************;
;************************************************;
;********* SIMULATION SET-UP PROCEDURES *********;
;************************************************;
;************************************************;

     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;;;; "SETUP" PROCEDURE ;;;;;
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     
     ;The setup procedure performs a number of tasks in the following order:
     ;
     ; 1) Clear all model variables
     ; 2) Set global and turtle-specific variables using hard-coded information.
     ; 3) Set global and turtle-specific variables using user-specified information.
     ; 4) Check for valid user-specified global variable values.
     ; 5) Set hard-coded turtle-specific variable values.
     ;
     ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
     to setup
       set debug-indent-level 0
       output-debug-message ("EXECUTING THE 'setup' PROCEDURE...") ("")
       
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;;; CLEAR ALL MODEL VARIABLES ;;;
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
       ;For this model to work with NetLogo's new plotting features,
       ;"__clear-all-and-reset-ticks" should be replaced with "clear-all" 
       ;at the beginning of your setup procedure and "reset-ticks" at the 
       ;end of the procedure.
       __clear-all-and-reset-ticks
       
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;;; SET GLOBAL AND TURTLE-SPECIFIC VARIABLES USING HARD-CODED VALUES ;;;
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
       ;Set some non-specific global variables.
       set-default-shape chrest-turtles "turtle"
       set-default-shape tiles "box"
       set-default-shape holes "circle"
       set current-training-time 0
       set current-game-time 0
       set movement-headings [ 0 90 180 270]
       set training? true
  
       ;Set action-pattern token strings 
       set move-around-tile-token "MAT"
       set move-purposefully-token "MP"
       set move-randomly-token "MR"
       set move-to-tile-token "MTT"
       set push-tile-token "PT"
       set surrounded-token "S"
       set remain-stationary-token "RS"
       
       ;Set visual-pattern token strings
       set hole-token "H"
       set tile-token "T"
       set turtle-token "A"
       
       set debug-indent-level (debug-indent-level + 1)
       output-debug-message (word "THE 'current-training-time' GLOBAL VARIABLE IS SET TO: '" current-training-time "'.") ("")
       output-debug-message (word "THE 'current-game-time' GLOBAL VARIABLE IS SET TO: '" current-game-time "'.") ("")
       output-debug-message (word "THE 'movement-headings' GLOBAL VARIABLE IS SET TO: '" movement-headings "'.") ("")
       output-debug-message (word "THE 'training?' GLOBAL VARIABLE IS SET TO: '" training? "'.") ("")
       output-debug-message (word "THE 'move-around-tile-token' GLOBAL VARIABLE IS SET TO: '" move-around-tile-token "'.") ("")
       output-debug-message (word "THE 'move-randomly-token' GLOBAL VARIABLE IS SET TO: '" move-randomly-token "'.") ("")
       output-debug-message (word "THE 'move-to-tile-token' GLOBAL VARIABLE IS SET TO: '" move-to-tile-token "'.") ("")
       output-debug-message (word "THE 'push-tile-token' GLOBAL VARIABLE IS SET TO: '" push-tile-token "'.") ("")
       output-debug-message (word "THE 'hole-token' GLOBAL VARIABLE IS SET TO: '" hole-token "'.") ("")
       output-debug-message (word "THE 'tile-token' GLOBAL VARIABLE IS SET TO: '" tile-token "'.") ("")
       output-debug-message (word "THE 'turtle-token' GLOBAL VARIABLE IS SET TO: '" turtle-token "'.") ("")
       output-debug-message (word "THE 'remain-stationary-token' GLOBAL VARIABLE IS SET TO: '" remain-stationary-token "'.") ("")
  
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;;; SET GLOBAL AND TURTLE-SPECIFIC VARIABLES USING USER-SPECIFIED VALUES ;;;
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
       setup-environment-using-user-selected-file
       
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;;; CHECK FOR VALID USER-SPECIFIED GLOBAL VARIABLE VALUES ;;;
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
       if(hole-birth-prob > 1)[
         error ("The global 'hole-birth-prob' variable is greater than 1 ().  Please rectify this so that it is <= 1.")
       ]
       
       if(tile-birth-prob > 1)[
         error ("The global 'tile-birth-prob' variable is greater than 1 ().  Please rectify this so that it is <= 1.")
       ]
       
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;;; SET HARD-CODED TURTLE-SPECIFIC VARIABLE VALUES ;;;
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
       ask chrest-turtles [
         if(sight-radius < 2)[
           error (word "Turtle " who "'s sight radius is < 2 (" sight-radius ").  This value must be >= 2 since player turtles must be able to see 1 patch past a tile they are adjacent to.")
         ]
         
         set closest-tile ""
         set current-visual-pattern ""
         set heading 0
         set next-action-to-perform ""
         set score 0
         set time-to-perform-next-action -1 ;Set to -1 initially since if it is set to 0 the turtle will think it has some action to perform in the initial round.
         set visual-pattern-used-to-generate-action []
         set sight-radius-colour (select-sight-radius-colour)
         
         chrest:instantiate-chrest-in-turtle
         chrest:set-add-link-time (convert-seconds-to-milliseconds (add-link-time))
         chrest:set-discrimination-time (convert-seconds-to-milliseconds (discrimination-time))
         chrest:set-familiarisation-time (convert-seconds-to-milliseconds (familiarisation-time))
         
         place-randomly
         
         setup-plot-pen "Scores"
         setup-plot-pen "Num Visual-Action Links" 
         setup-plot-pen "Visual LTM Size"
         setup-plot-pen "Visual LTM Avg. Depth"
         setup-plot-pen "Action LTM Size"
         setup-plot-pen "Action LTM Avg. Depth"
         setup-plot-pen "Visual STM Size"
         setup-plot-pen "Action STM Size"
         
         output-debug-message (word "My 'closest-tile' variable is set to: '" closest-tile "'.") (who)
         output-debug-message (word "My 'current-visual-pattern' variable is set to: '" current-visual-pattern "'.") (who)
         output-debug-message (word "My 'heading' variable is set to: '" heading "'.") (who)
         output-debug-message (word "My 'next-action-to-perform' variable is set to: '" next-action-to-perform "'.") (who)
         output-debug-message (word "My 'score' variable is set to: '" score "'.") (who)
         output-debug-message (word "My 'time-to-perform-next-action' variable is set to: '" time-to-perform-next-action "'.") (who)
         output-debug-message (word "My 'visual-pattern-used-to-generate-action' variable is set to: '" visual-pattern-used-to-generate-action "'.") (who)
         output-debug-message (word "My '_addLinkTime' CHREST variable is set to: '" convert-milliseconds-to-seconds (chrest:get-add-link-time) "' seconds.") (who)
         output-debug-message (word "My '_discriminationTime' CHREST variable is set to: '" convert-milliseconds-to-seconds (chrest:get-discrimination-time) "' seconds.") (who)
         output-debug-message (word "My '_familiarisationTime' CHREST variable is set to: '" convert-milliseconds-to-seconds (chrest:get-familiarisation-time) "' seconds.") (who)
       ]
       
       set debug-indent-level (debug-indent-level - 1)
     end
     
     ;******************************************;
     ;******************************************;
     ;**** "SETUP" PROCEDURE SUB-PROCEDURES ****;
     ;******************************************;
     ;******************************************;
     
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;;;; "SELECT-SIGHT-RADIUS-COLOUR" PROCEDURE ;;;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
               
          ;Selects a colour for the calling turtle's "sight-radius-colour" variable iff
          ;the calling turtle is a CHREST turtle.
          ;
          ;The colour selected will be the same colour as the calling turtle's colour but
          ;brighter so that the calling turtle itself isn't lost in the colour of its sight 
          ;radius. 
          ;
          ;         Name              Data Type     Description
          ;         ----              ---------     -----------
          ;@returns -                 Integer       A non-shaded base colour
          ;
          ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
          to-report select-sight-radius-colour 
            ifelse(breed = chrest-turtles)[
              set sight-radius-colour (color + 2)
              report sight-radius-colour
            ]
            [
              error (word "Turtle " who "'s 'breed' variable (" breed ") is not equal to 'chrest-turtles'.")
            ]
          end
     
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;;;; "SETUP-ENVIRONMENT-USING-USER-SELECTED-FILE" PROCEDURE ;;;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

          ;Sets various global and turtle variables using an external .txt file selected
          ;by the user.
          ;
          ;TODO: This could be extracted into its own extension for use by the Netlogo community.
          ;
          ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
          to setup-environment-using-user-selected-file
            file-close ;This must be done just in case the previous file errored out (Netlogo does not reset file pointers automatically).
            file-open user-file
            
            let variable-name ""
            
            while[not file-at-end?][
              set debug-indent-level (debug-indent-level + 1)
              output-debug-message ("EXECUTING THE 'setup-environment-using-user-selected-file' PROCEDURE...") ("")
              set debug-indent-level (debug-indent-level + 1)
              let line file-read-line
              output-debug-message (word "LINE BEING READ FROM EXTERNAL FILE IS: '" line "'") ("")
              
              ifelse(not empty? line)[
                output-debug-message (word "'" line "' IS NOT EMPTY SO IT WILL BE PROCESSED.") ("")
                ifelse(string:rex-match "[a-zA-Z_\\-]+" line )[
                  set variable-name line
                  output-debug-message (word "'" line "' ONLY CONTAINS EITHER ALPHABETICAL CHARACTERS, HYPHENS OR UNDERSCORES SO IT MUST BE A VARIABLE NAME.") ("")
                  output-debug-message (word "THE 'variable-name' VARIABLE IS NOW SET TO: '" variable-name "'.") ("")
                ]
                [
                  ifelse(string:rex-match "\"(.)*\"" line)[
                    output-debug-message (word "'" line "' IS SURROUNDED WITH DOUBLE QUOTES INDICATING THAT THIS IS A NETLOGO COMMAND.  THIS COMMAND SHOULD BE RUN USING THE 'print-and-run' PROCEDURE..." ) ("")
                    print-and-run (read-from-string line)
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
                      )[
                       error (word "ERROR: External model settings file line: '" line "' contains more than one pair of matching parenthesis!" )
                      ]
                      output-debug-message ("NO MORE THAN ONE PAIR OF MATCHING PARENTHESIS EXISTS...")  ("")
                 
                      output-debug-message ("CHECKING FOR A HYPHEN IF MATCHING PARENTHESIS EXIST...") ("")
                      if(
                        (check-for-substring-in-string-and-report-occurrences "(" line) = (check-for-substring-in-string-and-report-occurrences ")" line) and
                        (check-for-substring-in-string-and-report-occurrences "(" line) = 1 and 
                        not member? "-" line 
                      )[
                       error (word "ERROR: External model settings file line: '" line "' does not contain a hyphen in turtle ID specification!" )
                      ]
                      output-debug-message ("LINE CONTAINS A HYPHEN AND ONE PAIR OF MATCHING PARENTHESIS...") ("")
                 
                      output-debug-message ("CHECKING FOR MATCHING PARENTHESIS IF A HYPHEN EXISTS...") ("")
                      if( member? "-" line and not member? "(" line and not member? ")" line )[
                        error (word "ERROR: External model settings file line: '" line "' contains a hyphen but no parenthesis in group ID specification!" )
                      ]
                      output-debug-message ("HYPHEN IS SPECIFIED ALONG WITH MATCHING PARENTHESIS") ("")
                 
                      output-debug-message (word "'" line "' IS FORMATTED CORRECTLY.") ("")
                 
                      ifelse( member? "(" line )[
                        output-debug-message (word "'" line "' CONTAINS A '(' SO THE '" variable-name "' VARIABLE FOR A NUMBER OF TURTLES SHOULD BE SET...") ("")
                   
                        let turtle-id read-from-string ( substring line ( (position "(" line) + 1 ) (position "-" line) )
                        let last-turtle-id read-from-string ( substring line ( (position "-" line) + 1 ) (position ")" line) )
                        let value-specified read-from-string ( substring line ( (position ":" line) + 1 ) (length line) )
                   
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
                        let value-specified read-from-string ( substring line ( (position ":" line) + 1 ) (length line) )
                        output-debug-message (word "TURTLE " turtle-id "'s '" variable-name "' VARIABLE WILL BE SET TO: '" value-specified "'.") ("")
                   
                        ask turtle turtle-id[ 
                          print-and-run (word "set " variable-name " " value-specified)
                        ]
                      ]
                    ]
                    [
                      output-debug-message (word "'" line "' DOES NOT CONTAIN A ':' SO '" variable-name "' IS A GLOBAL VARIABLE AND WILL BE SET TO: '" read-from-string line "'.") ("")
                      print-and-run (word "set " variable-name " " (read-from-string line) )
                    ] 
                  ]
                ]
              ]
              [
                output-debug-message (word "'" line "' IS EMPTY SO IT WILL NOT BE PROCESSED.") ("")
              ]
              
              set debug-indent-level (debug-indent-level - 2)
            ]
          end
          
          ;*******************************************************************************;
          ;*******************************************************************************;
          ;**** "SETUP-ENVIRONMENT-USING-USER-SELECTED-FILE" PROCEDURE SUB-PROCEDURES ****;
          ;*******************************************************************************;
          ;*******************************************************************************;
               
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
               ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com> 
               to print-and-run [string-to-be-run]
                 set debug-indent-level (debug-indent-level + 1)
                 output-debug-message ("EXECUTING THE 'print-and-run' PROCEDURE...") ("")
                 set debug-indent-level (debug-indent-level + 1)
                 output-debug-message (word "NETLOGO COMMAND TO BE PASSED TO 'run' PRIMITIVE: '" string-to-be-run "'.") ("")
                 set debug-indent-level (debug-indent-level - 2)
                 run string-to-be-run
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
          ;
          ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
          to setup-plot-pen [name-of-plot]
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'setup-plot-pen' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message (word "Setting my plot pen for the '" name-of-plot "' plot.") (who)
            set debug-indent-level (debug-indent-level - 2)
            
            set-current-plot name-of-plot
            create-temporary-plot-pen (word "Turtle " who)
            set-current-plot-pen (word "Turtle " who)
            set-plot-pen-interval time-increment
            set-plot-pen-color color
          end

;*********************************************;
;*********************************************;
;********* RUN SIMULATION PROCEDURES *********;
;*********************************************;
;*********************************************;

     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;;;; "PLAY" PROCEDURE ;;;;;
     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

     ;Enables Tileworld games to be played.  The game progresses in the following stages:
     ;  1) Create new tiles and holes.
     ;  2) CHREST turtles act:
     ;    2.1) CHREST turtles determine if they are hidden or not:
     ;      2.1.1) If not hidden, they determine if they are to perform an action in the future
     ;         or now:
     ;        2.1.1.1) If they are scheduled to perform an action in the future, they will not
     ;                 do anything.
     ;        2.1.1.2) If they are scheduled to perform an action now they will generate a visual
     ;                 a visual pattern and check to see if this matches the visual pattern generated
     ;                 when they decided on the action they are to perform now:
     ;          2.1.1.2.1) If the current visual pattern matches the new visual pattern generated, the
     ;                     CHREST turtle will perform their action and then deliberate about what to do
     ;                     next.
     ;          2.1.1.2.2) If the current visual pattern does not match the new visual pattern generated,
     ;                     the CHREST turtle will not perform their action but will deliberate about what
     ;                     to do next.
     ;        2.1.1.3) If they are not scheduled to perform an action in the future or now, they 
     ;                 will generate a visual pattern and deliberate about what to do next.
     ;      2.1.2) If hidden they do not do anything.
     ;    2.2) CHREST turtles update plots
     ;  3) Update environment.
     ;  4) Check end game condition.
     ;
     ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
     to play
       
       set debug-indent-level 0
       
       output-debug-message ("") ("") ;Blank to seperate time increments for readability.
       ifelse(training?)[
         output-debug-message (word "========== TIME: " current-training-time " ==========") ("") 
       ]
       [
         output-debug-message (word "========== TIME: " current-game-time " ==========" ) ("") 
       ]
       set debug-indent-level (debug-indent-level + 1)
       
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;;; CREATE NEW TILES AND HOLES ;;;
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
       output-debug-message ("CHECKING TO SEE IF NEW TILES/HOLES SHOULD BE CREATED...") ("")
       create-new-tiles-and-holes
       
       ;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;;; CHREST TURTLES ACT ;;;
       ;;;;;;;;;;;;;;;;;;;;;;;;;;
       
       output-debug-message ("UPDATING 'chrest-turtles'...") ("")
       set debug-indent-level (debug-indent-level + 1)
       ask chrest-turtles [
         output-debug-message ("Checking the value of my 'hidden?' variable.  If 'false' I should do something in this round, if 'true' I should do nothing...") (who)
         output-debug-message (word "My 'hidden?' variable is set to: '" hidden? "'.") (who)
         
         if(not hidden?)[
           output-debug-message (word "Since 'hidden?' is 'false' I should do something...") (who)
           
           output-debug-message ("Checking to see if I am scheduled to perform an action in the future...") (who)
           ifelse(scheduled-to-perform-action-in-future?)[
             output-debug-message (word "I am scheduled to perfom an action in the future so I'll just update my plots.") (who)
           ]
           [
             output-debug-message ("Checking to see if I am scheduled to perform an action now...") (who)
             ifelse(scheduled-to-perform-action-now?)[
               output-debug-message (word "I'm scheduled to perform an action now.  I'll check to see if my environment has changed since I decided to perform '" next-action-to-perform "'...") (who)
               generate-current-visual-pattern
               
               output-debug-message (word "Checking to see if the value of my 'current-visual-pattern' variable (" current-visual-pattern ") matches the value of my 'visual-pattern-used-to-generate-action' variable (" visual-pattern-used-to-generate-action ")...") (who)
               if(current-visual-pattern = visual-pattern-used-to-generate-action)[
                 output-debug-message (word "The values of my 'current-visual-pattern' and 'visual-pattern-used-to-generate-action' variables are equal so I'll perform '" next-action-to-perform "'...") (who)
                 perform-action (next-action-to-perform)
                 output-debug-message ("Now I need to update my 'current-visual-pattern' variable so I can decide on what to do next...") (who)
                 generate-current-visual-pattern
               ]
               
               output-debug-message ("Now I need to decide upon what to do next...") (who)
               deliberate
             ]
             [
               output-debug-message (word "I am not scheduled to perform an action in the future or now so I'll just deliberate about what to do next...") (who)
               output-debug-message ("I need to update my 'current-visual-pattern' variable so I can decide on what to do next...") (who)
               generate-current-visual-pattern
               output-debug-message ("My 'current-visual-pattern' variable has been updated so I'll decide upon what to do next...") (who)
               deliberate
             ]
           ]
           
           output-debug-message ("Updating my plots...") (who)
           update-plot "Scores" score
           update-plot "Num Visual-Action Links" (chrest:get-ltm-modality-num-action-links "visual")
           update-plot "Visual LTM Size" (chrest:get-ltm-modality-size "visual")
           update-plot "Visual LTM Avg. Depth" (chrest:get-ltm-modality-avg-depth "visual")
           update-plot "Action LTM Size" (chrest:get-ltm-modality-size "action")
           update-plot "Action LTM Avg. Depth" (chrest:get-ltm-modality-avg-depth "action")
           update-plot "Visual STM Size" (chrest:get-stm-modality-size "visual")
           update-plot "Action STM Size" (chrest:get-stm-modality-size "action")
         ]
       ]
       set debug-indent-level (debug-indent-level - 1)
       
       ;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;;; UPDATE ENVIRONMENT ;;;
       ;;;;;;;;;;;;;;;;;;;;;;;;;;
       
       output-debug-message ("UPDATING THE ENVIRONMENT...") ("")
       update-environment
       
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       ;;; CHECK END GAME CONDITION ;;;
       ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
       
       output-debug-message ("CHECKING TO SEE IF THERE ARE ANY NON-TILE/HOLE TURTLES STILL PLAYING (VISIBLE)...") ("")
       if(player-turtles-finished?)[
         stop
       ]
     end
     
     ;*******************************;
     ;*******************************;
     ;**** "PLAY" SUB-PROCEDURES ****;
     ;*******************************;
     ;*******************************;
     
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;;;; "CREATE-NEW-TILES-AND-HOLES" PROCEDURE ;;;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Used to determine whether new tiles and holes should be created in the 
          ;simulation environment.
          ;
          ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
          to create-new-tiles-and-holes
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'create-new-tiles-and-holes' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("CHECKING GAME CONTEXT (TRAINING OR NON-TRAINING)...") ("")
            
            no-display
            
            ifelse(training?)[
              output-debug-message ("GAME IS BEING PLAYED IN A TRAINING CONTEXT: THE 'current-training-time' VARIABLE SHOULD BE USED TO DETERMINE IF HOLES/TILES SHOULD BE CREATED.") ("")
              output-debug-message (word "REMAINDER OF DIVIDING '" current-training-time "' BY '" tile-born-every "' IS: '" remainder current-training-time tile-born-every "'.") ("")
              
              if(remainder current-training-time tile-born-every = 0)[
                output-debug-message ("A NEW TILE SHOULD BE GIVEN THE CHANCE TO BE CREATED NOW.") ("")
                create-a ("tiles")
              ]
              
              output-debug-message (word "REMAINDER OF DIVIDING '" current-training-time "' BY '" hole-born-every "' IS: '" remainder current-training-time hole-born-every "'.") ("")
              
              if(remainder current-training-time hole-born-every = 0)[
                output-debug-message ("A NEW HOLE SHOULD BE GIVEN THE CHANCE TO BE CREATED NOW.") ("")
                create-a ("holes")
              ]
            ]
            [
              output-debug-message ("GAME IS BEING PLAYED IN A NON-TRAINING CONTEXT: THE 'current-game-time' VARIABLE SHOULD BE USED TO DETERMINE IF HOLES/TILES SHOULD BE CREATED.") ("")
              output-debug-message (word "REMAINDER OF DIVIDING '" current-game-time "' BY '" tile-born-every "' IS: '" remainder current-game-time tile-born-every "'.") ("")
              
              if(remainder current-game-time tile-born-every = 0)[
                output-debug-message ("A NEW TILE SHOULD BE GIVEN THE CHANCE TO BE CREATED NOW.") ("")
                create-a ("tiles")
              ]
              
              output-debug-message (word "REMAINDER OF DIVIDING '" current-game-time "' BY '" hole-born-every "' IS: '" remainder current-game-time hole-born-every "'.") ("")
              
              if(remainder current-game-time hole-born-every = 0)[
                output-debug-message ("A NEW HOLE SHOULD BE GIVEN THE CHANCE TO BE CREATED NOW.") ("")
                create-a ("holes")
              ]
            ]
            
            display
            set debug-indent-level (debug-indent-level - 2)
          end
          
          ;*****************************************************;
          ;*****************************************************;
          ;**** "CREATE-NEW-TILES-AND-HOLES" SUB-PROCEDURES ****;
          ;*****************************************************;
          ;*****************************************************;
          
               ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
               ;;;;; "CREATE-A" PROCEDURE ;;;;;
               ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
               ;Probabilistically creates a new turtle of the specified breed 
               ;in the environment according to breed-specific instructions.
               ;
               ;         Name              Data Type     Description
               ;         ----              ---------     -----------
               ;@params  breed-name        String        The breed of turtle that should be created.
               ;
               ;TODO: add a check to see if the string passed as 'breed-name' is
               ;      an actual breed ('is-turtle-set?' or 'is-agentset?' could 
               ;      be used).  Remember that Netlogo stores breed names in upper-
               ;      case so 'breed-name' must be upper-case.
               ;
               ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
               to create-a [breed-name]
                 set debug-indent-level (debug-indent-level + 1)
                 output-debug-message ("EXECUTING THE 'create-a' PROCEDURE...") ("")
                 set debug-indent-level (debug-indent-level + 1)
                 output-debug-message ("CHECKING TO SEE IF A NEW HOLE SHOULD BE CREATED...") ("")
                 
                 ifelse(breed-name = "tiles")[
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
                 [
                   ifelse(breed-name = "holes")[
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
                   [
                     error (word "The breed specified (" breed-name ") does not exist.")
                   ]
                 ]
                 
                 set debug-indent-level (debug-indent-level - 2)
               end
               
               ;***********************************;
               ;***********************************;
               ;**** "CREATE-A" SUB-PROCEDURES ****;
               ;***********************************;
               ;***********************************;
               
                    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                    ;;;;; "PLACE-RANDOMLY" PROCEDURE ;;;;;
                    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
                    ;Places the calling turtle on a random patch in the environment. If the patch 
                    ;that the calling turtle is placed on already contains a turtle that is visible, 
                    ;the calling turtle is placed on another random patch. This process repeats until 
                    ;the calling turtle is placed on a patch that only contains the calling turtle (and
                    ;a hidden turtle, potentially). 
                    to place-randomly
                      set debug-indent-level (debug-indent-level + 1)
                      output-debug-message ("EXECUTING THE 'place-randomly' PROCEDURE...") ("")
                      set debug-indent-level (debug-indent-level + 1)
            
                      setxy random-pxcor random-pycor
                      output-debug-message (word "I've set my xcor to: '" xcor "' and ycor to '" ycor "'.  Checking to see if this patch is free..." ) (who)
            
                      while[ ( count (turtles-here with [hidden? = false]) ) > 1][
                        output-debug-message (word "The patch with xcor: '" xcor "' and ycor '" ycor "'.  Already has a visible turtle on it, selecting new values for my 'xcor' and 'ycor' variables..." ) (who)
                        setxy random-pxcor random-pycor
                      ]
                      output-debug-message(word "Patch with xcor '" xcor "' and ycor '" ycor "' does not contain any visible turtles so I'm staying here.") (who)
            
                      set debug-indent-level (debug-indent-level - 2)
                    end
          
               ;;;;;;;;;;;;;;;;;;;;;;;;;;;
               ;;;;; "AGE" PROCEDURE ;;;;;
               ;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Decreases the calling turtle's "time-to-live" variable by 0.1.
          ;If the calling turtles "time-to-live" variable is less than
          ;or equal to 0, the turtle dies.
          ;
          ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
          to age
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'age' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message (word "My 'time-to-live' variable is set to: '" time-to-live "' and I will age by: '" time-increment "'...") (who)
            
            set time-to-live precision (time-to-live - time-increment) 1
            output-debug-message (word "My 'time-to-live' variable is now set to: '" time-to-live "'.  If this is equal to 0, I will die.") (who)
            
            if(time-to-live <= 0)[
              output-debug-message (word "My 'time-to-live' variable is equal to : '" time-to-live "' so I will now die.") (who)
              
              ask chrest-turtles[
                if(myself = closest-tile)[
                  set closest-tile ""
                ]
              ]
              
              set debug-indent-level (debug-indent-level - 2)
              die
            ]
            
            set debug-indent-level (debug-indent-level - 2)
          end

          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "ALTER-HEADING-RANDOMLY-BY-ADDING-OR-SUBTRACTING-90" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Alters the calling turtle's heading randomly by adding or subtracting
          ;90.  So, if the calling turtle is facing:
          ; - North (0): calling turtle will turn east or west.
          ; - East (90): calling turtle will turn north or south.
          ; - South (180): calling turtle will turn east or west.
          ; - West (270): calling turtle will turn north or south.
          ;
          ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
          to alter-heading-randomly-by-adding-or-subtracting-90
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'alter-heading-randomly-by-adding-or-subtracting-90' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            
            ifelse( (random 2) = 0)[
              output-debug-message ("Altering current heading by adding 90.") (who)
              set heading ( heading + 90 )
            ]
            [ 
              output-debug-message ("Altering current heading by subtracting 90.") (who)
              set heading ( heading - 90 )
            ]
            
            output-debug-message (word "My 'heading' variable is now set to: '" heading "'.") (who)
            set debug-indent-level (debug-indent-level - 2)
          end
          
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "ANY-TILES-ON-PATCH-AHEAD?" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Reports boolean true or false depending upon whether or not there is a tile
          ;on the patch immediately ahead of the calling turtle along its current heading.
          ;
          ;         Name              Data Type     Description
          ;         ----              ---------     -----------
          ;@returns -                 Boolean       True if there is a turtle whose 'breed'
          ;                                         variable value is equal to 'tiles' on 
          ;                                         the patch immediately ahead of the 
          ;                                         calling turtle along its current heading.
          ;                                         False is reported if not.
          ;
          ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
          to-report any-tiles-on-patch-ahead?
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'any-tiles-on-patch-ahead?' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            
            output-debug-message(word "Checking to see if there are any tiles on the patch immediately ahead with heading: " heading "...") (who)
            ifelse(any? tiles-on patch-at-heading-and-distance (heading) (1))[
              output-debug-message(word "There are tiles on the patch immediately ahead with heading: " heading ".  Reporting true...") (who)
              set debug-indent-level (debug-indent-level - 2)
              report true
            ]
            [
              output-debug-message(word "There aren't any tiles on the patch immediately ahead with heading: " heading ".  Reporting false...") (who)
              set debug-indent-level (debug-indent-level - 2)
              report false
            ] 
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
          ;@returns -                 Integer       The number of occurrences of needle in haystack.
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
          
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "CONVERT-SECONDS-TO-MILLISECONDS" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Primarily used to enable the CHREST architectures in CHREST turtles 
          ;to be able to perform their operations based upon the time kept by 
          ;this Netlogo model.
          ;
          ;         Name              Data Type     Description
          ;         ----              ---------     -----------
          ;@param   seconds           Number        A measure of time in seconds.
          ;@returns -                 Number        The value of "seconds" in milliseconds with no 
          ;                                         significant figures.
          ;
          ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
          to-report convert-seconds-to-milliseconds [seconds]
            report (precision (seconds * 1000) (0))
          end
          
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "CONVERT-MILLISECONDS-TO-SECONDS" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Primarily used to convert CHREST architecture times in CHREST turtles 
          ;into Netlogo model time.
          ;
          ;         Name              Data Type     Description
          ;         ----              ---------     -----------
          ;@param   milliseconds      Number        A measure of time in milliseconds.
          ;@returns -                 Number        The value of "milliseconds" in seconds with one 
          ;                                         significant figure.
          ;
          ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
          to-report convert-milliseconds-to-seconds [milliseconds]
            report (precision (milliseconds / 1000) (1))
          end
          
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "CORRECTLY-POSITIONED-TO-PUSH-CLOSEST-TILE-TO-CLOSEST-HOLE?" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Used to determine if the calling turtle is correctly positioned to push the
          ;tile closest to the calling turtle's closest hole towards the closest hole 
          ;(is the closest tile to the turtle's closest hole 1 patch away along the 
          ;heading passed?).
          ;
          ;         Name              Data Type     Description
          ;         ----              ---------     -----------
          ;@param   heading-to-check  Number        The heading along which to check for
          ;                                         the closest tile.
          ;@returns -                 Boolean       True if the closest tile is 1 patch 
          ;                                         away along heading-to-check, false 
          ;                                         if not.
          ;
          ;@author  Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
          to-report correctly-positioned-to-push-closest-tile-to-closest-hole? [heading-to-check]
            ifelse(member? (turtle (first ([who] of closest-tile))) (turtles-on patch-at-heading-and-distance (heading-to-check) (1)))[
              report true
            ]
            [
              report false
            ]
          end
          
          
          
          
          
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "DELIBERATE" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Enables a calling turtle to deliberate about what action to perform next.  This is a very complex
          ;procedure and as such is outlined in full below:
          ;
          ; 1) The calling turtle's breed is checked.  If it is a chrest-turtle then deliberation continues.
          ; 2) The calling turtle's 'time-to-perform-next-action' variable is reset to -1 and a local 
          ;    'actions-associated-with-visual-pattern' list variable is created.
          ; 3) The calling turtle generates a new visual pattern and stores it in its 'current-visual-pattern'
          ;    variable.  This variable is then checked to see if it is empty.  If it isn't then the local 
          ;    'actions-associated-with-visual-pattern' variable is set to the result of the calling turtle's 
          ;    CHREST architecture retrieving any action patterns associated with the visual pattern contained 
          ;    in the calling turtle's 'current-visual-pattern' variable.  This will return a Netlogo list.
          ; 4) The local 'actions-associated-with-visual-pattern' variable is checked to see if it is empty.
          ;    4.1) If it isn't then the number of items in the list is checked.
          ;       4.1.2) If there is more than one item in the list then one of the list items is selected at
          ;              random and is then passed to the 'load-action' procedure so that it can be executed.
          ;       4.1.3) If there is only one item in the list then this is passed to the 'load-action' 
          ;              procedure so that it can be executed.   
          ;    4.2) If it is then an action to perform is selected using heuristics.
          ;       4.2.1) The calling turtle's 'current-visual-pattern' variable is checked to see if it 
          ;              contains any tiles.
          ;          4.2.1.1) If tiles can be seen then the calling turtle checks to see if its 
          ;                   'current-visual-pattern' variable also contains holes.
          ;                4.2.1.1.1) If the calling turtle can see any holes it will call the 
          ;                           'generate-push-closest-tile-to-closest-hole-action' procedure.
          ;                4.2.1.1.2) If the calling turtle can not see any holes it will call the 
          ;                           'generate-move-to-or-push-closest-tile-action' procedure.
          ;          4.2.1.2) If tiles can not be seen then the calling turtle will call the 
          ;                   'generate-random-move-action' procedure.
          to deliberate
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'deliberate' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("Checking to see if I am a chrest-turtle...") (who)
            
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            ;;; CHECK BREED OF CALLING TURTLE ;;;
            ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
            
            if(breed = chrest-turtles)[
              output-debug-message ("I am a chrest-turtle so I can continue to deliberate.") (who)
              
              output-debug-message ("Setting the local 'actions-associated-with-visual-pattern' variable to an empty list...") (who)
              let actions-associated-with-visual-pattern []
              output-debug-message (word "The local 'actions-associated-with-visual-pattern' variable is set to: " actions-associated-with-visual-pattern "...") (who)
              
              output-debug-message (word "Checking to see if my 'current-visual-pattern' variable: '" current-visual-pattern "' is empty...") (who)
              if(not empty? current-visual-pattern)[
                output-debug-message (word "'" current-visual-pattern "' isn't empty so I'll check to see if I have any action-patterns associated with it in LTM...") (who)
                output-debug-message ("If I do, I'll add these action-patterns to the local 'actions-associated-with-visual-pattern' variable...") (who)
                set actions-associated-with-visual-pattern (chrest:recognise-pattern-and-return-patterns-of-specified-modality ("visual") ("item_square") (current-visual-pattern) ("action"))
              ]
              output-debug-message (word "The 'actions-associated-with-visual-pattern' variable is now set to: '" actions-associated-with-visual-pattern "'.") (who)
              
              output-debug-message (word "Checking to see if the 'actions-associated-with-visual-pattern' variable value is empty...") (who)
              ifelse(not empty? actions-associated-with-visual-pattern)[
                output-debug-message (word "The 'actions-associated-with-visual-pattern' variable value is not empty.  Checking to see how many items there are in this list...") (who)
                output-debug-message (word "I have " length actions-associated-with-visual-pattern " action-patterns associated with '" current-visual-pattern ".") (who)
                
                if( (length actions-associated-with-visual-pattern) > 1 )[
                  output-debug-message (word "I have more than one action associated with '" current-visual-pattern "' so I'll pick one of the actions to perform at random...") (who)
                  let action-to-perform ( item (random length actions-associated-with-visual-pattern) actions-associated-with-visual-pattern )
                  output-debug-message (word "The action I will perform is: '" action-to-perform "', loading this action for execution...") (who)
                  load-action (action-to-perform)
                ]
                
                if( ( length actions-associated-with-visual-pattern ) = 1 )[
                  output-debug-message (word "I only have one action associated with '" current-visual-pattern "' so I'll perform that action...") (who)
                  let action-to-perform item 0 actions-associated-with-visual-pattern
                  output-debug-message (word "The action I will perform is: '" action-to-perform "', loading this action for execution...") (who)
                  load-action (action-to-perform)
                ]
              ]
              [
                output-debug-message (word "I have no actions associated with '" current-visual-pattern "' so I'll figure out what to using a heuristic.  First, I need to check if I can see any tiles...") (who)
                let number-of-tiles (check-for-substring-in-string-and-report-occurrences ("T") (current-visual-pattern) )
                output-debug-message (word "I can see " number-of-tiles " tiles" ) (who)
                
                ifelse( number-of-tiles > 0)[
                  output-debug-message ("I can see one or more tiles, checking if I can see any holes...") (who)
                  
                  let number-of-holes ( check-for-substring-in-string-and-report-occurrences ("H") (current-visual-pattern) )
                  output-debug-message (word "I can see " number-of-holes " holes") (who)
                    
                  ifelse(number-of-holes > 0)[
                    output-debug-message ("Since I can see one or more tiles and holes, I'll try to push the tile closest to my closest hole into my closest hole...") (who)
                    generate-push-closest-tile-to-closest-hole-action
                  ]
                  [
                    output-debug-message ("I can't see a hole, I'll either move to my closest tile if its not adjacent to me or turn to face it and push it along this heading if it is...") (who)
                    generate-move-to-or-push-closest-tile-action
                  ] 
                ]
                [
                  output-debug-message ("I can't see any tiles, I'll just select a random heading to move 1 patch forward...") (who)
                  generate-random-move-action
                ]
              ]
            ]
            set debug-indent-level (debug-indent-level - 2)
          end
          
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "GENERATE-CURRENT-VISUAL-PATTERN" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Generates a visual pattern and sets it to the calling turtle's 'current-visual-pattern'
          ;variable.  The calling turtle will scan its viewable area (dictated by the value of its 
          ;'sight-radius' variable) from south-west to north-east.
          to generate-current-visual-pattern
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'generate-current-visual-pattern' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            
            output-debug-message (word "My 'current-visual-pattern' is set to: '" current-visual-pattern "'.  I'll clear it now...") (who)
            set current-visual-pattern ""
            output-debug-message (word "My 'current-visual-pattern' variable is now set to: '" current-visual-pattern "'") (who)
            
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
              
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;;;CHECK FOR VISIBLE TURTLES THAT AREN'T 'tiles' OR 'holes' ;;;
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
              if((any? (turtles-at xCorOffset yCorOffset) with [hidden? = false and breed != tiles and breed != holes]) and 
                 (not member? self turtles-at xCorOffset yCorOffset) 
              )[
                set current-visual-pattern (word current-visual-pattern chrest:create-item-square-pattern turtle-token xCorOffset yCorOffset)
                output-debug-message (word "There is another turtle that is not hidden, not myself, not a tile and not a hole in my sight-radius.  My 'current-visual-pattern' variable is now set to: '" current-visual-pattern "'.") (who)
              ]
              
              ;;;;;;;;;;;;;;;;;;;;;;
              ;;;CHECK FOR TILES ;;;
              ;;;;;;;;;;;;;;;;;;;;;;
              
              if( (any? tiles-at xCorOffset yCorOffset) )[
                set current-visual-pattern (word current-visual-pattern chrest:create-item-square-pattern tile-token xCorOffset yCorOffset)
                output-debug-message (word "There is a tile in my sight-radius.  My 'current'visual-pattern' variable is now set to: '" current-visual-pattern "'.") (who)
               ]
               
               ;;;;;;;;;;;;;;;;;;;;;;;
               ;;; CHECK FOR HOLES ;;;
               ;;;;;;;;;;;;;;;;;;;;;;;
               
               if( (any? holes-at xCorOffset yCorOffset) )[
                 set current-visual-pattern (word current-visual-pattern chrest:create-item-square-pattern hole-token xCorOffset yCorOffset)
                 output-debug-message(word "There is a hole in my sight-radius.  My 'current-visual-pattern' variable is now set to: '" current-visual-pattern "'.") (who)
               ]
               
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
             
             output-debug-message (word "After updating my 'current-visual-pattern' variable, its final value is: '" current-visual-pattern "'.") (who)
             set debug-indent-level (debug-indent-level - 2)
          end
          
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "GENERATE-MOVE-TO-OR-PUSH-TILE-ACTION" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Generates a "push-tile" action pattern for the calling turtle that enables it to push 
          ;the calling turtle's closest tile along the heading of the calling turtle after it has 
          ;turned to face its closest tile.
          ;
          ;If the path of the calling turtle's closest tile along this heading is not clear, the 
          ;calling turtle will alter its current heading by +/- 90 and a "move-around-tile" action 
          ;pattern will be generated instead of a "push-tile" action pattern.  
          ;
          ;@author Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
          to generate-move-to-or-push-closest-tile-action
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'generate-push-tile-action' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            
            if(not surrounded?)[
              output-debug-message ("I'm not surrounded so I'll set my 'closest-tile' variable value to be equal to one of the tiles closest to me...") (who) 
              set closest-tile min-one-of tiles [distance myself]
              output-debug-message (word "The 'who' variable value of the tile indicated by the value of my 'closest-tile' value is: " [who] of closest-tile "...") (who)
              let action-pattern ""
              
              output-debug-message (word "Checking to see how far away my closest-tile is from me (" distance closest-tile ")...") (who)
              ifelse(distance closest-tile > 1)[
                output-debug-message ("My closest tile is more than 1 patch away so I need to move closer to it.") (who)
                output-debug-message ("I'll face the tile indicated in my 'closest-tile' variable and then rectify my heading from there...") (who)
                face closest-tile
                set heading (rectify-heading(heading))
                output-debug-message (word "My heading is now set to: " heading "...") (who)
                output-debug-message (word "Checking to see if there is anything in the way along this heading...") (who)
                
                ;Only need to check for visible turtles that aren't tiles here since if there were another
                ;tile on the patch to be moved to, this would be the tile being pushed.  For example: there
                ;would never be a situation where the turtle decides to move north to be adjacent to a tile 
                ;that is north-east of it and there is a tile immediately north of it which would need to be 
                ;moved out of the way.  In this case, the tile to the north would be the one that would be 
                ;pushed in the first place.
                while[not way-clear?][
                  output-debug-message (word "There is something on the patch ahead along heading " heading " so I'll alter my heading randomly by +/- 90 to get around it...") (who)
                  alter-heading-randomly-by-adding-or-subtracting-90
                ]
                output-debug-message (word "The patch immediately ahead with heading " heading " is free, so I'll move there...") (who)
                
                output-debug-message (word "Generating the action pattern...") (who)
                set action-pattern (chrest:create-item-square-pattern move-to-tile-token heading 1)
              ]
              [
                output-debug-message ("My closest tile is 1 patch away from me or less so I'll turn to face it and attempt to push it...")(who)
                face closest-tile
                output-debug-message ("Checking to see if there is anything blocking my closest tile from being pushed (other players or tiles, holes can't block a tile)...") (who)
                
                ifelse(any? (turtles-on (patch-at-heading-and-distance (heading) (2)) ) with [ (breed != holes) and (hidden? = false) ] )[
                  output-debug-message ("There are turtles on the patch in front of the tile I am facing that aren't holes so I'll have to move around the tile to try and push it from another direction...") (who)
                  alter-heading-randomly-by-adding-or-subtracting-90
                  output-debug-message (word "Checking to see if the patch immediately ahead with heading " heading " is clear...") (who)
                  
                  while[ 
                    ( any? (turtles-on (patch-at-heading-and-distance (heading) (1))) with [breed != tiles] and hidden? = false) or
                    ( (any? (turtles-on (patch-at-heading-and-distance (heading) (1))) with [breed = tiles]) and (any? (turtles-on patch-at-heading-and-distance (heading) (2)) with [breed != holes] and hidden? = false) )
                  ]
                  [ 
                    output-debug-message (word "There is something on the patch ahead with heading " heading "; either a non-tile or a tile that is blocked...") (who)
                    output-debug-message ("I'll alter my current heading by +/- 90 and check again...") (who)
                    alter-heading-randomly-by-adding-or-subtracting-90
                  ]
                  output-debug-message (word "The patch ahead with heading " heading " is either free or has a tile that can be pushed on it.  Checking to see if I need to push a tile or not...") (who)
                
                  ifelse(any-tiles-on-patch-ahead?)[
                    output-debug-message ("Since there is a tile on the patch immediately along my current heading, I'll push this tile out of the way..." ) (who)
                    output-debug-message ("Generating the action pattern...") (who)
                    set action-pattern (chrest:create-item-square-pattern push-tile-token heading 1)
                  ]
                  [
                    output-debug-message ("There isn't a tile on the patch immediately along my current heading so I'll generate a 'move-to-tile' action pattern...") (who)
                    output-debug-message ("Generating the action pattern...") (who)
                    set action-pattern (chrest:create-item-square-pattern move-around-tile-token heading 1)
                  ]
                ]
                [
                  output-debug-message ("There aren't any turtles on the patch in front of the tile I am facing (or there is a hole there) so I'll push this tile...") (who)
                  output-debug-message ("Now I'll generate the action pattern...") (who)
                  set action-pattern (chrest:create-item-square-pattern push-tile-token heading 1)
                ]
              ]
              
              output-debug-message (word "Action pattern generated: '" action-pattern "'.  Checking to see if its empty, if not, I'll load it for execution...") (who)
              if(not empty? action-pattern)[
                output-debug-message("The local 'action-pattern' variable is not empty, loading it for execution...") (who)
                load-action (action-pattern)
              ]
            ]
            
            set debug-indent-level (debug-indent-level - 2)
          end
          
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "GENERATE-PUSH-CLOSET-TILE-TO-CLOSEST-HOLE" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          to generate-push-closest-tile-to-closest-hole-action
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'generate-push-closest-tile-to-closest-hole-action' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
           
            output-debug-message ("Checking to see if I'm surrounded, if I am, I can't push one of my closest tiles towards one of my closest holes...") (who)
            if(not surrounded?)[
              
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;;; DETERMINE CLOSEST HOLE ;;;
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              
              output-debug-message ("I'm not surrounded, I'll now calculate what tile(s) is(are) closest to the closest hole(s) I can see...") (who)
              output-debug-message ("I'll push the tile closest to my closest hole towards my closest hole or move towards this tile.  If more than one tile is a candidate I'll pick the tile closest to myself to push...") (who)
              let closest-hole min-one-of holes [distance myself]
              output-debug-message (word "My closest hole's 'who' variable is: " [who] of closest-hole "...") (who)
              
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;;; POPULATE 'percepts' LIST ;;;
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              
              output-debug-message ("Populating the local 'percepts' list; this will contain the individual objects I can currently see...") (who)
              let percepts (string:rex-split (current-visual-pattern) ("\\]"))
              output-debug-message (word "Based upon the value of my 'current-visual-pattern' variable, I can see " length percepts " objects...") (who)
              
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;;; POPULATE "tiles-visible" LIST WITH TILES THAT CAN BE SEEN ;;;
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             
              output-debug-message ("I'll now go through and add the objects that are tiles to the local 'visible-tiles' list...") (who)
              let visible-tiles []
              
              foreach(percepts)[
                output-debug-message (word "Checking to see if '" ? "' is a tile...") (who)
               
                if( (check-for-substring-in-string-and-report-occurrences ("T") (?)) > 0)[
                  output-debug-message (word "'" ? "' is a tile, splitting this string up when a space is encountered and setting the results to the local 'percept-units' variable...") (who)
                  let percept-units (string:rex-split (?) ("\\s"))
                 
                  output-debug-message ("Setting the local 'xCorOffset' and 'yCorOffset' variables...") (who)
                  let xCorOffset (read-from-string (item (1) (percept-units)))
                  let yCorOffset (read-from-string (item (2) (percept-units)))
                  output-debug-message (word "The local 'xCorOffset' variable value is set to: " xCorOffset " and the local 'yCorOffset' variable value is set to: " yCorOffset "...") (who)
                 
                  output-debug-message ("Putting the tile at this x/yCorOffset from myself to the end of the local 'visible-tiles' list...") (who)
                  set visible-tiles ( lput ( tiles-at (xCorOffset) (yCorOffset) ) ( visible-tiles ) )
                ]
              ]
              output-debug-message (word "The local 'visible-tiles' list is set to: " visible-tiles "...") (who)
              
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;;; CALCULATE DISTANCE BETWEEN VISIBLE TILES AND CLOSEST HOLE ;;;
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              
              output-debug-message ("Now I'll calculate the distance of each tile in 'visible-tiles' from my closest hole and add each value to the local 'distances-from-visible-tiles-to-closest-hole' list...") (who)
              let distances-from-visible-tiles-to-closest-hole []
              
              foreach(visible-tiles)[
                ask ? [
                  set distances-from-visible-tiles-to-closest-hole (lput (distance closest-hole) (distances-from-visible-tiles-to-closest-hole))
                ]
              ]
              output-debug-message (word "The 'distances-from-visible-tiles-to-closest-hole' list is now set to: " distances-from-visible-tiles-to-closest-hole "...") (who)
              output-debug-message ("Each item in the 'distances-from-visible-tiles-to-closest-hole' list now corresponds to each item in the 'visible-tiles' list (in the same order)...") (who)
              
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;;; CALCULATE WHICH VISIBLE TILES ARE CLOSEST TO THE CLOSEST HOLE ;;;
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
             
              output-debug-message ("Setting the minimum value of the 'distances-from-visible-tiles-to-closest-hole' list to the local 'min-distance-of-visible-tiles-to-closest-hole' variable...") (who)
              let min-distance-of-visible-tiles-to-closest-hole (min distances-from-visible-tiles-to-closest-hole)
              output-debug-message (word "The local 'min-distance-of-visible-tiles-to-closest-hole' variable value is now set to: " min-distance-of-visible-tiles-to-closest-hole "...") (who)
              output-debug-message (word "Checking each value in the 'distances-from-visible-tiles-to-closest-hole' list to see if it equals: " min-distance-of-visible-tiles-to-closest-hole "...") (who)
              output-debug-message ("If a value does match, the 'who' value of the tile will be added to the local 'candidate-tiles' list...") (who)  
              let candidate-tiles []
              let position-being-checked 0
              
              foreach(distances-from-visible-tiles-to-closest-hole)[
                if( ? = min-distance-of-visible-tiles-to-closest-hole )[
                  set candidate-tiles (lput (item (position-being-checked) (visible-tiles)) (candidate-tiles))
                ]
                set position-being-checked (position-being-checked + 1)
              ]
              output-debug-message (word "The 'candidate-tiles' list is now set to: " candidate-tiles ", checking to see how many candidate tiles there are (" length candidate-tiles ")...") (who)
              
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;;; DECIDE ON WHAT TILE IS THE CLOSEST TO MY CLOSEST HOLE ;;;
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              
              ifelse(length candidate-tiles = 1)[
                output-debug-message ("I have only one candidate tile so I'll attempt to push this tile towards my closest hole...") (who)
                set closest-tile (first candidate-tiles)
              ]
              [
                output-debug-message ("I have more than one candidate tile so I'll pick the tile closest to me to push towards my closest hole...") (who)
                output-debug-message ("If there is more than one candidate tile equidistant closest to me I'll just pick one tile from all candidates randomly...") (who)
                
                output-debug-message ("Calculating distances of each tile in the local 'candidate-tiles' variable from myself and putting these distances into the local 'distances-from-candidate-tiles-to-myself' variable...") (who)
                let distances-from-candidate-tiles-to-myself []
                foreach(candidate-tiles)[
                  ask ? [
                    set distances-from-candidate-tiles-to-myself (lput (distance myself) (distances-from-candidate-tiles-to-myself) )
                  ]
                ]
                output-debug-message (word "The local 'distances-from-candidate-tiles-to-myself' list is set to: " distances-from-candidate-tiles-to-myself "...") (who)
                
                output-debug-message ("Setting the minimum value in the local 'distances-from-candidate-tiles-to-myself' list to the value of the local 'min-distance-from-candidate-tiles-to-myself' variable...") (who)
                let min-distance-from-candidate-tiles-to-myself (min distances-from-candidate-tiles-to-myself)
                output-debug-message (word "The local 'min-distance-from-candidate-tiles-to-myself' variable value is now set to: " min-distance-from-candidate-tiles-to-myself "...") (who)
                
                output-debug-message ("Now I'll populate the local 'candidate-tiles-closest-to-me' with the positions of each item in 'distances-from-candidate-tiles-to-myself' that matches the value of 'min-distance-from-candidate-tiles-to-myself'...") (who)
                output-debug-message ("These positions will equal the position of tiles in the 'candidate-tiles' list and so I'll be able to choose one of the candidate tiles to be my closest-tile...") (who)
                let candidate-tiles-closest-to-me []
                set position-being-checked 0
                
                foreach(distances-from-candidate-tiles-to-myself)[
                  if(? = min-distance-from-candidate-tiles-to-myself)[
                    set candidate-tiles-closest-to-me (lput (position-being-checked) (candidate-tiles-closest-to-me))
                  ]
                  set position-being-checked (position-being-checked + 1)
                ]
                output-debug-message (word "The 'candidate-tiles-closest-to-me' variable is now set to: " candidate-tiles-closest-to-me ".  Picking one of these to be my closest tile...") (who)
                set closest-tile (item (one-of candidate-tiles-closest-to-me) (candidate-tiles) )
              ]
              output-debug-message (word "The closest tile's 'who' value is: " [who] of closest-tile "...") (who)
              
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;;; CHECK DISTANCE BETWEEN MYSELF AND CLOSEST TILE ;;;
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              
              let action-pattern ""
              
              output-debug-message (word "Checking to see how far the closest tile is from me in patches (" [distance myself] of closest-tile ")...") (who)
              
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;;; CLOSEST TILE IS NOT ADJACENT TO ME ;;;
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              
              ifelse( (first ([distance myself] of closest-tile)) > 1)[
                output-debug-message ("My closest tile is more than 1 patch away so I need to move closer to it.") (who)
                
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;;; SET HEADING DEPENDING UPON HEADING OF MYSELF TO CLOSEST TILE ;;;
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
                output-debug-message ("I'll face the tile indicated in my 'closest-tile' variable and then rectify my heading from there...") (who)
                face turtle (first ([who] of closest-tile))
                set heading (rectify-heading (heading))
                output-debug-message (word "My heading is now set to: " heading "...") (who)
                output-debug-message (word "Checking to see if there are any objects other than tiles on the patch ahead, if there is a tile, I'll check to see if it is blocked from being pushed...") (who)
                
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;;; CHECK TO SEE IF THERE IS AN UNMOVEABLE OBSTACLE ALONG HEADING TO CLOSEST TILE ;;;
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
                ;No need for a 'headings-tried' killswitch here in the 'while' conditional since
                ;the turtle checks to see if it is surrounded when this procedure starts so there
                ;must be a free path if it gets to here.
                ;
                ;Unlike the 
                while[ 
                  ( any? (turtles-on (patch-at-heading-and-distance (heading) (1))) with [breed != tiles] and hidden? = false) or
                  ( (any? (turtles-on (patch-at-heading-and-distance (heading) (1))) with [breed = tiles]) and (any? (turtles-on patch-at-heading-and-distance (heading) (2)) with [breed != holes] and hidden? = false) )
                ]
                [ 
                  output-debug-message (word "There is something on the patch ahead with heading " heading "; either a non-tile or a tile that is blocked...") (who)
                  output-debug-message ("I'll alter my current heading by +/- 90 and check again...") (who)
                  alter-heading-randomly-by-adding-or-subtracting-90
                ]
                output-debug-message (word "The patch ahead with heading " heading " is either free or has a tile that can be pushed on it.  Checking to see if I need to push a tile or not...") (who)
                
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;;; CHECK TO SEE IF I NEED TO PUSH A TILE TO MOVE ALONG HEADING OR NOT ;;;
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
                ifelse(any-tiles-on-patch-ahead?)[
                  output-debug-message ("Since there is a tile on the patch immediately along my current heading, I'll set this to be my closest-tile so that it is pushed when the 'push-tile' action I'm to generate is performed..." ) (who)
                  set closest-tile (tiles-on patch-at-heading-and-distance (heading) (1))
                  output-debug-message ("Generating the action pattern...") (who)
                  set action-pattern (chrest:create-item-square-pattern push-tile-token heading 1)
                ]
                [
                  output-debug-message ("There isn't a tile on the patch immediately along my current heading so I'll generate a 'move-to-tile' action pattern...") (who)
                  output-debug-message ("Generating the action pattern...") (who)
                  set action-pattern (chrest:create-item-square-pattern move-to-tile-token heading 1)
                ] 
              ]
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              ;;; CLOSEST TILE IS ADJACENT TO ME ;;;
              ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
              [
                output-debug-message ("My closest tile is adjacent to me (one patch away) so I should decide whether to push it into my closest hole (if possible), wait or re-position myself...") (who)
                
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;;; CALCULATING LOCATION OF CLOSEST HOLE RELATIVE TO CLOSEST TILE ;;;
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
                output-debug-message ("Calculating where the closest tile is in relation to my closest hole...")(who)
                let heading-of-closest-tile-along-shortest-distance-to-closest-hole ""
                ask closest-tile[
                  set heading-of-closest-tile-along-shortest-distance-to-closest-hole (towards closest-hole)
                ]
                output-debug-message (word "The local 'heading-of-closest-tile-along-shortest-distance-to-closest-hole' variable value is now set to: " heading-of-closest-tile-along-shortest-distance-to-closest-hole ".  If this is less than 0 I'll convert it to its positive equivalent...") (who)
                if(heading-of-closest-tile-along-shortest-distance-to-closest-hole < 0)[
                  output-debug-message ("The local 'heading-of-closest-tile-along-shortest-distance-to-closest-hole' variable is less than 0, converting it to its positive equivalent...") (who)
                  set heading-of-closest-tile-along-shortest-distance-to-closest-hole (heading-of-closest-tile-along-shortest-distance-to-closest-hole + 360)
                ]
                output-debug-message (word "The local 'heading-of-closest-tile-along-shortest-distance-to-closest-hole' variable value is now set to: " heading-of-closest-tile-along-shortest-distance-to-closest-hole "...") (who)
                
                output-debug-message ("Turning to face the tile closest to my closest hole...") (who)
                face turtle (first ([who] of closest-tile))
                let positioned-correctly? false
                
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;;; CLOSEST TILE IS DIRECTLY NORTH/EAST/SOUTH/WEST OF CLOSEST HOLE ;;;
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
                output-debug-message ("Checking to see if the tile closest to my closest hole is directly north/east/south/west of my closest hole...") (who)
                ifelse(
                  (heading-of-closest-tile-along-shortest-distance-to-closest-hole = 0) or
                  (heading-of-closest-tile-along-shortest-distance-to-closest-hole = 90) or
                  (heading-of-closest-tile-along-shortest-distance-to-closest-hole = 180) or
                  (heading-of-closest-tile-along-shortest-distance-to-closest-hole = 270) 
                )[
                  output-debug-message ("The closest tile to my closest hole is directly north/east/south/west of my closest hole, I should push it in one direction only then...") (who)
                  output-debug-message ("Checking to see if I am positioned correctly to push the closest tile towards my closest hole...") (who)
                  
                  if(correctly-positioned-to-push-closest-tile-to-closest-hole? (heading-of-closest-tile-along-shortest-distance-to-closest-hole) )[
                    output-debug-message (word "I'm correctly positioned (closest tile is 1 patch away along heading " heading-of-closest-tile-along-shortest-distance-to-closest-hole ")...") (who)
                    set positioned-correctly? true
                  ]
                ]
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;;; CLOSEST TILE IS NOT DIRECTLY NORTH/EAST/SOUTH/WEST OF CLOSEST HOLE ;;;
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                [
                  output-debug-message ("The tile closest to my closest hole is not directly north/east/south/west of my closest hole.  Determining where my closest hole is in relation to its closest tile...") (who)
                  output-debug-message ("I can push the tile closest to my closest hole in one of two directions in this case if I am positioned correctly...") (who)
                  
                  if(heading-of-closest-tile-along-shortest-distance-to-closest-hole > 0 and heading-of-closest-tile-along-shortest-distance-to-closest-hole < 90)[
                    output-debug-message ("My closest hole is north-east of its closest tile") (who)
                    output-debug-message ("Checking to see if the closest tile is adjacent to me to the north or east, if it is I can push it along my current heading since I am facing it...") (who)
                    
                    if(correctly-positioned-to-push-closest-tile-to-closest-hole? (0) or correctly-positioned-to-push-closest-tile-to-closest-hole? (90) )[
                      set positioned-correctly? true
                    ]
                  ]
                  
                  if(heading-of-closest-tile-along-shortest-distance-to-closest-hole > 90 and heading-of-closest-tile-along-shortest-distance-to-closest-hole < 180)[
                    output-debug-message ("My closest hole is south-east of its closest tile") (who)
                    output-debug-message ("Checking to see if the closest tile is adjacent to me to the east or south, if it is I can push it along my current heading since I am facing it...") (who)
                    
                    if(correctly-positioned-to-push-closest-tile-to-closest-hole? (90) or correctly-positioned-to-push-closest-tile-to-closest-hole? (180) )[
                      set positioned-correctly? true
                    ]
                  ]
                  
                  if(heading-of-closest-tile-along-shortest-distance-to-closest-hole > 180 and heading-of-closest-tile-along-shortest-distance-to-closest-hole < 270)[
                    output-debug-message ("My closest hole is south-west of its closest tile") (who)
                    output-debug-message ("Checking to see if the closest tile is adjacent to me to the south or west, if it is I can push it along my current heading since I am facing it...") (who)
                    
                    if(correctly-positioned-to-push-closest-tile-to-closest-hole? (180) or correctly-positioned-to-push-closest-tile-to-closest-hole? (270) )[
                      set positioned-correctly? true
                    ]
                  ]
                  
                  if(heading-of-closest-tile-along-shortest-distance-to-closest-hole > 270 and heading-of-closest-tile-along-shortest-distance-to-closest-hole < 360)[
                    output-debug-message ("My closest hole is north-west of its closest tile") (who)
                    
                    output-debug-message ("Checking to see if the closest tile is adjacent to me to the west or north, if it is I can push it along my current heading since I am facing it...") (who)
                    
                    if(correctly-positioned-to-push-closest-tile-to-closest-hole? (270) or correctly-positioned-to-push-closest-tile-to-closest-hole? (0) )[
                      set positioned-correctly? true
                    ]
                  ]
                ]
                
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;;; TURTLE IS POSITIONED CORRECTLY ;;;
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                
                ifelse(positioned-correctly?)[
                  output-debug-message ("Checking to see if there is anything blocking the tile from being pushed along my current heading...") (who)
                  ifelse(any? (turtles-on patch-at-heading-and-distance (heading) (2)) with [breed != holes and hidden? = false])[
                    output-debug-message(word "There is something blocking the closest tile from being pushed along heading " heading ". This could only be another agent so I'll remain stationary and hope it moves...") (who)
                    set action-pattern (chrest:create-item-square-pattern (remain-stationary-token) (0) (0))
                  ]
                  [
                    output-debug-message(word "There is nothing blocking the closest tile from being pushed along heading " heading " so I'll generate an action pattern to do this...") (who)
                    set action-pattern (chrest:create-item-square-pattern (push-tile-token) (heading) (1))
                  ]
                ]
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                ;;; TURTLE IS NOT POSITIONED CORRECTLY ;;;
                ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                [
                  output-debug-message ("Altering heading by +/- 90 to try and move into a correct position...") (who)
                  alter-heading-randomly-by-adding-or-subtracting-90
                  
                  while[ 
                    ( any? (turtles-on (patch-at-heading-and-distance (heading) (1))) with [breed != tiles and hidden? = false]) or
                    ( (any? (turtles-on (patch-at-heading-and-distance (heading) (1))) with [breed = tiles]) and (any? (turtles-on patch-at-heading-and-distance (heading) (2)) with [breed != holes] and hidden? = false) )
                  ]
                  [ 
                    output-debug-message (word "There is something on the patch ahead with heading " heading "; either a non-tile or a tile that is blocked...") (who)
                    output-debug-message ("I'll alter my current heading by +/- 90 and check again...") (who)
                    alter-heading-randomly-by-adding-or-subtracting-90
                  ]
                  output-debug-message (word "The patch ahead with heading " heading " is either free or has a tile that can be pushed on it.  Checking to see if I need to push a tile or not...") (who)
                  
                  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  ;;; CHECK TO SEE IF I NEED TO PUSH A TILE TO MOVE ALONG HEADING OR NOT ;;;
                  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
                  
                  ifelse(any-tiles-on-patch-ahead?)[
                    output-debug-message ("There is a tile on the patch immediately along my current heading so I'll set this to be my closest-tile so that it is pushed when the 'push-tile' action I'm to generate is performed..." ) (who)
                    set closest-tile (tiles-on patch-at-heading-and-distance (heading) (1))
                    output-debug-message ("Generating the action pattern...") (who)
                    set action-pattern (chrest:create-item-square-pattern push-tile-token heading 1)
                  ]
                  [
                    output-debug-message ("There isn't a tile on the patch immediately along my current heading so I'll generate a 'move-around-tile' action pattern...") (who)
                    output-debug-message ("Generating the action pattern...") (who)
                    set action-pattern (chrest:create-item-square-pattern move-around-tile-token heading 1)
                  ] 
                ]
              ]
              
              output-debug-message (word "Checking to see if the local 'action-pattern' variable (" action-pattern ") has been instantiated, if so, it will be loaded for execution...") (who)
              if(not empty? action-pattern)[
                output-debug-message (word "Action pattern is not empty, loading for execution...") (who)
                load-action (action-pattern) 
              ]
            ]
          end
          
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "GENERATE-RANDOM-MOVE-ACTION" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         
          ;Selects a heading at random for the calling turtle to move in and generates an 
          ;action pattern indicating that the calling turtle will move 1 patch along this 
          ;randomly selected heading and load this action pattern for execution.
          ;
          ;@author   Martyn Lloyd-Kelly  <martynlloydkelly@gmail.com>     
          to generate-random-move-action
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'generate-random-move-action' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            
            ;Since this procedure is only called when the turtle can not see a tile, a simple
            ;call to "surrounded?" sufficies to check if the agent is surrounded since if the
            ;turtle could see a tile, this procedure would not be called. 
            output-debug-message ("Checking to see if I'm surrounded, if not, I'll continue...") (who)
            if(not surrounded?)[
              output-debug-message ("Since I'm not surrounded I'll continue trying to move randomly...") (who)
              output-debug-message (word "Selecting a heading at random from '" movement-headings "' with a 1 in " (length movement-headings) " probability and setting my heading to that value...") (who)
              set heading (item (random (length movement-headings)) (movement-headings))
              output-debug-message (word "I've set my heading to " heading ".") (who)
              output-debug-message (word "Generating action pattern...") (who)
              let action-pattern (chrest:create-item-square-pattern move-randomly-token heading 1)
              output-debug-message (word "Action pattern generated: '" action-pattern "'.  Loading this action for execution...") (who)
              load-action (action-pattern)
            ]
            
            set debug-indent-level (debug-indent-level - 2)
          end
          
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "LOAD-ACTION" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Sets the calling turtle's: 
          ; - 'next-action-to-perform' variable to the parameter passed to this procedure.
          ; - 'visual-pattern-used-to-generate-action' variable is set to the value of the 
          ;   calling turtle's 'current-visual-pattern' variable
          ; - 'time-to-perform-next-action' variable to the current time plus the value contained
          ;   in the calling turtle's 'action-performance-time' variable.
          ;
          ;         Name              Data Type     Description
          ;         ----              ---------     -----------
          ;@param   action-pattern    String        The action-pattern that is to be set to the calling
          ;                                         turtle's 'next-action-to-perform' variable.  This 
          ;                                         action may then be performed in the future.
          to load-action [action-pattern]
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'load-action' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            
            output-debug-message (word "Setting my 'next-action-to-perform' variable value to: '" action-pattern "' and my 'visual-pattern-used-to-generate-action' variable value to: '" current-visual-pattern "'...") (who)
            set next-action-to-perform (action-pattern)
            set visual-pattern-used-to-generate-action (current-visual-pattern)
            
            output-debug-message (word "Checking to see if the game is being played in a training context.  The 'training?' global variable is set to: '" training? "'.") (who)
            ifelse(training?)[
              output-debug-message ( word "Game is being played in a training context. Setting my 'time-to-perform-next-action' variable to: 'current-training-time' (" current-training-time ") + 'action-performance-time' (" action-performance-time ") = " (precision (current-training-time + action-performance-time) (1)) "..." ) (who)
              set time-to-perform-next-action (precision (current-training-time + action-performance-time) (1))
            ]
            [
              output-debug-message ( word "Game is being played in a non-training context. Setting my 'time-to-perform-next-action' variable to: 'current-game-time' (" current-game-time ") + 'action-performance-time' (" action-performance-time ") = " (precision (current-game-time + action-performance-time) (1)) "..." ) (who)
              set time-to-perform-next-action (precision (current-game-time + action-performance-time) (1))
            ]
            
            output-debug-message (word "I'm going to perform '" next-action-to-perform "' at time: '" time-to-perform-next-action "' and my 'visual-pattern-used-to-generate-action' variable is set to: '" visual-pattern-used-to-generate-action "'." ) (who)
            set debug-indent-level (debug-indent-level - 2)
          end
 
          ;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "MOVE" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Enables calling turtle to move along its current heading by the number of 
          ;patches specified by the parameter passed to this procedure so long as the 
          ;patch immediately ahead of the calling turtle along its current heading is 
          ;clear.  If the patch immediately in front of the calling turtle along its
          ;heading is not clear then the calling turtle will not move.
          ;
          ;If the calling turtle's 'breed' variable is set to "chrest-turtles" and the
          ;calling turtle is not intended to be moving randomly then an action pattern 
          ;is generated and linked to the calling turtle's 'current-visual-pattern' 
          ;variable value.
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
          ;
          ;@author   Martyn Lloyd-Kelly  <martynlloydkelly@gmail.com>
          to move [action-token heading-to-move-along patches-to-move]
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'move' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            
            output-debug-message (word "Setting my heading to the value of the local-variable 'heading-to-move-along': " heading-to-move-along "...") (who)
            set heading (heading-to-move-along)
            
            output-debug-message (word "Checking to see if the patch immediately ahead of me along heading " heading " is clear...") (who)
            if(way-clear?)[
              output-debug-message (word "The patch immediately ahead of me along heading " heading " is clear so I'll move " patches-to-move " patches along this heading...") (who)
              forward patches-to-move 
              
              output-debug-message ("If I'm not a CHREST turtle and I'm not moving randomly, I'll attempt to associate this action and contents of 'current-visual-pattern together...") (who)
              output-debug-message (word "Checking my 'breed' variable value (" breed ") and the value of the local 'action-token?' variable (" action-token ")...") (who)
              if( (breed = chrest-turtles) and (action-token != move-randomly-token) )[
                output-debug-message ("I am a CHREST turtle and I'm not moving randomly so I'll generate an action pattern and associate this with my current visual pattern...") (who)
                output-debug-message ("Generating the action pattern...") (who)
                let action-pattern (chrest:create-item-square-pattern (action-token) (heading) (patches-to-move))
                output-debug-message (word "Action pattern generated: " action-pattern ".  Attempting to associate this with: '" current-visual-pattern "'...") (who)
                chrest:associate-patterns "visual" "item_square" current-visual-pattern "action" "item_square" action-pattern convert-seconds-to-milliseconds(report-current-time)
              ]
            ]
            
            set debug-indent-level (debug-indent-level - 2)
          end
          
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "OUTPUT-DEBUG-MESSAGE" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Takes the message passed as the first parameter to this procedure and outputs 
          ;it to the command center if the global 'debug?' variable is set to true.  
          ;Users can also specify that the message to output is turtle-specific using the 
          ;second parameter passed to this procedure.
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
              
              print msg-to-output
            ]
          end
          
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "PERFORM-ACTION" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         
          ;Takes an action pattern and uses the information contained within it to enable
          ;the calling turtle to perform the action appropriately.
          ;
          ;         Name              Data Type     Description
          ;         ----              ---------     -----------
          ;@param   action-to-perform String        The action-pattern to be performed.
          to perform-action [action-to-perform]
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'perform-action' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message (word "The action I am to perform is: '" action-to-perform "'.  Parsing this now...") (who)
            
            ;action-to-perform will contain something like the following which needs to be parsed: < [PT 180 1] >
            let action-1 substring action-to-perform ( (position "[" action-to-perform ) + 1 ) (position "]" action-to-perform) ;Should give "PT 180 1"
            let action ( substring action-1 (0) (position " " action-1) );Should give PT
            let heading-and-patches-to-move substring action-1 ( (position " " action-1) + 1 ) (length action-1) ;should give "180 1"
            let heading-to-move-along ( read-from-string ( substring heading-and-patches-to-move 0 (position " " heading-and-patches-to-move) ) ); should give 180
            let patches-to-move ( read-from-string ( substring heading-and-patches-to-move ( (position " " heading-and-patches-to-move) + 1) (length heading-and-patches-to-move) ) );should give 1
            
            output-debug-message (word "Checking to see what action I should perform using the value of the local 'action' variable: '" action "'...") (who)
            
            ifelse(action = move-randomly-token)[
              output-debug-message (word "'" action "' is equal to: '" move-randomly-token "' so I'll execute the 'move' procedure but I won't associate the action pattern and visual pattern...") (who)
              move (action) (heading-to-move-along) (patches-to-move)
            ]
            [
              ifelse(action = push-tile-token)[
                output-debug-message (word "'" action "' is equal to: '" push-tile-token "' so I'll execute the 'push-tile' procedure if my'closest-tile' variable is not empty (" closest-tile ")...") (who)
                ifelse(closest-tile != "")[
                  output-debug-message ("My 'closest-tile' variable is not empty so I'll push this tile...") (who)
                  push-tile (heading-to-move-along)
                ]
                [
                  output-debug-message ("My 'closest-tile' variable is empty so I won't do anything...") (who)
                  stop
                ]
              ]
              [
                ifelse(action = surrounded-token)[
                  output-debug-message (word "'" action "' is equal to: '" surrounded-token "' so I'm surrounded...") (who)
                  output-debug-message (word "Checking the value of my 'breed' variable ( breed ) to see if I'm a CHREST turtle.  If I am I'll associate this action with my current visual pattern...") (who)
                  if(breed = chrest-turtles)[
                    output-debug-message (word "I am a CHREST turtle so I'll associate the value of my 'current-visual-pattern' variable (" current-visual-pattern ") with the value of the local 'action-to-perform' variable (" action-to-perform ")...") (who)
                    chrest:associate-patterns "visual" "item_square" current-visual-pattern "action" "item_square" action-to-perform convert-seconds-to-milliseconds(report-current-time)
                  ]
                  
                  output-debug-message ("Since I'm surrounded I'll stop trying to perform an action...") (who)
                  set debug-indent-level (debug-indent-level - 2)
                  stop
                ]
                [
                  ifelse(action = remain-stationary-token)[
                    output-debug-message (word "'" action "' is equal to: '" remain-stationary-token "' so I'll remain stationary...") (who)
                    output-debug-message (word "Checking the value of my 'breed' variable ( breed ) to see if I'm a CHREST turtle.  If I am I'll associate this action with my current visual pattern...") (who)
                    if(breed = chrest-turtles)[
                      output-debug-message (word "I am a CHREST turtle so I'll associate the value of my 'current-visual-pattern' variable (" current-visual-pattern ") with the value of the local 'action-to-perform' variable (" action-to-perform ")...") (who)
                      chrest:associate-patterns "visual" "item_square" current-visual-pattern "action" "item_square" action-to-perform convert-seconds-to-milliseconds(report-current-time)
                    ]
                    
                    output-debug-message ("Since I'm remaining stationary I won't do anything now...") (who)
                    set debug-indent-level (debug-indent-level - 2)
                    stop
                  ]
                  [
                    output-debug-message (word "'" action "' indicates that I'm not to move randomly, not to push a tile or surrounded so I'll move purposefully...") (who)
                    move (action) (heading-to-move-along) (patches-to-move)
                  ]
                ]
              ]
            ]
            
            output-debug-message (word "Since I've performed an action I don't have an action to perform in the future at the moment so I'll reset my 'next-action-to-perform' and 'time-to-perform-next-action' variables to '' and -1...") (who)
            set next-action-to-perform ""
            set time-to-perform-next-action -1
            output-debug-message (word "My 'next-action-to-perform' variable value is now: '" next-action-to-perform "' and my 'time-to-perform-next-action' variable value is now: '" time-to-perform-next-action "'...") (who)
            
            set debug-indent-level (debug-indent-level - 2)
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
          to-report player-turtles-finished?
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'player-turtles-finished?' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message (word "THE NUMBER OF VISIBLE TURTLES THAT AREN'T OF BREED 'tiles' AND 'holes' IS: " count turtles with [ breed != tiles and breed != holes and hidden? = false ] ".") ("")
            
            ifelse( count turtles with [ breed != tiles and breed != holes and hidden? = false ] = 0 )[ 
              output-debug-message ("THERE ARE NO VISIBLE TURTLES THAT AREN'T OF BREED 'tiles' AND 'holes' IN THE ENVIRONMENT.") ("")
              report true 
            ]
            [ 
              output-debug-message ("THERE ARE VISIBLE TURTLES THAT AREN'T OF BREED 'tiles' AND 'holes' IN THE ENVIRONMENT.") ("")
              report false 
            ]
            
            set debug-indent-level (debug-indent-level - 2)
          end
          
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          ;;; "PUSH-TILE" PROCEDURE ;;;
          ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
          ;Enables the calling agent to push a tile.  The calling agent will set its heading to
          ;face its closest-tile and the tile to be pushed is asked to do the same (enables a 
          ;"push" to be simulated).  The tile to be pushed is also asked to determine if there 
          ;is anything immediately in front of it in the current heading, if not, the tile moves
          ;forward 1 patch along its current heading and the calling turtle does the same.
          ;
          ;If there is a turtle in front of the tile to be pushed then the tile does not move and
          ;when the calling turtle checks the patch that is 1 patch away in its current heading,
          ;it will see that the tile occupies this patch and will not move.
          ;
          ;         Name              Data Type     Description
          ;         ----              ---------     -----------
          ;@params  push-heading      Number        The heading that the pusher should set its heading
          ;                                         to in order to push the tile in question.
          to push-tile [push-heading]
            set debug-indent-level (debug-indent-level + 1)
            output-debug-message ("EXECUTING THE 'push-tile' PROCEDURE...") ("")
            set debug-indent-level (debug-indent-level + 1)
            
            output-debug-message( word "Setting my heading to the value contained in the local 'push-heading' variable: " push-heading "...") (who)
            set heading (push-heading)
            output-debug-message (word "My 'heading' variable is now set to:" heading ".  Checking to see if there is a tile immediately ahead that I can push...") (who)
            
            if(any? tiles-on patch-at-heading-and-distance (heading) (1))[
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
                  ask myself [ set score score + 1 ]
                  die
                ]
                [
                  ;No need to check if the way is clear since the pusher will have already
                  ;done this.  If the patch ahead of the tile along its current heading 
                  ;is not free, this procedure would not have been run.
                  output-debug-message (word "There are no holes on the patch immediately ahead of me with heading " heading " so I'll move forward by 1 patch...") (who)
                  forward 1
                ]
              ]
            ]

            ;The way ahead will now be free since, if the tile was blocked, the pusher
            ;would not have executed this procedure.
            output-debug-message (word "I should also move forward by 1 patch...") (who)
            forward 1
            
            if(breed = chrest-turtles)[
              let action-pattern (chrest:create-item-square-pattern (push-tile-token) (heading) (1))
              output-debug-message (word "Action pattern generated: " action-pattern ".  Attempting to associate this with: '" current-visual-pattern "'...") (who)
              chrest:associate-patterns "visual" "item_square" current-visual-pattern "action" "item_square" action-pattern convert-seconds-to-milliseconds(report-current-time)
            ]
            
            set debug-indent-level (debug-indent-level - 2)
          end
         
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;;; "REPORT-CURRENT-TIME" PROCEDURE ;;;
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         
         ;Reports the current time in seconds by determining if the game is currently 
         ;being played in a training context or not.
         ;
         ;@author Martyn Lloyd-Kelly <martynlloydkelly@gmail.com>
         to-report report-current-time
           ifelse(training?)[
             report current-training-time
           ]
           [
             report current-game-time
           ]
         end
         
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;;; "RECTIFY-HEADING" PROCEDURE ;;;
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         
         ;Reports one of 0, 90, 180 or 270 if the heading passed does not already
         ;equal one of these values.  If the heading passed does not equal one of
         ;these values, the value returned may be one of two values according to
         ;the following conditions:
         ;
         ; - If the heading passed is > 0 and < 90 either 0 or 90 is returned.
         ; - If the heading passed is > 90 and < 180 either 90 or 180 is returned.
         ; - If the heading passed is > 180 and < 270 either 180 or 270 is returned.
         ; - If the heading passed is > 270 and < 360 either 270 or 0 is returned. 
         ;
         ;The non-determinism of the value reported ensures that the calling turtle
         ;does not repeat the same action over and over e.g. if a calling turtle's
         ;closest tile is to the south-east and the calling turtle turns to face this
         ;tile and its heading is then rectified, it has a 1 in 2 chance of setting 
         ;its heading east or south rather than always setting its heading to the east
         ;or always to the south.  Thus, the behaviour of the calling turtle is more 
         ;flexible.
         ;
         ;         Name              Data Type     Description
         ;         ----              ---------     -----------
         ;@param   heading-to-recify Float         The heading to be rectified.
         to-report rectify-heading [heading-to-rectify]
           set debug-indent-level (debug-indent-level + 1)
           output-debug-message ("EXECUTING THE 'recitify-heading' PROCEDURE...") ("")
           set debug-indent-level (debug-indent-level + 1)
           output-debug-message (word "THE VALUE OF THE LOCAL VARIABLE 'heading-to-rectify' IS: '" heading-to-rectify "'.") ("")
           
           if(heading-to-rectify < 0)[
             set heading-to-rectify (360 + heading-to-rectify)
             output-debug-message ("'heading-to-rectify' IS LESS THAN 0, SO 360 HAS BEEN ADDED TO IT TO CONVERT IT TO A POSITIVE VALUE.") ("")
             output-debug-message(word "'heading-to-rectify' IS NOW EQUAL TO: '" heading-to-rectify "'.") ("")
           ]
           
           output-debug-message ("SETTING THE LOCAL 'random-decision' VARIABLE VALUE...") ("")
           let random-decision (random 2)
           output-debug-message (word "THE LOCAL 'random-decision' VARIABLE VALUE IS NOW SET TO: " random-decision "...") ("")
           output-debug-message (word "CHECKING THE VALUE OF THE LOCAL 'heading-to-rectify' VARIABLE VALUE (" heading-to-rectify ")...") ("")
           
           if( (heading-to-rectify > 0) and (heading-to-rectify < 90) )[
             output-debug-message (word "THE LOCAL 'heading-to-rectify' VARIABLE VALUE IS > 0 AND < 90...") ("")
             ifelse( random-decision = 0 )[
               output-debug-message (word "REPORTING " (item (0) (movement-headings)) "...") ("")
               set debug-indent-level (debug-indent-level - 2)
               report (item (0) (movement-headings))
             ]
             [
               output-debug-message (word "REPORTING " (item (1) (movement-headings)) "...") ("")
               set debug-indent-level (debug-indent-level - 2)
               report (item (1) (movement-headings))
             ]
           ]
           
           if( (heading-to-rectify > 90) and (heading-to-rectify < 180) )[
             output-debug-message (word "THE LOCAL 'heading-to-rectify' VARIABLE VALUE IS > 90 AND < 180...") ("")
             ifelse( random-decision = 0 )[
               output-debug-message (word "REPORTING " (item (1) (movement-headings)) "...") ("")
               set debug-indent-level (debug-indent-level - 2)
               report (item (1) (movement-headings))
             ]
             [
               output-debug-message (word "REPORTING " (item (2) (movement-headings)) "...") ("")
               set debug-indent-level (debug-indent-level - 2)
               report (item (2) (movement-headings))
             ]
           ]
           
           if( (heading-to-rectify > 180) and (heading-to-rectify < 270) )[
             output-debug-message (word "THE LOCAL 'heading-to-rectify' VARIABLE VALUE IS > 180 AND < 270...") ("")
             ifelse( random-decision = 0 )[
               output-debug-message (word "REPORTING " (item (2) (movement-headings)) "...") ("")
               set debug-indent-level (debug-indent-level - 2)
               report (item (2) (movement-headings))
             ]
             [
               output-debug-message (word "REPORTING " (item (3) (movement-headings)) "...") ("")
               set debug-indent-level (debug-indent-level - 2)
               report (item (3) (movement-headings))
             ]
           ]
           
           if( (heading-to-rectify > 270) and (heading-to-rectify < 360) )[
             output-debug-message (word "THE LOCAL 'heading-to-rectify' VARIABLE VALUE IS > 270 AND < 360...") ("")
             ifelse( random-decision = 0 )[
               output-debug-message (word "REPORTING " (item (3) (movement-headings)) "...") ("")
               set debug-indent-level (debug-indent-level - 2)
               report (item (3) (movement-headings))
             ]
             [
               output-debug-message (word "REPORTING " (item (0) (movement-headings)) "...") ("")
               set debug-indent-level (debug-indent-level - 2)
               report (item (0) (movement-headings))
             ]
           ]
           
           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
           ;;; OLD METHOD - IMPLEMENTED BY VIDAL ;;;
           ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
           
;           if(heading-to-rectify <= 45)[
;             output-debug-message ("'heading-to-rectify' IS LESS THAN OR EQUAL TO 45, REPORTING 0.") ("")
;             set debug-indent-level (debug-indent-level - 2)
;             report 0
;           ]
;           
;           if(heading-to-rectify <= 135)[
;             output-debug-message ("'heading-to-rectify' IS LESS THAN OR EQUAL TO 135, REPORTING 90.") ("")
;             set debug-indent-level (debug-indent-level - 2)
;             report 90
;           ]
;           
;           if (heading-to-rectify <= 225)[
;             output-debug-message ("'heading-to-rectify' IS LESS THAN OR EQUAL TO 225, REPORTING 180.") ("")
;             set debug-indent-level (debug-indent-level - 2)
;             report 180
;           ]
;           
;           if (heading-to-rectify <= 315)[
;             output-debug-message ("'heading-to-rectify' IS LESS THAN OR EQUAL TO 315, REPORTING 270.") ("")
;             set debug-indent-level (debug-indent-level - 2)
;             report 270
;           ]
           
           output-debug-message ("THE LOCAL 'heading-to-rectify' VARIABLE VALUE IS SET TO EITHER 0, 90, 180 or 270, REPORTING THIS VALUE...") ("")
           set debug-indent-level (debug-indent-level - 2)
           report heading-to-rectify
         end
         
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;;; "SCHEDULED-TO-PERFORM-ACTION-IN-FUTURE?" PROCEDURE ;;;
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
          
         ;Checks the calling turtle's 'time-to-perform-next-action' variable against either
         ;the 'current-training-time' or 'current-game-time' depending on whether the game
         ;is being played in a training context or not.
         ;
         ;         Name              Data Type     Description
         ;         ----              ---------     -----------
         ;@returns -                 Boolean       True returned if the value of the calling turtle's 
         ;                                         'time-to-perform-next-action' variable is greater 
         ;                                         than the value of the local 'current-time' variable.  
         ;                                         False is returned if not.
         to-report scheduled-to-perform-action-in-future?
           set debug-indent-level (debug-indent-level + 1)
           output-debug-message (word "EXECUTING THE 'scheduled-to-perform-action-in-future?' PROCEDURE...") ("")
           set debug-indent-level (debug-indent-level + 1)
           
           output-debug-message (word "CHECKING THE VALUE OF THE GLOBAL 'training?' VARIABLE (" training? ") TO SEE IF THE GAME IS BEING PLAYED IN A TRAINING CONTEXT OR NOT.  'true' IF IT IS, 'false' IF NOT...") ("")
           output-debug-message (word "A LOCAL VARIABLE: 'current-time' WILL BE SET TO EITHER THE VALUE OF 'current-training-time' (" current-training-time ") OR 'current-game-time' (" current-game-time ") DEPENDING ON WHETHER THE GAME IS BEING PLAYED IN A TRAINING CONTEXT OR NOT...") ("")
           output-debug-message (word "THE LOCAL 'current-time' VARIABLE WILL THEN BE CHECKED AGAINST THE VALUE OF THE CALLING TURTLE's 'time-to-perform-next-action' VARIABLE TO SEE IF IT IS SCHEDULED TO PERFORM AN ACTION IN THE FUTURE...") ("")
           let current-time 0
           ifelse(training?)[ set current-time (current-training-time) ][ set current-time (current-game-time) ]
           
           output-debug-message (word "Comparing the value of my 'time-to-perform-next-action' variable (" time-to-perform-next-action ") against the value of the local 'current-time' variable (" current-time ")...") (who)
           
           ifelse(time-to-perform-next-action > current-time)[
             output-debug-message ("The value of my 'time-to-perform-next-action' variable is greater than the value of the local 'current-time' variable.") (who)
             output-debug-message ("I am therefore scheduled to perform an action in the future.  Reporting 'true'...") (who)
             set debug-indent-level (debug-indent-level - 2)
             report true
           ]
           [
             set debug-indent-level (debug-indent-level - 2)
             report false
           ]
         end
         
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;;; "SCHEDULED-TO-PERFORM-ACTION-NOW?" PROCEDURE ;;;
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         
         ;Checks the calling turtle's 'time-to-perform-next-action' variable against either
         ;the 'current-training-time' or 'current-game-time' depending on whether the game
         ;is being played in a training context or not.
         ;
         ;         Name              Data Type     Description
         ;         ----              ---------     -----------
         ;@returns -                 Boolean       True returned if the value of the calling turtle's 
         ;                                         'time-to-perform-next-action' variable is greater 
         ;                                         than the value of the local 'current-time' variable.  
         ;                                         False is returned if not.
         to-report scheduled-to-perform-action-now?
           set debug-indent-level (debug-indent-level + 1)
           output-debug-message (word "EXECUTING THE 'scheduled-to-perform-action-now?' PROCEDURE...") ("")
           set debug-indent-level (debug-indent-level + 1)
           
           output-debug-message (word "CHECKING THE VALUE OF THE GLOBAL 'training?' VARIABLE (" training? ") TO SEE IF THE GAME IS BEING PLAYED IN A TRAINING CONTEXT OR NOT.  'true' IF IT IS, 'false' IF NOT...") ("")
           output-debug-message (word "A LOCAL VARIABLE: 'current-time' WILL BE SET TO EITHER THE VALUE OF 'current-training-time' (" current-training-time ") OR 'current-game-time' (" current-game-time ") DEPENDING ON WHETHER THE GAME IS BEING PLAYED IN A TRAINING CONTEXT OR NOT...") ("")
           output-debug-message (word "THE LOCAL 'current-time' VARIABLE WILL THEN BE CHECKED AGAINST THE VALUE OF THE CALLING TURTLE's 'time-to-perform-next-action' VARIABLE TO SEE IF IT IS SCHEDULED TO PERFORM AN ACTION NOW...") ("")
           let current-time 0
           ifelse(training?)[ set current-time (current-training-time) ][ set current-time (current-game-time) ]
           
           output-debug-message (word "Comparing the value of my 'time-to-perform-next-action' variable (" time-to-perform-next-action ") against the value of the local 'current-time' variable (" current-time ")...") (who)
           ifelse(time-to-perform-next-action = current-time)[
             output-debug-message ("The value of my 'time-to-perform-next-action' variable is equal to the value of the local 'current-time' variable.") (who)
             output-debug-message ("I am therefore scheduled to perform an action now.  Reporting 'true'...") (who)
             set debug-indent-level (debug-indent-level - 2)
             report true
           ]
           [
             set debug-indent-level (debug-indent-level - 2)
             report false
           ]
         end
             
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;;; "SURROUNDED?" PROCEDURE ;;;
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         
         ;Determines whether the calling turtle is surrounded and generates a "surrounded"
         ;action pattern if it is.  To check whether it is surrounded or not the calling 
         ;turtle checks to see if either condition that follows is true for each item, n, 
         ;in the global 'movement-headings' variable:
         ;
         ; - Is there a turtle other than a tile on the patch immediately ahead of the calling
         ;   turtle with heading n?
         ; - If there is a tile on the patch immediately ahead of the calling turtle with 
         ;   heading n, is there another turtle other than a hole on the patch that is 2 
         ;   patches away from the calling turtle with heading n?
         ;
         ;If these conditions are true for all items in the global 'movement-headings' 
         ;variable then the calling turtle is surrounded. 
         ;
         ;         Name              Data Type     Description
         ;         ----              ---------     -----------
         ;@return  -                 Boolean       Boolean true indicates that the calling turtle is
         ;                                         surrounded, boolean false indicates that the calling 
         ;                                         turtle is not surrounded.
         to-report surrounded?
           set debug-indent-level (debug-indent-level + 1)
           output-debug-message ("EXECUTING THE 'surrounded?' PROCEDURE...") ("")
           set debug-indent-level (debug-indent-level + 1)
           
           output-debug-message ("Setting the local 'headings-blocked' and 'heading-item' variable values to an empty list and 0, respectively...") (who)
           let headings-blocked []
           let heading-item 0
           output-debug-message (word "The local 'headings-blocked' and 'heading-item' variable values are now set to: '" headings-blocked "' and '" heading-item "'...") (who)
           
           while[heading-item < length movement-headings][
             let heading-to-check (item (heading-item) (movement-headings))
             output-debug-message (word "Checking to see if the patch at heading " heading-to-check " and distance 1 has any turtles on it that aren't tiles...") (who)
             output-debug-message (word "Also checking to see if there are any tiles at heading " heading-to-check " and distance 1.  If there are, the patch at heading " heading-to-check " and distance 2 will be checked to see if it contains any turtles except holes...") (who)
             output-debug-message (word "If either condition is true, I'm blocked along heading " heading-to-check " so I'll add " heading-to-check " to the local 'headings-blocked' list...") (who)
               
             if(
               (any? (turtles-on patch-at-heading-and-distance heading-to-check 1) with [ hidden? = false and breed != tiles ]) or
               (any? (tiles-on patch-at-heading-and-distance heading-to-check 1) and (any? (turtles-on patch-at-heading-and-distance heading-to-check 2) with [breed != holes]))
             )[
               output-debug-message (word "One of the conditions has evaluated to true so I'll add " heading-to-check " to the local 'headings-blocked' list...") (who)
               set headings-blocked (lput (heading-to-check) (headings-blocked))
               output-debug-message (word "'headings-blocked' list now set to: " headings-blocked ".  Checking the next heading in the global 'movement-headings' variable...") (who)
             ]
             
             ;ICNREMENT TIME HERE.
             set heading-item (heading-item + 1)
           ]
           
           output-debug-message (word "Checking the length of the local 'headings-blocked' list (" length headings-blocked ").  If this is equal to the length of the global 'movement-headings' list (" length movement-headings ") then I'm surrounded...") (who)
           ifelse( (length headings-blocked) = (length movement-headings) )[
             output-debug-message ("The length of the local 'headings-blocked' list is equal to the length of the global 'movement-headings' list so I am surrounded...") (who)
             output-debug-message ("Generating an action pattern indicating that I am surrounded...") (who)
             let action-pattern (chrest:create-item-square-pattern (surrounded-token) (0) (0))
             output-debug-message (word "Action pattern generated: '" action-pattern "', loading this action for execution...") (who)
             load-action (action-pattern)
             
             set debug-indent-level (debug-indent-level - 2)
             report true
           ]
           [
             output-debug-message ("The length of the local 'headings-blocked' list is not equal to the length of the global 'movement-headings' list so I am not surrounded...") (who)
             set debug-indent-level (debug-indent-level - 2)
             report false
           ]
           
           ;OLD METHOD
;           ifelse(
;             any? (turtles-on patch-at-heading-and-distance 0 1) with [ hidden? = false and breed != tiles ] and
;             any? (turtles-on patch-at-heading-and-distance 90 1) with [ hidden? = false and breed != tiles ] and 
;             any? (turtles-on patch-at-heading-and-distance 180 1) with [ hidden? = false and breed != tiles ] and 
;             any? (turtles-on patch-at-heading-and-distance 270 1) with [ hidden? = false and breed != tiles ]
;           )[
;             output-debug-message ("There are visible turtles on the patches directly north, east, south and west of me that aren't tiles so I am surrounded...") (who)
;             output-debug-message ("Generating an action pattern indicating that I am surrounded...") (who)
;             let action-pattern (chrest:create-item-square-pattern (surrounded-token) (heading) (0))
;             output-debug-message (word "Action pattern generated: '" action-pattern "', loading this action for execution...") (who)
;             load-action (action-pattern)
;             
;             set debug-indent-level (debug-indent-level - 2)
;             report true
;           ]
;           [
;             output-debug-message ("One or more of the patches directly north, east, south and west of me do not contain visible turtles or these patches have tiles on them so I am NOT surrounded") (who)
;             set debug-indent-level (debug-indent-level - 2)
;             report false
;           ]
         end
         
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;;; "UPDATE-ENVIRONMENT" PROCEDURE ;;;
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         
         ;Updates the current simulation environment by:
         ; 1) Incrementing the current time in either a training or non-training context by 
         ;    the value specified in the global 'time-incremenet' variable
         ; 2) Decreasing the lifespan of tiles and holes by the value specified in the global 
         ;    'time-incremenet' variable
         ; 3) Hiding all non "tiles" and "holes" turtle breeds if their 'training-time' or
         ;    'game-time' variable values are less than or equal to the 'current-training-time'
         ;    or 'current-game-time" variable values.
         ; 4) Ending the game if no non "tiles" and "holes" turtle breeds are visble.
         to update-environment
           set debug-indent-level (debug-indent-level + 1)
           output-debug-message ("EXECUTING 'update-environment' PROCEDURE...") ("")
           set debug-indent-level (debug-indent-level + 1)
           output-debug-message(word "CHECKING TO SEE IF GAME IS BEING PLAYED IN TRAINING CONTEXT I.E IS THE GLOBAL 'training?' VARIABLE (" training? ") SET TO TRUE?") ("")
           
           ifelse(training?)[
             output-debug-message (word "GAME IS BEING PLAYED IN TRAINING CONTEXT.  INCREMENTING GLOBAL 'current-training-time' VARIABLE (" current-training-time ") BY GLOBAL 'time-increment' VARIABLE (" time-increment ")...") ("")
             set current-training-time ( precision (current-training-time + time-increment) (1) )
             output-debug-message (word "GLOBAL 'current-training-time' VARIABLE NOW SET TO: " current-training-time ".") ("")
           ]
           [
             output-debug-message (word "GAME IS BEING PLAYED IN NON-TRAINING CONTEXT.  INCREMENTING GLOBAL 'current-game-time' VARIABLE (" current-game-time ") BY GLOBAL 'time-increment' VARIABLE (" time-increment ")...") ("")
             set current-game-time ( precision (current-game-time + time-increment) (1) )
             output-debug-message (word "GLOBAL 'current-game-time' VARIABLE NOW SET TO: " current-game-time ".") ("")
           ]
           
           output-debug-message ("ASKING ALL TILES AND HOLES TO AGE...") ("")
           ask tiles [age]
           ask holes [age]
           
           output-debug-message ("ASKING ALL chrest-turtles TO SET THEIR 'hidden?' VARIABLE TO TRUE IF THEIR 'training-time' OR 'play-time' VARIABLE IS LESS THAN/EQUAL TO 'current-training-time' OR 'current-game-time'...") ("")
           ask chrest-turtles[
             set debug-indent-level (debug-indent-level + 1)
             output-debug-message (word "Checking to see if I am playing the game in a training context i.e is the global 'training?' variable (" training? ") set to true?") (who)
             ifelse(training?)[
               output-debug-message (word "I am playing the game in a training context so I need to check and see if my 'training-time' variable (" training-time ") is less than or equal to the global 'current-training-time' variable (" current-training-time ").") (who)
               if(training-time <= current-training-time)[
                 output-debug-message ("My 'training-time' variable is equal to the global 'current-training-time' value so I'll set my 'hidden?' variable to true...") (who)
                 set hidden? true
               ]
               
             ]
             [
               output-debug-message (word "I am playing the game in a non-training context so I need to check and see if my 'play-time' variable (" play-time ") is less than or equal to the global 'current-game-time' variable (" current-game-time ").") (who)
               if(play-time <= current-game-time)[
                 output-debug-message ("My 'play-time' variable is equal to the global 'current-game-time' value so I'll set my 'hidden?' variable to true...") (who)
                 set hidden? true
               ]
             ]
             set debug-indent-level (debug-indent-level - 1)
           ]
           
           set debug-indent-level (debug-indent-level - 2)
         end
         
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;;; "UPDATE-PLOT" PROCEDURE ;;;
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         
         ;Plots the value specified by the second parameter passed to this function on
         ;the plot specified by the first parameter passed to this function for the
         ;calling turtle.
         ;
         ;         Name              Data Type     Description
         ;         ----              ---------     -----------
         ;@param   name-of-plot      String        The name of the plot to be updated.
         ;@param   value             Float         The value to be plotted.
         to update-plot [name-of-plot value]
           set debug-indent-level (debug-indent-level + 1)
           output-debug-message ("EXECUTING THE 'update-plot' PROCEDURE...") ("")
           set debug-indent-level (debug-indent-level + 1)
           output-debug-message (word "The name of the plot to update is: '" name-of-plot "' and the y-value to plot is: '" value "'.") (who)
           
           set-current-plot name-of-plot
           set-current-plot-pen (word "Turtle " who)
           plot value
           
           set debug-indent-level (debug-indent-level - 2)
         end
         
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
         ;;; "WAY-CLEAR?" PROCEDURE ;;;
         ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
           
         ;Determines whether the patch immediately ahead of the calling turtle
         ;(ahead with respect to the calling turtle's current heading) has any
         ;turtles on it.
         ;
         ;         Name              Data Type     Description
         ;         ----              ---------     -----------
         ;@return  -                 Boolean       Boolean true indicates that the patch ahead
         ;                                         contains no turtles.  Boolean false indicates
         ;                                         that the patch ahead does contain turtles.
         to-report way-clear?
           set debug-indent-level (debug-indent-level + 1)
           output-debug-message ("EXECUTING THE 'way-clear?' PROCEDURE...") ("")
           set debug-indent-level (debug-indent-level + 1)
           output-debug-message (word "Checking to see if there are any visible turtles on the patch immediately ahead of me with heading: '" heading "'...") (who)
           
           ifelse(any? (turtles-on patch-ahead 1) with [hidden? = false])[ 
             output-debug-message (word "The way ahead is not clear.") (who)
             set debug-indent-level (debug-indent-level - 2)
             report false 
           ]
           [ 
             output-debug-message (word "The way ahead is clear.") (who)
             set debug-indent-level (debug-indent-level - 2)
             report true 
           ]
         end
  
@#$#@#$#@
GRAPHICS-WINDOW
147
10
577
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

BUTTON
12
10
93
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
579
10
805
174
Scores
Time
Score
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

BUTTON
12
43
93
76
NIL
play
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
579
324
739
471
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
899
324
1059
471
Visual LTM Avg. Depth
Time
Avg. Depth
0.0
10.0
0.0
5.0
true
false
"" ""
PENS

MONITOR
12
114
143
159
Training Time (s)
current-training-time
1
1
11

PLOT
739
324
899
471
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
1059
324
1219
471
Action LTM Avg. Depth
Time
Avg. Depth
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

MONITOR
12
159
143
204
Non-training Time (s)
current-game-time
1
1
11

MONITOR
13
294
143
339
Tile Birth Prob.
tile-birth-prob
1
1
11

MONITOR
13
339
143
384
Hole Birth Prob
hole-birth-prob
17
1
11

MONITOR
13
384
143
429
Tile Lifespan (s)
tile-lifespan
1
1
11

MONITOR
13
429
143
474
Hole Lifespan (s)
hole-lifespan
1
1
11

PLOT
804
10
1030
174
Num Visual-Action Links
Time
Total # Action Links
0.0
10.0
0.0
10.0
true
false
"" ""
PENS

MONITOR
12
204
143
249
Tile Born Every (s)
tile-born-every
1
1
11

MONITOR
13
249
143
294
Hole Born Every (s)
hole-born-every
1
1
11

SWITCH
12
78
122
111
debug?
debug?
0
1
-1000

PLOT
579
174
739
324
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
739
174
899
324
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

@#$#@#$#@
# CHREST Tileworld  
## CREDITS

**Programmer:** Martyn Lloyd-Kelly  <martynlloydkelly@gmail.com>

## MODEL DESCRIPTION
The "Tileworld" testbed was first formally described in:

Martha Pollack and Marc Ringuette. _"Introducing the Tileworld: experimentally evaluating agent architectures."_  Thomas Dietterich and William Swartout ed. In Proceedings of the Eighth National Conference on Artificial Intelligence,  p. 183--189, AAAI Press. 1990.

This model is built upon the "Tileworld" Netlogo model originally developed by Jose M. Vidal.  The model itself and details thereof can be found at the following website:
http://jmvidal.cse.sc.edu/netlogomas/tileworld/index.html

The player turtles in this model are endowed with instances of the Java implementation of the CHREST architecture developed principally by Prof. Fernand Gobet and Dr. Peter Lane. See the following website for more details regarding the CHREST architecture: 
http://www.chrest.info/

Players score a point for pushing tiles into holes which appear at random and are transient.  The probability of new tiles/holes being created and how long they exist for can be altered by the user to make the model environment more or less dynamic.  The length of a game is constrained by a user-specified length of time.

Players are not capable of pushing more than one tile at a time, if a tile is blocked then the player must realign themselves and push the tile from a different direction.  Each patch may only hold either a player, a tile or a hole.  Other players and holes can not be pushed.

Based upon current visual information, player turtles are capable of making decisions about what to do based upon current visual information or, if they are CHREST turtles, can make a decision about what to do by associating visual patterns with action patterns.  In the model, decision-making takes time, the length of time taken depends upon how complicated the decision-making procedure is.  Associating visual and action patterns however, takes significantly less time and therefore, should allow the player to perform more actions in less time resulting in higher scores.

Of course, the quality of actions is also paramount in securing better scores so CHREST turtles are also capable of reinforcing associations between visual and action patterns if they have led to the successful filling of a hole with a tile.

Players can either go through a period of training before playing a real game or simply play a real game.  Again, this decision is left to the user.

## MODEL REQUIREMENTS
This model requires that you have the following Netlogo extensions installed into the "extenstions" directory of your Netlogo distribution:

  * CHREST - found at https://github.com/mlk5060/chrest-netlogo-extension
  * String - found at https://github.com/NetLogo/String-Extension/

## AIM OF THE MODEL
The aim of this model is to investigate the interplay between _talent_ and _practice_ using the CHREST architecture as a model of cognition in an environment whose dynanism is not just a result of the actions of players.

"Talent" is embodied by the following parameters that can be set for players:

  * The size of a turtle's the sight-radius: larger sight-radii equates to greater talent since increasing the amount of the Tileworld that can be seen equates to greater complexity and more opportunities to score (more tiles and holes can be seen in one percept).  See: Gerardo I. Simari and Simon Parsons. _"On Approximating the Best Decision for an Autonomous Agent"_ Sixth Workshop on Game Theoretic and Decision Theoretic Agents (GTDT 2004) at the Third Conference on Autonomous Agents and Multi-agent Systems (AAMAS 2004), pp. 91-100.

"Expertise" is embodied by the size and quality of a CHREST turtle's LTM.  The size of this should increase if CHREST turtles are presented with new information more frequently and are allowed to learn for longer periods of time.

## CHREST TURTLE BEHAVIOUR
The behaviour of CHREST turtles in the model is driven by the generation and recognition of _visual_ and _action_ patterns; symbolic representations of the current environment and the actions performed within it.  Before and after the performance of every action, the CHREST turtle will generate a visual pattern composed of a representation of what objects it can see and where the object is located using x/y coordinates relative from the CHREST turtle's current location to the object.  For example, the visual pattern: [A, 3, 1] indicates that the player can see another player, A, 3 patches to its east and 1 patch north of itself.  

Action patterns are generated by reasoning with the current visual pattern about what to do next.  The action pattern is then loaded for execution and performed when the length of time specified by the CHREST turtle's _action-performance-time_ has elapsed.  Action patterns look similiar to visual patterns but they instead describe what action should be/was performed given a visual pattern.  For example, the action pattern: [PT, 0, 1] indicates that the player should push a tile, PT, 1 patch (1) along heading 0 (north).

Since these patterns can be stored in the CHREST turtle's long-term memory (hereafter referred to as "LTM"), CHREST turtles are capable of associating the visual pattern that generated the action pattern and the action pattern generated together.  When a CHREST turtle successfully pushes a tile into a hole, this triggers a _reinforcement_ of all the visual-action pattern links present in the CHREST turtle's short-term memory (hereafter referred to as "STM").  This reinforcement takes the form of adding 1 to the weight of the link between the visual and action patterns present in STM (if the links exist). 

This enables the CHREST turtle's dual-process theory of behaviour: when a CHRESt turtle generates a visual pattern, it will then try to recognise this visual pattern i.e. see if it already exists in LTM.  If it does, the CHREST turtle will then check to see if it has an action pattern associated with this visual pattern in its LTM.  If it does then three situations may be true:

  1. The visual pattern is associated with only one visual pattern.  In this case, the action is performed. 
  2. The visual pattern is associated with multiple action patterns and these associations have heterogenous weights.  In this case, the action pattern whose association is weighted most is selected.  
  3. The visual pattern is associated with multiple action patterns and these associations have homogenous weights. In this case, one action pattern is selected at random with a 1 in _n_ probability (_n_ = number of action patterns whose associations weigh the most). 

It may be true that the visual pattern is not recognised or that the visual pattern is not associated with any action patterns in LTM.  In this case, a heuristic is employed, based upon the content of the current visual pattern:

  1. If the CHREST turtle can see one or more tiles and holes, it will attempt to push the tile closest to the hole that is closest to itself into this hole.
  2. If the CHREST turtle can see one or more tiles but no holes, it will attempt to push the tile closest to it along the heading it approaches it at.
  3. If the CHREST turtle can see no tiles or holes, it will select a heading at random to move in.

A CHREST turtle will attempt to associate the visual patterns generated in the cases above with the action patterns generated in response to them with the exception of the action patterns generated in the third case.  This is because the environment is dynamic i.e. tiles and holes appear at random and therefore, favouring one random heading over another does not impart any benefit upon the potential score of a player.
 
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
NetLogo 5.0.5
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
