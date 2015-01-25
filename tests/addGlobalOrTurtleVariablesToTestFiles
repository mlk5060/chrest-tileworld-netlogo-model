#!/usr/bin/env bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
DEFAULT=$(tput sgr0)

trap ctrl_c

ctrl_c()
{
    printf "${DEFAULT}\n"
}

getTestSuitesToUpdate()
{
    outputTestSuitePrompt
    read -e TEST_SUITES #The -e flag enables tab-completion.

    while [[ $TEST_SUITES == "list" ]]; do
        printf "\n${MAGENTA}"
        ls -d */
        printf "${DEFAULT}"
        outputTestSuitePrompt
        read -e TEST_SUITES #The -e flag enables tab-completion.
    done

    printf "\n${YELLOW}Checking for existence of test-suites...${DEFAULT}"

    TEST_SUITE_NUMBER=1
    calculateTotalNumberTestSuites "$TEST_SUITES"
    ALL_SPECIFIED_SUITES_EXIST=true
    while [ "$TEST_SUITE_NUMBER" -le "$TOTAL_NUMBER_TEST_SUITES" ]; do
        setTestSuiteName
        if [ ! -d "$CURRENT_TEST_SUITE_NAME" ]; then
            printf "\n\n${RED}$CURRENT_TEST_SUITE_NAME is not a directory in the 'tests' directory, please rectify.${DEFAULT}"
            ALL_SPECIFIED_SUITES_EXIST=false
        fi
        let "TEST_SUITE_NUMBER+=1"
    done

    if [ "$ALL_SPECIFIED_SUITES_EXIST" = false ]; then
        getTestSuitesToUpdate 
    fi

    printf "\n${GREEN}OK, the test-suites to be updated are as follows:\n\n${MAGENTA}"
    printf "$(echo $TEST_SUITES | sed 's/ //g' | sed 's/\;/\n/g')"
    printf "\n\n${YELLOW}Is this correct (y/n)?"
    printf "\nMISTAKES MADE NOW CAN NOT BE UNDONE LATER!\n\n${DEFAULT}"
    read TEST_SUITES_CORRECT

    while [ "$TEST_SUITES_CORRECT" != "y" ] && [ "$TEST_SUITES_CORRECT" != "n" ]; do
        printf "\n${YELLOW}Please enter 'y' or 'n'\n\n${DEFAULT}"
        read TEST_SUITES_CORRECT
    done 
}

outputTestSuitePrompt()
{
    printf "\n\n${GREEN}What test suites would you like to update?"
    printf "\nIf you are unsure of what test-suites are available please enter 'list' to show all test-suites available."
    printf "\nFor editing of multiple test-suites, separate test-suite names with semi-colons (;)."
    printf "\nBe aware that this tool will insert new variable information in all files for specified test suites!${DEFAULT}\n\n"
}

calculateTotalNumberTestSuites()
{
    TOTAL_NUMBER_TEST_SUITES=`echo $1 | sed 's/[^;]//g' | wc -c`
}

setTestSuiteName(){
    #Takes the string of test suites specified by the user, splits on semi-colons, extracts the nth field from the split,
    #replaces all question marks with escaped question marks and removes all spaces and directory separators.
    CURRENT_TEST_SUITE_NAME=`echo $TEST_SUITES | cut -d';' -f"$TEST_SUITE_NUMBER" | sed 's/\?/\\?/g' | sed 's/ //g' | sed 's/\///g'` 
}

getNewVariableInfo(){
    printf "\n${GREEN}What is the name of the new variable you wish to insert into the test-suite files specified?\n\n${DEFAULT}"
    read NEW_VARIABLE_NAME

    printf "\n${GREEN}What should the value of this variable be set to?\n\n${DEFAULT}"
    read NEW_VARIABLE_VALUE

    printf "\n${GREEN}Is this new variable a breed-specific variable (y/n)?\n\n${DEFAULT}"
    read BREED_SPECIFIC_VARIABLE

    while [ "$BREED_SPECIFIC_VARIABLE" != "y" ] && [ "$BREED_SPECIFIC_VARIABLE" != "n" ]; do
        printf "\n${YELLOW}Please enter 'y' or 'n'\n\n${DEFAULT}"
        read BREED_SPECIFIC_VARIABLE
    done 

    printf "\n${GREEN}What variable name should the new variable information be inserted before in the test suite files?\n\n${DEFAULT}"
    read VARIABLE_TO_INSERT_BEFORE

    printf "\n${YELLOW}OK, is this information correct (y/n)?"
    printf "\nMISTAKES MADE NOW CAN NOT BE UNDONE LATER!"
    printf "\n\n${MAGENTA}New variable name: $NEW_VARIABLE_NAME"
    printf "\nNew variable value: $NEW_VARIABLE_VALUE"
    printf "\nIs new variable turtle-specific?: $BREED_SPECIFIC_VARIABLE"
    printf "\nVariable to insert new variable before in test-suite files: $VARIABLE_TO_INSERT_BEFORE\n\n${DEFAULT}"
    read NEW_VARIABLE_INFORMATION_CORRECT

    while [ "$NEW_VARIABLE_INFORMATION_CORRECT" != "y" ] && [ "$NEW_VARIABLE_INFORMATION_CORRECT" != "n" ]; do
        printf "\n${YELLOW}Please enter 'y' or 'n'\n\n${DEFAULT}"
        read NEW_VARIABLE_INFORMATION_CORRECT
    done 
}

printf "\n${BLUE}========================================================"
printf "\n=== ADD NEW VARIABLE INFORMATION TO TEST SUITES TOOL ==="
printf "\n========================================================${DEFAULT}"

getTestSuitesToUpdate

while [ "$TEST_SUITES_CORRECT" == "n" ]; do
    printf "\n${GREEN}OK, lets try that again!${DEFAULT}"
    getTestSuitesToUpdate
done

getNewVariableInfo
while [ "$NEW_VARIABLE_INFORMATION_CORRECT" == "n" ]; do
    printf "\n${GREEN}OK, lets try that again!${DEFAULT}"
    getNewVariableInfo
done

printf "\n${YELLOW}For each file in the test-suites specified, I'll check that:"
printf "\n1. The variable that the new variable is to be inserted before exists as a whole word on its own line."
printf "\n2. The new variable isn't already specified as a whole word on its own line.\n\n${DEFAULT}"

TEST_SUITE_NUMBER=1
declare -a TEST_FILES_TO_IGNORE
declare -a TEST_FILES_ALREADY_CONTAINING_NEW_VARIABLE
declare -a TEST_FILES_TO_PROCESS
TEST_FILES_TO_IGNORE_INDEX=0
TEST_FILES_ALREADY_CONTAINING_NEW_VARIABLE_INDEX=0
TEST_FILES_TO_PROCESS_INDEX=0

while [ "$TEST_SUITE_NUMBER" -le "$TOTAL_NUMBER_TEST_SUITES" ]; do
    setTestSuiteName
    
    for f in $(ls -1 "$CURRENT_TEST_SUITE_NAME")
    do

        NUMBER_OF_TIMES_VARIABLE_TO_INSERT_BEFORE_APPEARS_IN_FILE=$(grep -o -E -w "$VARIABLE_TO_INSERT_BEFORE" "$CURRENT_TEST_SUITE_NAME/$f" | wc -l)
        NUMBER_OF_TIMES_NEW_VARIABLE_APPEARS_IN_FILE=$(grep -o -E -w "$NEW_VARIABLE_NAME" "$CURRENT_TEST_SUITE_NAME/$f" | wc -l)

        if [ "$NUMBER_OF_TIMES_VARIABLE_TO_INSERT_BEFORE_APPEARS_IN_FILE" -eq "0" ] || [ "$NUMBER_OF_TIMES_VARIABLE_TO_INSERT_BEFORE_APPEARS_IN_FILE" -gt "1" ]; then
            TEST_FILES_TO_IGNORE[TEST_FILES_TO_IGNORE_INDEX]="$CURRENT_TEST_SUITE_NAME/$f:$NUMBER_OF_TIMES_VARIABLE_TO_INSERT_BEFORE_APPEARS_IN_FILE"
            let "TEST_FILES_TO_IGNORE_INDEX+=1"
            continue
        elif [ "$NUMBER_OF_TIMES_NEW_VARIABLE_APPEARS_IN_FILE" -ge "1" ]; then
            TEST_FILES_ALREADY_CONTAINING_NEW_VARIABLE[TEST_FILES_ALREADY_CONTAINING_NEW_VARIABLE_INDEX]="$CURRENT_TEST_SUITE_NAME/$f:$NUMBER_OF_TIMES_NEW_VARIABLE_APPEARS_IN_FILE"
            let "TEST_FILES_ALREADY_CONTAINING_NEW_VARIABLE_INDEX+=1"
            continue
        else
            TEST_FILES_TO_PROCESS[TEST_FILES_TO_PROCESS_INDEX]="$CURRENT_TEST_SUITE_NAME/$f"
            let "TEST_FILES_TO_PROCESS_INDEX+=1"
            continue
        fi
    done
    
    let "TEST_SUITE_NUMBER+=1"
done

if [ ${#TEST_FILES_TO_PROCESS[@]} -eq 0 ]; then
    printf "${RED}No test-suite file contained the variable '$VARIABLE_TO_INSERT_BEFORE'.  Please check the test files in question and try again.\n\n${DEFAULT}"
    exit
fi

if [ ${#TEST_FILES_TO_IGNORE[@]} -ge 1 ]; then
    printf "${RED}The following test-suite files either do not contain the variable name that the new variable should be inserted before ($VARIABLE_TO_INSERT_BEFORE) as a "
    printf "full word or contain it more than once:"
    printf "\n\n${MAGENTA}"
    
    for file in ${TEST_FILES_TO_IGNORE[@]}
    do
        filename=$(echo $file | cut -d: -f1)
        occurrences=$(echo $file | cut -d: -f2)
        printf "FILENAME: $filename   OCCURENCES: $occurrences\n"
    done
    
    printf "\n${RED}Do you want to continue and ignore these files (y) or quit the tool entirely (n)?\n\n${DEFAULT}"
    read CONTINUE
    
    while [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "n" ] ; do
        printf "\n${YELLOW}Please enter 'y' or 'n'\n\n${DEFAULT}"
        read CONTINUE
    done
fi

if [ "$CONTINUE" = "n" ]; then
    printf "\n"
    exit
fi

if [ ${#TEST_FILES_ALREADY_CONTAINING_NEW_VARIABLE[@]} -ge 1 ]; then
    printf "${RED}The following test-suite files already specify the new variable ($NEW_VARIABLE_NAME):"
    printf "\n\n${MAGENTA}"
    
    for file in ${TEST_FILES_ALREADY_CONTAINING_NEW_VARIABLE[@]}
    do
        filename=$(echo $file | cut -d: -f1)
        occurrences=$(echo $file | cut -d: -f2)
        printf "FILENAME: $filename   OCCURENCES: $occurrences\n"
    done
    
    printf "\n${RED}Do you want to continue and ignore these files (y) or quit the tool entirely (n)?\n\n${DEFAULT}"
    read CONTINUE
    
    while [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "n" ] ; do
        printf "${YELLOW}Please enter 'y' or 'n'\n\n${DEFAULT}"
        read CONTINUE
    done
fi

if [ "$CONTINUE" = "n" ]; then
    printf "\n"
    exit
fi

declare -a TEST_FILES_SUCCESSFULLY_PROCESSED
TEST_FILES_SUCCESSFULLY_PROCESSED_INDEX=0

if [ "$BREED_SPECIFIC_VARIABLE" = "y" ]; then
    declare -a FILES_WITH_NO_TURTLE_IDS
    declare -a TEST_FILES_TO_DEFINITELY_PROCESS
    FILES_WITH_NO_TURTLE_IDS_INDEX=0
    TEST_FILES_TO_DEFINITELY_PROCESS_INDEX=0

    for file in ${TEST_FILES_TO_PROCESS[@]}
    do
        TURTLE_IDS=$(grep -E -w -A 1 "$VARIABLE_TO_INSERT_BEFORE" "$file" | tr '\n' ',' | cut -d, -f2 | cut -d: -f1)

        if [ -z "$TURTLE_IDS" ]; then
            FILES_WITH_NO_TURTLE_IDS[FILES_WITH_NO_TURTLE_IDS_INDEX]="$file"
            let "FILES_WITH_NO_TURTLE_IDS_INDEX+=1"
        else
            TEST_FILES_TO_DEFINITELY_PROCESS[TEST_FILES_TO_DEFINITELY_PROCESS_INDEX]="$file"
            let "TEST_FILES_TO_DEFINITELY_PROCESS_INDEX+=1"
        fi
    done

    if [ ${#FILES_WITH_NO_TURTLE_IDS[@]} -ge 1 ]; then
        printf "${RED}There are no turtle ID's specified for the turtle variable '$VARIABLE_TO_INSERT_BEFORE' (the variable that the new variable is to be inserted before) in "
        printf "the following files:"
        printf "\n${MAGENTA}"
        for file in ${FILES_WITH_NO_TURTLE_IDS[@]}
        do
            printf "\n$file"
        done
        printf "\n\n${RED}Therefore, I am unable to insert new variable information into these files.  Please check that there are turtle IDs specified with values after "
        printf "the declaration of the $VARIABLE_TO_INSERT_BEFORE turtle variable in these files.  This specification should take either of the following forms:"
        printf "\n\nturtle_id:value"
        printf "\n(turtle_id-turtle_id):value"
        printf "\n\nDo you want to continue and ignore these files (y) or quit the tool entirely (n)?\n\n${DEFAULT}"
        read CONTINUE
        
        while [ "$CONTINUE" != "y" ] && [ "$CONTINUE" != "n" ] ; do
            printf "\n${YELLOW}Please enter 'y' or 'n'\n\n${DEFAULT}"
            read CONTINUE
        done

        if [ "$CONTINUE" = "n" ]; then
            printf "\n"
            exit
        fi
    fi

    for file in ${TEST_FILES_TO_DEFINITELY_PROCESS[@]}
    do
        LINE_NUMBER_TO_INSERT_INTO=$(grep -o -E -w -n "$VARIABLE_TO_INSERT_BEFORE" "$file" | cut -d: -f1 )
        `sed -i "${LINE_NUMBER_TO_INSERT_INTO}i $NEW_VARIABLE_NAME\n$TURTLE_IDS:$NEW_VARIABLE_VALUE\n" $file`
        TEST_FILES_SUCCESSFULLY_PROCESSED[TEST_FILES_SUCCESSFULLY_PROCESSED_INDEX]="$file:$LINE_NUMBER_TO_INSERT_INTO"
        let "TEST_FILES_SUCCESSFULLY_PROCESSED_INDEX+=1"
    done

  else
    for file in ${TEST_FILES_TO_PROCESS[@]}
    do
        LINE_NUMBER_TO_INSERT_INTO=$(grep -o -E -w -n "$VARIABLE_TO_INSERT_BEFORE" "$file" | cut -d: -f1)
        `sed -i "${LINE_NUMBER_TO_INSERT_INTO}i $NEW_VARIABLE_NAME\n$NEW_VARIABLE_VALUE\n" $file`
        TEST_FILES_SUCCESSFULLY_PROCESSED[TEST_FILES_SUCCESSFULLY_PROCESSED_INDEX]="$file:$LINE_NUMBER_TO_INSERT_INTO"
        let "TEST_FILES_SUCCESSFULLY_PROCESSED_INDEX+=1"
    done
fi

if [ ${#TEST_FILES_SUCCESSFULLY_PROCESSED[@]} -ge 1 ]; then
    printf "\n\n${GREEN}The following files were successfully processed and the new variable information should be found at the line number indicated for each file:\n${MAGENTA}"
    for file in ${TEST_FILES_SUCCESSFULLY_PROCESSED[@]}
    do
        FILENAME=$(echo $file | cut -d: -f1)
        LINE_NUMBER_INFO_INSERTED_AT=$(echo $file | cut -d: -f2)
        printf "\nFILE: $FILENAME   LINE: $LINE_NUMBER_INFO_INSERTED_AT"
    done
else
    printf "\n\n${RED}No files were sucessfully processed."
fi

printf "\n\n${DEFAULT}"