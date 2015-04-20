#!/bin/bash
RESULTS_DIR=`pwd`
RESULTS_FILE="$RESULTS_DIR/OverallResults.csv"
SCENARIO_NUMBER=1

#If the file specified by the RESULTS_FILE variable exists, remove it.
if [ -e "$RESULTS_FILE" ]
	then
		rm "$RESULTS_FILE"
fi

#Create the file specified by the RESULTS_FILE variable and set its 
#permissions so that the file's owner and members of the owner's 
#group can read, write and execute the file while others can only 
#read it. 
touch "$RESULTS_FILE"
chmod 774 "$RESULTS_FILE"

#Append the string below to the file specified by the RESULTS_FILE variable.
#The string can be interpreted as giving column headers to a table. 
echo "env_complexity, num_players, agent_type, repeat, avg_score, avg_delib_time, avg_num_va_links, avg_num_non_visual_cd, avg_num_visual_cd, avg_num_pat_rcg, avg_vis_ltm_size_, avg_vis_ltm_depth, avg_act_ltm_size" >> "$RESULTS_FILE"

#Main loop
while [ $SCENARIO_NUMBER -le 27 ]; do
	case $SCENARIO_NUMBER in
		1 )
			INDEPENDENT_VARIABLE_STRING="1, 2, 1";;
		2 )
			INDEPENDENT_VARIABLE_STRING="1, 2, 2";;
		3 )
			INDEPENDENT_VARIABLE_STRING="1, 2, 3";;
		4 )
			INDEPENDENT_VARIABLE_STRING="1, 4, 1";;
		5 )
			INDEPENDENT_VARIABLE_STRING="1, 4, 2";;
		6 )
			INDEPENDENT_VARIABLE_STRING="1, 4, 3";;
		7 )
			INDEPENDENT_VARIABLE_STRING="1, 8, 1";;
		8 )
			INDEPENDENT_VARIABLE_STRING="1, 8, 2";;
		9 )
			INDEPENDENT_VARIABLE_STRING="1, 8, 3";;
		10 )
			INDEPENDENT_VARIABLE_STRING="2, 2, 1";;
		11 )
			INDEPENDENT_VARIABLE_STRING="2, 2, 2";;
		12 )
			INDEPENDENT_VARIABLE_STRING="2, 2, 3";;
		13 )
			INDEPENDENT_VARIABLE_STRING="2, 4, 1";;
		14 )
			INDEPENDENT_VARIABLE_STRING="2, 4, 2";;
		15 )
			INDEPENDENT_VARIABLE_STRING="2, 4, 3";;
		16 )
			INDEPENDENT_VARIABLE_STRING="2, 8, 1";;
		17 )
			INDEPENDENT_VARIABLE_STRING="2, 8, 2";;
		18 )
			INDEPENDENT_VARIABLE_STRING="2, 8, 3";;
		19 )
			INDEPENDENT_VARIABLE_STRING="3, 2, 1";;
		20 )
			INDEPENDENT_VARIABLE_STRING="3, 2, 2";;
		21 )
			INDEPENDENT_VARIABLE_STRING="3, 2, 3";;
		22 )
			INDEPENDENT_VARIABLE_STRING="3, 4, 1";;
		23 )
			INDEPENDENT_VARIABLE_STRING="3, 4, 2";;
		24 )
			INDEPENDENT_VARIABLE_STRING="3, 4, 3";;
		25 )
			INDEPENDENT_VARIABLE_STRING="3, 8, 1";;
		26 )
			INDEPENDENT_VARIABLE_STRING="3, 8, 2";;
		27 )
			INDEPENDENT_VARIABLE_STRING="3, 8, 3";;
	esac

	#Set repeat number and loop through repeat directories.
	REPEAT_NUMBER=1
	while [ $REPEAT_NUMBER -lt 11 ]; do

		#Check to see if the current scenario directory contains the current repeat directory and
		#output file.
		if [ -e "$RESULTS_DIR/Scenario$SCENARIO_NUMBER/Repeat$REPEAT_NUMBER/Repeat$REPEAT_NUMBER.txt" ]
			then
				#Check if file is readable (done seperately to the existence check so that a relevant 
				#error message can be output if not).
				if [ -r "$RESULTS_DIR/Scenario$SCENARIO_NUMBER/Repeat$REPEAT_NUMBER/Repeat$REPEAT_NUMBER.txt" ]
					then
						cd "$RESULTS_DIR/Scenario$SCENARIO_NUMBER/Repeat$REPEAT_NUMBER"
						# 1) 'grep' the line containing the variable that needs to be stored.
						# 2) Pipe the result of step 1 to 'cut' and seperate the line when a colon is encountered.
						#    This should create 2 fields: the first is the name of the variable and the second is
						#    the actual variable.
						# 3) Pipe the second field from step 2 to 'sed' and trim all whitespace from the variable.
						# 4) Store the result of step 3 in a variable so it may be appended to the overall results 
						#    file.
						AVG_SCORE=$(grep "Avg score" "Repeat$REPEAT_NUMBER.txt" | cut -d':' -f2 | awk '{gsub(/^ +|  +$/,"")}1' | tr -d '\r')
						AVG_DELIBERATION_TIME=$(grep "Avg deliberation time" "Repeat$REPEAT_NUMBER.txt" | cut -d':' -f2 | awk '{gsub(/^ +|  +$/,"")}1' | tr -d '\r')
						AVG_NUM_VISUAL_ACTION_LINKS=$(grep "Avg # visual-action links" "Repeat$REPEAT_NUMBER.txt" | cut -d':' -f2 | awk '{gsub(/^ +|  +$/,"")}1' | tr -d '\r')
						AVG_NUM_PROBLEM_SOLVING=$(grep "Avg # problem-solving" "Repeat$REPEAT_NUMBER.txt" | cut -d':' -f2 | awk '{gsub(/^ +|  +$/,"")}1' | tr -d '\r')
						AVG_NUM_PATTERN_RECOGNITIONS=$(grep "Avg # pattern recognitions" "Repeat$REPEAT_NUMBER.txt" | cut -d':' -f2 | awk '{gsub(/^ +|  +$/,"")}1' | tr -d '\r')
						AVG_NUM_NODES_VISUAL_LTM=$(grep "Avg # visual LTM nodes" "Repeat$REPEAT_NUMBER.txt" | cut -d':' -f2 | awk '{gsub(/^ +|  +$/,"")}1' | tr -d '\r')
						AVG_DEPTH_VISUAL_LTM=$(grep "Avg depth visual LTM" "Repeat$REPEAT_NUMBER.txt" | cut -d':' -f2 | awk '{gsub(/^ +|  +$/,"")}1' | tr -d '\r')
						AVG_NUM_NODES_ACTION_LTM=$(grep "Avg # action LTM nodes" "Repeat$REPEAT_NUMBER.txt" | cut -d':' -f2 | awk '{gsub(/^ +|  +$/,"")}1' | tr -d '\r')
						echo "$INDEPENDENT_VARIABLE_STRING, $REPEAT_NUMBER, $AVG_SCORE, $AVG_DELIBERATION_TIME, $AVG_NUM_VISUAL_ACTION_LINKS, $AVG_NUM_PROBLEM_SOLVING, $AVG_NUM_PATTERN_RECOGNITIONS, $AVG_NUM_NODES_VISUAL_LTM, $AVG_DEPTH_VISUAL_LTM, $AVG_NUM_NODES_ACTION_LTM" >> "$RESULTS_FILE"
					else
						echo "$RESULTS_DIR/Scenario$SCENARIO_NUMBER/Repeat$REPEAT_NUMBER/Repeat$REPEAT_NUMBER.txt does not have read permission."
				fi
			else
				echo "$RESULTS_DIR/Scenario$SCENARIO_NUMBER/Repeat$REPEAT_NUMBER/Repeat$REPEAT_NUMBER.txt does not exist."
		fi
		let REPEAT_NUMBER=REPEAT_NUMBER+1
	done
	let SCENARIO_NUMBER=SCENARIO_NUMBER+1
done
cd "$RESULTS_DIR"