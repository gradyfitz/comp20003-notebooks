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

EXPECTED=("Step 3 - strings\[0\] = Short string" "Step 3 - strings\[1\] = Short strin1" "Step 3 - strings\[2\] = Short strin2")

INPUT=""

runGroupTest "" "$EXPECTED" "p_2_r_3.res"



echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"