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
TOTAL_TESTS=3
# Give 2 seconds for solution to run before killing.
TIMEOUT_LENGTH=2

PROGRAM_NAME=$1

runTest "this is some example text" "debug_p2.2_r_1.res" "5 4 this 2 is 4 some 7 example 4 text"
runTest "a ab" "debug_p2.2_r_3.res" "2 1 a 2 ab"
runTest "aLgOrItHmS aRe FuN" "debug_p2.2_r_2.res" "3 10 aLgOrItHmS 3 aRe 3 FuN"


echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"