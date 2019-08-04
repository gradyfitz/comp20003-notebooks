function echoerr
{
    # Prints the given string to stderr, works, but doesn't look 
    # good if things get jumbled.
    printf "%s\n" "$*" >&2; 
}
function runTest
{
    # This function is a test for the array program
    # Argument $1 -> The string to match against
    # Argument $2 -> The test file name
    # Argument $3 -> The String input
    #
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"

    rm -f "results/$2"
    mkdir -p results
    
    TIMEOUT=0
    timeout $TIMEOUT_LENGTH $PROGRAM_NAME > results/$2 <<<$3
    # If the timeout is hit, status 124 is returned.
    if [[ $? == 124 ]]
    then
        TIMEOUT=1
    fi
    
    grep -E "^""$1""$" results/$2 > /dev/null
    
    if [ $? -ne 0 ]
    then
        if [[ $TIMEOUT != 0 ]]
        then
            echo "[Test Script] $TIMEOUT_LENGTH second timeout hit, program ended."
        fi
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Expected Output Needed Line: "
        echo "$1"
        echo "[Test Script] Actual Output: "
        cat results/$2
        exit 1
    else
        PASSED_TESTS=$(($PASSED_TESTS + 1))
        echo "[Test Script] Test $PASSED_TESTS Passed"
    fi
}
TOTAL_TESTS=2
# Give 2 seconds for solution to run before killing.
TIMEOUT_LENGTH=2

PROGRAM_NAME=$1

runTest "a cab fabcde" "debug_p5_r_1.res" "1a2ba3cab4dabc5eabcd6fabcde7gabcdef"
runTest "abcde abc abcdefgh" "debug_p5_r_2.res" "5abcde4abcd3abc9abcdefghi1a8abcdefgh5abcde"

echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"