function echoerr
{
    # Prints the given string to stderr, works, but doesn't look 
    # good if things get jumbled.
    printf "%s\n" "$*" >&2; 
}

function runTest
{
    # This function runs a test for the factorial program.
    # Argument $1 -> The input data to use
    # Argument $2 -> The string to match against
    # Argument $3 -> The test file name
    #
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

    grep -E "^""$2""$" results/$3 > /dev/null

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
        echo "$2"
        echo "[Test Script] Actual Output: "
        cat results/$3
        exit 1
    else
        PASSED_TESTS=$(($PASSED_TESTS + 1))
        echo "[Test Script] Test $PASSED_TESTS Passed"
    fi
}

TOTAL_TESTS=4
# Give 2 seconds for solution to run before killing.
TIMEOUT_LENGTH=2

PROGRAM_NAME=$1

runTest "1" "The factorial of 1 is 1" "debug_1_r_1.res"
runTest "2" "The factorial of 2 is 2" "debug_1_r_2.res"
runTest "3" "The factorial of 3 is 6" "debug_1_r_3.res"
runTest "4" "The factorial of 4 is 24" "debug_1_r_4.res"


echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"