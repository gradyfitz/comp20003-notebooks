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

EXPECTED=("a\[0\]\[0\] = 0, b\[0\]\[0\] = 0, c\[0\]\[0\] = 0" "a\[1\]\[1\] = 21, b\[1\]\[1\] = 21, c\[1\]\[1\] = 21" "a\[2\]\[2\] = 42, b\[2\]\[2\] = 42, c\[2\]\[2\] = 42" "a\[3\]\[3\] = 63, b\[3\]\[3\] = 63, c\[3\]\[3\] = 63" "a\[4\]\[4\] = 84, b\[4\]\[4\] = 84, c\[4\]\[4\] = 84" "a\[5\]\[5\] = 105, b\[5\]\[5\] = 105, c\[5\]\[5\] = 105" "a\[6\]\[6\] = 126, b\[6\]\[6\] = 126, c\[6\]\[6\] = 126" "a\[7\]\[7\] = 147, b\[7\]\[7\] = 147, c\[7\]\[7\] = 147" "a\[8\]\[8\] = 168, b\[8\]\[8\] = 168, c\[8\]\[8\] = 168" "a\[9\]\[9\] = 189, b\[9\]\[9\] = 189, c\[9\]\[9\] = 189")

runGroupTest "" "$EXPECTED" "2_r_3_3.res"

echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"