#!/bin/bash       
TOP_LEVEL_DIRECTORY=$(pwd)
SCENARIO_NUMBER=1
while [ $SCENARIO_NUMBER -le 972 ]; do
	mkdir "Scenario$SCENARIO_NUMBER"
	cd "Scenario$SCENARIO_NUMBER"
	if [ $SCENARIO_NUMBER -le 324 ]; then
		ENV_COMPLEXITY=1
		if [ $SCENARIO_NUMBER -le 108 ]; then
			NUM_PLAYERS=2
			if [ $SCENARIO_NUMBER -le 54 ]; then
				AGENT_TYPE=2
				if [ $SCENARIO_NUMBER -le 9 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 18 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 27 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 36 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 45 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			else
				AGENT_TYPE=3
				if [ $SCENARIO_NUMBER -le 63 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 72 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 81 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 90 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 99 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			fi
		fi
		if [ $SCENARIO_NUMBER -gt 108 -a $SCENARIO_NUMBER -le 216 ]; then
			NUM_PLAYERS=4
			if [ $SCENARIO_NUMBER -le 162 ]; then
				AGENT_TYPE=2
				if [ $SCENARIO_NUMBER -le 117 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 126 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 135 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 144 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 153 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			else
				AGENT_TYPE=3
				if [ $SCENARIO_NUMBER -le 171 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 180 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 189 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 198 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 207 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			fi
		fi
		if [ $SCENARIO_NUMBER -gt 216 ]; then
			NUM_PLAYERS=8
			if [ $SCENARIO_NUMBER -le 270 ]; then
				AGENT_TYPE=2
				if [ $SCENARIO_NUMBER -le 225 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 234 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 243 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 252 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 261 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			else
				AGENT_TYPE=3
				if [ $SCENARIO_NUMBER -le 279 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 288 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 297 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 306 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 315 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			fi
		fi
	fi
	if [ $SCENARIO_NUMBER -gt 324 -a $SCENARIO_NUMBER -le 648 ]; then
		ENV_COMPLEXITY=2
		if [ $SCENARIO_NUMBER -le 432 ]; then
			NUM_PLAYERS=2
			if [ $SCENARIO_NUMBER -le 378 ]; then
				AGENT_TYPE=2
				if [ $SCENARIO_NUMBER -le 333 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 342 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 351 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 360 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 369 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			else
				AGENT_TYPE=3
				if [ $SCENARIO_NUMBER -le 387 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 396 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 405 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 414 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 423 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			fi
		fi
		if [ $SCENARIO_NUMBER -gt 432 -a $SCENARIO_NUMBER -le 540 ]; then
			NUM_PLAYERS=4
			if [ $SCENARIO_NUMBER -le 486 ]; then
				AGENT_TYPE=2
				if [ $SCENARIO_NUMBER -le 441 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 450 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 459 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 468 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 477 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			else
				AGENT_TYPE=3
				if [ $SCENARIO_NUMBER -le 495 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 504 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 513 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 522 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 531 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			fi
		fi
		if [ $SCENARIO_NUMBER -gt 540 ]; then
			NUM_PLAYERS=8
			if [ $SCENARIO_NUMBER -le 594 ]; then
				AGENT_TYPE=2
				if [ $SCENARIO_NUMBER -le 549 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 558 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 567 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 576 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 585 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			else
				AGENT_TYPE=3
				if [ $SCENARIO_NUMBER -le 603 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 612 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 621 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 630 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 639 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			fi
		fi
	fi
	if [ $SCENARIO_NUMBER -gt 648 ]; then
		ENV_COMPLEXITY=3
		if [ $SCENARIO_NUMBER -le 756 ]; then
			NUM_PLAYERS=2
			if [ $SCENARIO_NUMBER -le 702 ]; then
				AGENT_TYPE=2
				if [ $SCENARIO_NUMBER -le 657 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 666 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 675 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 684 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 693 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			else
				AGENT_TYPE=3
				if [ $SCENARIO_NUMBER -le 711 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 720 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 729 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 738 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 747 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			fi
		fi
		if [ $SCENARIO_NUMBER -gt 756 -a $SCENARIO_NUMBER -le 864 ]; then
			NUM_PLAYERS=4
			if [ $SCENARIO_NUMBER -le 810 ]; then
				AGENT_TYPE=2
				if [ $SCENARIO_NUMBER -le 765 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 774 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 783 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 792 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 801 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			else
				AGENT_TYPE=3
				if [ $SCENARIO_NUMBER -le 819 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 828 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 837 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 846 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 855 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			fi
		fi
		if [ $SCENARIO_NUMBER -gt 864 ]; then
			NUM_PLAYERS=8
			if [ $SCENARIO_NUMBER -le 918 ]; then
				AGENT_TYPE=2
				if [ $SCENARIO_NUMBER -le 873 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 882 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 891 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 900 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 909 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			else
				AGENT_TYPE=3
				if [ $SCENARIO_NUMBER -le 927 ]; then
					EPISODIC_MEMORY_SIZE=5
				elif [ $SCENARIO_NUMBER -le 936 ]; then
					EPISODIC_MEMORY_SIZE=6
				elif [ $SCENARIO_NUMBER -le 945 ]; then
					EPISODIC_MEMORY_SIZE=7
				elif [ $SCENARIO_NUMBER -le 954 ]; then
					EPISODIC_MEMORY_SIZE=8
				elif [ $SCENARIO_NUMBER -le 963 ]; then
					EPISODIC_MEMORY_SIZE=9
				else
					EPISODIC_MEMORY_SIZE=10
				fi
			fi
		fi
	fi

	MOD=$(($SCENARIO_NUMBER%9))
	case $MOD in
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

	cp "$TOP_LEVEL_DIRECTORY/EnvComplexity$ENV_COMPLEXITY.txt" "$TOP_LEVEL_DIRECTORY/Scenario${SCENARIO_NUMBER}/Scenario${SCENARIO_NUMBER}Settings.txt"
	cat "$TOP_LEVEL_DIRECTORY/../AgentType$AGENT_TYPE.txt" >> "$TOP_LEVEL_DIRECTORY/Scenario${SCENARIO_NUMBER}/Scenario${SCENARIO_NUMBER}Settings.txt"
	echo -e "\n\ndiscount-rate\n0:$DISCOUNT_RATE\n\nmax-length-of-episodic-memory\n0:$EPISODIC_MEMORY_SIZE" >> "$TOP_LEVEL_DIRECTORY/Scenario${SCENARIO_NUMBER}/Scenario${SCENARIO_NUMBER}Settings.txt"
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
