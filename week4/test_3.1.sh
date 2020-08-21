function echoerr
{
    # Prints the given string to stderr, works, but doesn't look 
    # good if things get jumbled.
    printf "%s\n" "$*" >&2; 
}

function runGroupTest
{
    # This function runs a test for the factorial program.
    # Argument $1 -> The input data to use
    # Argument $3 -> The test file name
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"

    rm -f "results/$3"
    mkdir -p results

    TIMEOUT=0
    timeout $TIMEOUT_LENGTH $PROGRAM_NAME > results/$3 <<< "$1"
    # If the timeout is hit, status 124 is returned.
    if [[ $? == 124 ]]
    then
        TIMEOUT=1
    fi
    
    for line in "${EXPECTED[@]}"
    do
        MIDDLE="^""$line""$"
        grep -E "$MIDDLE" results/$3 > /dev/null

        if [ $? -ne 0 ]
        then
            if [[ $TIMEOUT != 0 ]]
            then
                echo "[Test Script] $TIMEOUT_LENGTH second timeout hit, program ended."
            fi
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input: "
            echo "$1"
            echo "[Test Script] Expected Output Needed Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat results/$3
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

EXPECTED=(" *8 *" " *4 *9 *" " *1 *6 *11 *" " *3 *5 *7 *10 *14 *" " *2 *13 *")

INPUT="8 4 9 11 6 7 1 5 3 14 10 13 2"

runGroupTest "$INPUT" "$EXPECTED" "p_3.4_r_1.res"



echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"