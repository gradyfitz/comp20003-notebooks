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
        MIDDLE="^""$line""$"
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

EXPECTED=("Stack 1 created and empty." "Adding 1 to stack 1." "Taking top item from stack 1." "Top item on stack 1 was: 1." "Adding numbers 1 to 7 to stack 1." "Stack 1 not empty after items added." "Stack 2 created and empty." "Taking items from stack 1 and adding them to stack 2." "Stack 1: 7, 6, 5, 4, 3, 2, 1" "Stack 1 emptied." "Taking items from stack 2 and printing them." "Stack 2: 1, 2, 3, 4, 5, 6, 7" "Stack 2 emptied.")

runGroupTest "$EXPECTED" "p_4.1_r_1.res"

echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"