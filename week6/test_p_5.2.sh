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

EXPECTED=("Created Linear Probing hash table of size 13" "| | | | | | | | | | | | | |" "Inserting 14 into Linear Probing hash table" "Hashing 14: 1" "| |14| | | | | | | | | | | |" "Inserting 30 into Linear Probing hash table" "Hashing 30: 4" "| |14| | |30| | | | | | | | |" "Inserting 17 into Linear Probing hash table" "Hashing 17: 4" "| |14| | |30|17| | | | | | | |" "Inserting 55 into Linear Probing hash table" "Hashing 55: 3" "| |14| |55|30|17| | | | | | | |" "Inserting 31 into Linear Probing hash table" "Hashing 31: 5" "| |14| |55|30|17|31| | | | | | |" "Inserting 29 into Linear Probing hash table" "Hashing 29: 3" "| |14| |55|30|17|31|29| | | | | |" "Inserting 16 into Linear Probing hash table" "Hashing 16: 3" "| |14| |55|30|17|31|29|16| | | | |" "Finished inserting items into Linear Probing hash table" "Created Double Hashing table of size 13 using hash2(x) = (key % 5) + 1" "| | | | | | | | | | | | | |" "Inserting 14 into Double Hashing hash table" "Hashing 14: 1" "| |14| | | | | | | | | | | |" "Inserting 30 into Double Hashing hash table" "Hashing 30: 4" "| |14| | |30| | | | | | | | |" "Inserting 17 into Double Hashing hash table" "Hashing 17: 4" "| |14| | |30| | |17| | | | | |" "Inserting 55 into Double Hashing hash table" "Hashing 55: 3" "| |14| |55|30| | |17| | | | | |" "Inserting 31 into Double Hashing hash table" "Hashing 31: 5" "| |14| |55|30|31| |17| | | | | |" "Inserting 29 into Double Hashing hash table" "Hashing 29: 3" "| |14| |55|30|31| |17|29| | | | |" "Inserting 16 into Double Hashing hash table" "Hashing 16: 3" "| |14| |55|30|31| |17|29|16| | | |" "Finished inserting items into Double Hashing hash table")

runGroupTest "$EXPECTED" "p_5.2_r_1.res"

echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"