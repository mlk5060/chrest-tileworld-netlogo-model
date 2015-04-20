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
echo "complexity, agent_type, episodic_mem_size, discount_rate, repeat, avg_score, avg_delib_time, avg_num_va_links, avg_num_prob_sol, avg_num_pat_rcg, avg_vis_ltm_size_, avg_vis_ltm_depth, avg_act_ltm_size" >> "$RESULTS_FILE"

#Main loop
while [ $SCENARIO_NUMBER -le 270 ]; do
	
	# Determine complexity
	INTEGER=$((SCENARIO_NUMBER/90))
	FRACTION=$((SCENARIO_NUMBER%90))
	if [ \( $INTEGER -eq 0 -a $FRACTION -gt 0 \) -o \( $INTEGER -eq 1 -a $FRACTION -eq 0 \) ]; then
		ENV_COMPLEXITY=1
		NUM_PLAYERS=2
		NUMERATOR=90
	elif [ \( $INTEGER -eq 1 -a $FRACTION -gt 0 \) -o \( $INTEGER -eq 2 -a $FRACTION -eq 0 \) ]; then
		ENV_COMPLEXITY=2
		NUM_PLAYERS=4
		NUMERATOR=180
	else
		ENV_COMPLEXITY=3
		NUM_PLAYERS=8
		NUMERATOR=270
	fi

	#Determine agent type
	if [ $SCENARIO_NUMBER -ge $((NUMERATOR-90)) -a $SCENARIO_NUMBER -le $(((NUMERATOR-90)+45)) ]; then
		AGENT_TYPE=2
		AGENT_TYPE_START=$((NUMERATOR-90))
	else
		AGENT_TYPE=3
		AGENT_TYPE_START=$((NUMERATOR-45))
	fi

	#Determine episodic memory size
	if [ $SCENARIO_NUMBER -ge $AGENT_TYPE_START -a $SCENARIO_NUMBER -le $(($AGENT_TYPE_START+9)) ]; then
		EPISODIC_MEMORY_SIZE=6
	elif [ $SCENARIO_NUMBER -ge $AGENT_TYPE_START -a $SCENARIO_NUMBER -le $(($AGENT_TYPE_START+18)) ]; then
		EPISODIC_MEMORY_SIZE=8
	elif [ $SCENARIO_NUMBER -ge $AGENT_TYPE_START -a $SCENARIO_NUMBER -le $(($AGENT_TYPE_START+27)) ]; then
		EPISODIC_MEMORY_SIZE=10
	elif [ $SCENARIO_NUMBER -ge $AGENT_TYPE_START -a $SCENARIO_NUMBER -le $(($AGENT_TYPE_START+36)) ]; then
		EPISODIC_MEMORY_SIZE=12
	elif [ $SCENARIO_NUMBER -ge $AGENT_TYPE_START -a $SCENARIO_NUMBER -le $(($AGENT_TYPE_START+45)) ]; then
		EPISODIC_MEMORY_SIZE=14
	fi


	#Determine discount rate
	FRACTION=$((SCENARIO_NUMBER%9))
	case $FRACTION in
		1)
			DISCOUNT_RATE=0.1;;
		2)
			DISCOUNT_RATE=0.2;;
		3)
			DISCOUNT_RATE=0.3;;
		4)
			DISCOUNT_RATE=0.4;;
		5)
			DISCOUNT_RATE=0.5;;
		6)
			DISCOUNT_RATE=0.6;;
		7)
			DISCOUNT_RATE=0.7;;
		8)
			DISCOUNT_RATE=0.8;;
		0)
			DISCOUNT_RATE=0.9;;
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
						echo "$ENV_COMPLEXITY, $AGENT_TYPE, $EPISODIC_MEMORY_SIZE, $DISCOUNT_RATE, $REPEAT_NUMBER, $AVG_SCORE, $AVG_DELIBERATION_TIME, $AVG_NUM_VISUAL_ACTION_LINKS, $AVG_NUM_PROBLEM_SOLVING, $AVG_NUM_PATTERN_RECOGNITIONS, $AVG_NUM_NODES_VISUAL_LTM, $AVG_DEPTH_VISUAL_LTM, $AVG_NUM_NODES_ACTION_LTM" >> "$RESULTS_FILE"
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