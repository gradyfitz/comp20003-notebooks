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

TOTAL_TESTS=1
# Give 2 seconds for solution to run before killing.
TIMEOUT_LENGTH=2

PROGRAM_NAME=$1

runTest "A1a5,1 1s1c1r1e1a1m1e1d1 1t1h1e1 1a1m1a1t1e1u1r1 1m1a1g1i1c1i1a1n1 1a1s1 1t1h1e1 1a2r1d1v1a1r1k1 1a1t1e1 1t1h1e1 1a1p2l1e1 1h1e1'1d1 1p1r1e1p1a1r1e1d1.3" "debug_PC_4.1_1.res"

echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"