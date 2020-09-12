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

EXPECTED=("Before: 5 6 3 8 1 2 7 4 9" "Swapping index 1, containing 6 and index 7, containing 4" "Swapping index 3, containing 8 and index 5, containing 2" "Swapping index 0, containing 5 and index 4, containing 1" "After: 1 4 3 2 5 8 7 6 9")

runGroupTest "$EXPECTED" "p_6.2_r_1.res"

echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"