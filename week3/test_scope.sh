function echoerr
{
    # Prints the given string to stderr, works, but doesn't look 
    # good if things get jumbled.
    printf "%s\n" "$*" >&2; 
}

function runTest
{
    # This function runs a test for the factorial program.
    # Argument $1 -> The string to match against
    # Argument $2 -> The test file name
    #
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

    grep -E "^""\[""$1""\]""$3""$" results/$2 > /dev/null
    
    if [ $? -ne 0 ]
    then
        if [[ $TIMEOUT != 0 ]]
        then
            echo "[Test Script] $TIMEOUT_LENGTH second timeout hit, program ended."
        fi
        echo "[Test Script] TEST FAILED!"
        echo "[Test Script] Expected Output Needed Line: "
        echo "[$1]$3"
        echo "[Test Script] Actual Output: "
        cat results/$2
        exit 1
    else
        PASSED_TESTS=$(($PASSED_TESTS + 1))
        echo "[Test Script] Test $PASSED_TESTS Passed"
    fi
}

TOTAL_TESTS=1
# Give 2 seconds for solution to run before killing.
TIMEOUT_LENGTH=2

PROGRAM_NAME=$1
ANSWER="main    after "
ANSWER2=" x = 9"
runTest "$ANSWER" "debug_2.1_r_1.res" "$ANSWER2"



echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"