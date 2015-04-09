#!/bin/bash       
TOP_LEVEL_DIRECTORY=$(pwd)   
SCENARIO_NUMBER=1
while [ $SCENARIO_NUMBER -le 27 ]; do
	mkdir "Scenario$SCENARIO_NUMBER"
	cd "Scenario$SCENARIO_NUMBER"
	if [ $SCENARIO_NUMBER -le 9 ]; then
		ENV_COMPLEXITY=1
		if [ $SCENARIO_NUMBER -le 3 ]; then
			NUM_PLAYERS=2
			if [ $SCENARIO_NUMBER -eq 1 ]; then
				AGENT_TYPE=1
			fi
			if [ $SCENARIO_NUMBER -eq 2 ]; then
				AGENT_TYPE=2
			fi
			if [ $SCENARIO_NUMBER -eq 3 ]; then
				AGENT_TYPE=3
			fi
		fi
		if [ $SCENARIO_NUMBER -ge 4 -a $SCENARIO_NUMBER -le 6 ]; then
			NUM_PLAYERS=4
			if [ $SCENARIO_NUMBER -eq 4 ]; then
				AGENT_TYPE=1
			fi
			if [ $SCENARIO_NUMBER -eq 5 ]; then
				AGENT_TYPE=2
			fi
			if [ $SCENARIO_NUMBER -eq 6 ]; then
				AGENT_TYPE=3
			fi
		fi
		if [ $SCENARIO_NUMBER -ge 7 ]; then
			NUM_PLAYERS=8
			if [ $SCENARIO_NUMBER -eq 7 ]; then
				AGENT_TYPE=1
			fi
			if [ $SCENARIO_NUMBER -eq 8 ]; then
				AGENT_TYPE=2
			fi
			if [ $SCENARIO_NUMBER -eq 9 ]; then
				AGENT_TYPE=3
			fi
		fi
	fi
	if [ $SCENARIO_NUMBER -gt 9 -a $SCENARIO_NUMBER -le 18 ]; then
		ENV_COMPLEXITY=2
		 if [ $SCENARIO_NUMBER -le 12 ]; then
			NUM_PLAYERS=2
			if [ $SCENARIO_NUMBER -eq 10 ]; then
				AGENT_TYPE=1
			fi
			if [ $SCENARIO_NUMBER -eq 11 ]; then
				AGENT_TYPE=2
			fi
			if [ $SCENARIO_NUMBER -eq 12 ]; then
				AGENT_TYPE=3
			fi
		fi
		if [ $SCENARIO_NUMBER -ge 13 -a $SCENARIO_NUMBER -le 15 ]; then
			NUM_PLAYERS=4
			if [ $SCENARIO_NUMBER -eq 13 ]; then
				AGENT_TYPE=1
			fi
			if [ $SCENARIO_NUMBER -eq 14 ]; then
				AGENT_TYPE=2
			fi
			if [ $SCENARIO_NUMBER -eq 15 ]; then
				AGENT_TYPE=3
			fi
		fi
		if [ $SCENARIO_NUMBER -ge 16 ]; then
			NUM_PLAYERS=8
			if [ $SCENARIO_NUMBER -eq 16 ]; then
				AGENT_TYPE=1
			fi
			if [ $SCENARIO_NUMBER -eq 17 ]; then
				AGENT_TYPE=2
			fi
			if [ $SCENARIO_NUMBER -eq 18 ]; then
				AGENT_TYPE=3
			fi
		fi
	fi
	if [ $SCENARIO_NUMBER -gt 18 -a $SCENARIO_NUMBER -le 27 ]; then
		ENV_COMPLEXITY=3
		if [ $SCENARIO_NUMBER -le 21 ]; then
			NUM_PLAYERS=2
			if [ $SCENARIO_NUMBER -eq 19 ]; then
				AGENT_TYPE=1
			fi
			if [ $SCENARIO_NUMBER -eq 20 ]; then
				AGENT_TYPE=2
			fi
			if [ $SCENARIO_NUMBER -eq 21 ]; then
				AGENT_TYPE=3
			fi
		fi
		if [ $SCENARIO_NUMBER -ge 22 -a $SCENARIO_NUMBER -le 24 ]; then
			NUM_PLAYERS=4
			if [ $SCENARIO_NUMBER -eq 22 ]; then
				AGENT_TYPE=1
			fi
			if [ $SCENARIO_NUMBER -eq 23 ]; then
				AGENT_TYPE=2
			fi
			if [ $SCENARIO_NUMBER -eq 24 ]; then
				AGENT_TYPE=3
			fi
		fi
		if [ $SCENARIO_NUMBER -ge 25 ]; then
			NUM_PLAYERS=8
			if [ $SCENARIO_NUMBER -eq 25 ]; then
				AGENT_TYPE=1
			fi
			if [ $SCENARIO_NUMBER -eq 26 ]; then
				AGENT_TYPE=2
			fi
			if [ $SCENARIO_NUMBER -eq 27 ]; then
				AGENT_TYPE=3
			fi
		fi
	fi
	cp "$TOP_LEVEL_DIRECTORY/EnvComplexity$ENV_COMPLEXITY.txt" "$TOP_LEVEL_DIRECTORY/Scenario${SCENARIO_NUMBER}/Scenario${SCENARIO_NUMBER}Settings.txt"
	cat "$TOP_LEVEL_DIRECTORY/AgentType$AGENT_TYPE.txt" >> "$TOP_LEVEL_DIRECTORY/Scenario${SCENARIO_NUMBER}/Scenario${SCENARIO_NUMBER}Settings.txt"
	sed -i "s/create-chrest-turtles/create-chrest-turtles $NUM_PLAYERS/g" "$TOP_LEVEL_DIRECTORY/Scenario${SCENARIO_NUMBER}/Scenario${SCENARIO_NUMBER}Settings.txt"
	let MAX_TURTLE_ID=NUM_PLAYERS-1
	sed -i "s/0:/(0-$MAX_TURTLE_ID):/g" "$TOP_LEVEL_DIRECTORY/Scenario${SCENARIO_NUMBER}/Scenario${SCENARIO_NUMBER}Settings.txt"

	REPEAT_NUMBER=1
	while [ $REPEAT_NUMBER -le 10 ]; do
		mkdir "Repeat$REPEAT_NUMBER"
		touch "Repeat$REPEAT_NUMBER/blankSoGitPicksUpDirectory$REPEAT_NUMBER.txt"
		let REPEAT_NUMBER=REPEAT_NUMBER+1
	done
	cd "$TOP_LEVEL_DIRECTORY"
	let SCENARIO_NUMBER=SCENARIO_NUMBER+1
done