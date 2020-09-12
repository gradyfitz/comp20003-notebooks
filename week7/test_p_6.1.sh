function echoerr
{
    # Prints the given string to stderr, works, but doesn't look 
    # good if things get jumbled.
    printf "%s\n" "$*" >&2; 
}

function runGroupTest
{
    # This function runs a test for the factorial program.
    # Argument $1 -> The expected output
    # Argument $2 -> The test file name
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"

    rm -f "results/$2"
    mkdir -p results

    TIMEOUT=0
    timeout $TIMEOUT_LENGTH $PROGRAM_NAME > results/$2 
    # If the timeout is hit, status 124 is returned.
    if [[ $? == 124 ]]
    then
        TIMEOUT=1
    fi
    
    for line in "${EXPECTED[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        # Replace ( with \( everywhere it occurs in the string.
        #    s  / (  /  \\(  /               g
        # Replace ) with \) everywhere it occurs in the string.
        #    s  / )  /  \\)  /               g
        MIDDLE=$(sed 's/|/\\|/g' <<< "$line" | tr -d '\n' | sed 's/(/\\(/g' | tr -d '\n' | sed 's/)/\\)/g' | tr -d '\n' | sed 's/+/\\+/g' | tr -d '\n')
        MIDDLE="^""$MIDDLE""$"
        grep -E "$MIDDLE" results/$2 > /dev/null

        if [ $? -ne 0 ]
        then
            if [[ $TIMEOUT != 0 ]]
            then
                echo "[Test Script] $TIMEOUT_LENGTH second timeout hit, program ended."
            fi
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Line: "
            echo "$line"
            echo "$MIDDLE"
            echo "[Test Script] Actual Output: "
            cat results/$2
            exit 1
        fi
    done
    
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

TOTAL_TESTS=1
# Give 2 seconds for solution to run before killing.
TIMEOUT_LENGTH=2

PROGRAM_NAME=$1

EXPECTED=("Created hash table of size 13" "| | | | | | | | | | | | | |" "Inserting 2" "Hashing 2: 12" "| | | | | | | | | | | | |2|" "Inserting 3" "Hashing 3: 5" "| | | | | |3| | | | | | |2|" "Inserting 97" "Hashing 97: 10" "| | | | | |3| | | | |97| |2|" "Inserting 23" "Hashing 23: 8" "| | | | | |3| | |23| |97| |2|" "Inserting 15" "Hashing 15: 12" "|15| | | | |3| | |23| |97| |2|" "Inserting 21" "Hashing 21: 9" "|15| | | | |3| | |23|21|97| |2|" "Inserting 4" "Hashing 4: 11" "|15| | | | |3| | |23|21|97|4|2|" "Inserting 23" "Hashing 23: 8" "|15|23| | | |3| | |23|21|97|4|2|" "Inserting 29" "Hashing 29: 5" "|15|23| | | |3|29| |23|21|97|4|2|" "Inserting 37" "Hashing 37: 1" "|15|23|37| | |3|29| |23|21|97|4|2|" "Inserting 5" "Hashing 5: 4" "|15|23|37| |5|3|29| |23|21|97|4|2|" "Inserting 23" "Hashing 23: 8" "|15|23|37|23|5|3|29| |23|21|97|4|2|" "Inserting 28" "Hashing 28: 12" "Hashing 15: 12" "Hashing 23: 8" "Hashing 37: 1" "Hashing 23: 8" "Hashing 5: 4" "Hashing 3: 5" "Hashing 29: 5" "Hashing 23: 8" "Hashing 21: 9" "Hashing 97: 10" "Hashing 4: 11" "Hashing 2: 12" "| |37| | |5|3|29| |23|23|23|21|15|97|4|2|28| | | | | | | | | |" "Inserting 40" "Hashing 40: 6" "| |37| | |5|3|29|40|23|23|23|21|15|97|4|2|28| | | | | | | | | |" "Finished inserting items into table")

runGroupTest "$EXPECTED" "p_6.1_r_1.res"

echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"