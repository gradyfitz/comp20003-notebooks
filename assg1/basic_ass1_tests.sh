# This program is intended to test some basic functionality of your program.
# Do not assume that if your program passes these tests that your program is
# correct or that you will get full marks. On the other hand, if you are 
# unable to pass these simple tests, this is likely a hint that your program
# is _not_ correct.
#
# You're completely welcome to use parts of this script to build your own tests
# or ask on the Piazza about these tests. Bash scripting is not part of the 
# assessment for this subject, but you're welcome and encouraged to ask questions
# about using it. You can also freely post bash snippets on the Piazza if you like.
#
# Column names: VendorID, passenger_count, trip_distance, RatecodeID, store_and_fwd_flag, PULocationID, DOLocationID, payment_type, fare_amount, extra, mta_tax, tip_amount, tolls_amount, improvement_surcharge, total_amount, PUdatetime, DOdatetime, trip_duration
# PUdatetime is 15th column
# PUlocationID is the 5th column

function echoerr
{
    # Prints the given string to stderr, works, but doesn't look 
    # good if things get jumbled.
    printf "%s\n" "$*" >&2; 
}

RESULTS_FOLDER="results"
# The filename for the program to output results to.
TEMP_RESULTS_FILE="temp_results"
# The filename to redirect stdout to.
TEMP_COMPARISONS_FILE="temp_comparisons"
# The filename for the input file.
TEMP_INPUT_DATA_FILE="temp_input"
# The filename for the stdin input file.
TEMP_STDIN_INPUT_FILE="temp_stdin"

function buildProgram
{
    # This function clears the currently built program and calls make for it.
    # Remove compiled object files and linked executables.
    rm -f *.o dict1 dict2
    # Try to make dict1
    make dict1
    if [ $? -ne 0 ]
    then
        echoerr "[ERROR] Failed making dict1, please ensure your make rules are correct."
        exit 1
    fi
    # Try to make dict2
    make dict2
    if [ $? -ne 0 ]
    then
        echoerr "[ERROR] Failed making dict2, please ensure the rule is correct."
        echoerr "        Ignore this if you haven't completed stage 2 yet."
    fi
}

function execTest
{
    # Runs the given test.
    # Argument $1 -> The program to run with
    # Argument $2 -> The input to run with
    # Argument $3 -> The stdin data to send to the program
    
    rm -f "$STDOUT_FILE" "$RESULTS_FILE"
    mkdir -p "$RESULTS_FOLDER"
    
    # Write input data to file.
    printf "$2" " " > "$INPUT_DATA_FILE"
    # Write stdin data to file.
    printf "$3" " " > "$STDIN_DATA_FILE"
    TIMEOUT=0
    timeout $TIMEOUT_LENGTH ./$1 "$INPUT_DATA_FILE" "$RESULTS_FILE" > "$STDOUT_FILE" < "$STDIN_DATA_FILE"
    RET_VAL=$?
    # If the timeout is hit, status 124 is returned.
    if [[ $RET_VAL == 124 ]]
    then
        TIMEOUT=1
    fi
    
    if [[ $TIMEOUT != 0 ]]
    then
        echo "[Test Script] $TIMEOUT_LENGTH second timeout hit, program ended."
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] $1 timed out on input: "
        echo "$2"
        exit 1
    fi
    if [[ $RET_VAL != 0 ]]
    then
        echo "[Test Script] Program ended with $RET_VAL return value, if your"
        echo "program worked, it should return 0."
    fi
}

function runTest1
{
    # Runs the first test, minimal data, no spaces, no newline at end of input.
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"
    
    INPUT="2,3,4,5,F,6,7,8,9,1,2,3,4,5,6,2018-01-01,2019-01-01,9"
    STDIN="2018-01-01"
    
    # List of strings which should be present in the results file.
    # ( |^)([^,]*)
    # $1"$2"
    RESULTS_PRESENT=("2018-01-01 -->" "VendorID: 2 ||" "passenger_count: 3 ||" "trip_distance: 4 ||" "RatecodeID: 5 ||" "store_and_fwd_flag: F ||" "PULocationID: 6 ||" "DOLocationID: 7 ||" "payment_type: 8 ||" "fare_amount: 9 ||" "extra: 1 ||" "mta_tax: 2 ||" "tip_amount: 3 ||" "tolls_amount: 4 ||" "improvement_surcharge: 5 ||" "total_amount: 6 ||" "DOdatetime: 2019-01-01 ||" "trip_duration: 9 ||")
    
    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=("2018-01-01 --> VendorID: 2 || passenger_count: 3 || trip_distance: 4 || RatecodeID: 5 || store_and_fwd_flag: F || PULocationID: 6 || DOLocationID: 7 || payment_type: 8 || fare_amount: 9 || extra: 1 || mta_tax: 2 || tip_amount: 3 || tolls_amount: 4 || improvement_surcharge: 5 || total_amount: 6 || DOdatetime: 2019-01-01 || trip_duration: 9 ||")
    
    # Lines which should be present in the stdout file.
    STDOUT_LINES_PRESENT=("2018-01-01 --> 1")
    
    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=1
    
    # Expected lines in stdout file.
    EXPECTED_LINE_COUNT_STDOUT=1
    
    execTest "dict1" "$INPUT" "$STDIN"
    
    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$field"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in results file.
    for line in "${RESULTS_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in stdout file.
    for line in "${STDOUT_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $STDOUT_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Standard Output Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$STDOUT_FILE"
            exit 1
        fi
    done
    
    #check_line_count 
    # Test expected number of lines in results file.
    RF_LINES=$(wc -l "$RESULTS_FILE" | awk -F ' ' '{print $1}')
    RF_LINES=$(tr -d '\n' <<< "$RF_LINES")
    if [ $RF_LINES != $EXPECTED_LINE_COUNT_RESULTS ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Results file contained $RF_LINES line(s) but should "
        echo "have had $EXPECTED_LINE_COUNT_RESULTS line(s)"
        echo "[Test Script] Actual Output: "
        cat "$RESULTS_FILE"
        exit 1
    fi
    
    # Test expected line count in stdout file.
    SO_LINES=$(wc -l "$STDOUT_FILE" | awk -F ' ' '{print $1}')
    SO_LINES=$(tr -d '\n' <<< "$SO_LINES")
    if [ $SO_LINES != $EXPECTED_LINE_COUNT_STDOUT ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Standard output file contained $SO_LINES line(s) "
        echo "but should have had $EXPECTED_LINE_COUNT_STDOUT line(s)"
        echo "[Test Script] Actual Output: "
        cat "$STDOUT_FILE"
        exit 1
    fi
    
    # Increase passed test count.
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

function runTest2
{
    # Runs the first test, minimal data, no spaces, newline at end of input.
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"
    
    INPUT="2,3,4,5,F,6,7,8,9,1,2,3,4,5,6,2018-01-01,2019-01-01,9\n"
    STDIN="2018-01-01\n"
    
    # List of strings which should be present in the results file.
    # ( |^)([^,]*)
    # $1"$2"
    RESULTS_PRESENT=("2018-01-01 -->" "VendorID: 2 ||" "passenger_count: 3 ||" "trip_distance: 4 ||" "RatecodeID: 5 ||" "store_and_fwd_flag: F ||" "PULocationID: 6 ||" "DOLocationID: 7 ||" "payment_type: 8 ||" "fare_amount: 9 ||" "extra: 1 ||" "mta_tax: 2 ||" "tip_amount: 3 ||" "tolls_amount: 4 ||" "improvement_surcharge: 5 ||" "total_amount: 6 ||" "DOdatetime: 2019-01-01 ||" "trip_duration: 9 ||")
    
    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=("2018-01-01 --> VendorID: 2 || passenger_count: 3 || trip_distance: 4 || RatecodeID: 5 || store_and_fwd_flag: F || PULocationID: 6 || DOLocationID: 7 || payment_type: 8 || fare_amount: 9 || extra: 1 || mta_tax: 2 || tip_amount: 3 || tolls_amount: 4 || improvement_surcharge: 5 || total_amount: 6 || DOdatetime: 2019-01-01 || trip_duration: 9 ||")
    
    # Lines which should be present in the stdout file.
    STDOUT_LINES_PRESENT=("2018-01-01 --> 1")
    
    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=1
    
    # Expected lines in stdout file.
    EXPECTED_LINE_COUNT_STDOUT=1
    
    execTest "dict1" "$INPUT" "$STDIN"
    
    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$field"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in results file.
    for line in "${RESULTS_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in stdout file.
    for line in "${STDOUT_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $STDOUT_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Standard Output Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$STDOUT_FILE"
            exit 1
        fi
    done
    
    #check_line_count 
    # Test expected number of lines in results file.
    RF_LINES=$(wc -l "$RESULTS_FILE" | awk -F ' ' '{print $1}')
    RF_LINES=$(tr -d '\n' <<< "$RF_LINES")
    if [ $RF_LINES != $EXPECTED_LINE_COUNT_RESULTS ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Results file contained $RF_LINES line(s) but should "
        echo "have had $EXPECTED_LINE_COUNT_RESULTS line(s)"
        echo "[Test Script] Actual Output: "
        cat "$RESULTS_FILE"
        exit 1
    fi
    
    # Test expected line count in stdout file.
    SO_LINES=$(wc -l "$STDOUT_FILE" | awk -F ' ' '{print $1}')
    SO_LINES=$(tr -d '\n' <<< "$SO_LINES")
    if [ $SO_LINES != $EXPECTED_LINE_COUNT_STDOUT ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Standard output file contained $SO_LINES line(s) "
        echo "but should have had $EXPECTED_LINE_COUNT_STDOUT line(s)"
        echo "[Test Script] Actual Output: "
        cat "$STDOUT_FILE"
        exit 1
    fi
    
    # Increase passed test count.
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

function runTest3
{
    # Runs the first test, full date string, full text, spaces, newline at end of input.
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"
    
    INPUT="2,3,4,5,True,6,7,8,9,1,2,3,4,5,6,2018-01-01 00:31:17,2019-01-01 00:35:47,9\n"
    STDIN="2018-01-01 00:31:17\n"
    
    # List of strings which should be present in the results file.
    # ( |^)([^,]*)
    # $1"$2"
    RESULTS_PRESENT=("2018-01-01 00:31:17 -->" "VendorID: 2 ||" "passenger_count: 3 ||" "trip_distance: 4 ||" "RatecodeID: 5 ||" "store_and_fwd_flag: True ||" "PULocationID: 6 ||" "DOLocationID: 7 ||" "payment_type: 8 ||" "fare_amount: 9 ||" "extra: 1 ||" "mta_tax: 2 ||" "tip_amount: 3 ||" "tolls_amount: 4 ||" "improvement_surcharge: 5 ||" "total_amount: 6 ||" "DOdatetime: 2019-01-01 00:35:47 ||" "trip_duration: 9 ||")
    
    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=("2018-01-01 00:31:17 --> VendorID: 2 || passenger_count: 3 || trip_distance: 4 || RatecodeID: 5 || store_and_fwd_flag: True || PULocationID: 6 || DOLocationID: 7 || payment_type: 8 || fare_amount: 9 || extra: 1 || mta_tax: 2 || tip_amount: 3 || tolls_amount: 4 || improvement_surcharge: 5 || total_amount: 6 || DOdatetime: 2019-01-01 00:35:47 || trip_duration: 9 ||")
    
    # Lines which should be present in the stdout file.
    STDOUT_LINES_PRESENT=("2018-01-01 00:31:17 --> 1")
    
    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=1
    
    # Expected lines in stdout file.
    EXPECTED_LINE_COUNT_STDOUT=1
    
    execTest "dict1" "$INPUT" "$STDIN"
    
    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$field"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in results file.
    for line in "${RESULTS_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in stdout file.
    for line in "${STDOUT_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $STDOUT_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Standard Output Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$STDOUT_FILE"
            exit 1
        fi
    done
    
    #check_line_count 
    # Test expected number of lines in results file.
    RF_LINES=$(wc -l "$RESULTS_FILE" | awk -F ' ' '{print $1}')
    RF_LINES=$(tr -d '\n' <<< "$RF_LINES")
    if [ $RF_LINES != $EXPECTED_LINE_COUNT_RESULTS ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Results file contained $RF_LINES line(s) but should "
        echo "have had $EXPECTED_LINE_COUNT_RESULTS line(s)"
        echo "[Test Script] Actual Output: "
        cat "$RESULTS_FILE"
        exit 1
    fi
    
    # Test expected line count in stdout file.
    SO_LINES=$(wc -l "$STDOUT_FILE" | awk -F ' ' '{print $1}')
    SO_LINES=$(tr -d '\n' <<< "$SO_LINES")
    if [ $SO_LINES != $EXPECTED_LINE_COUNT_STDOUT ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Standard output file contained $SO_LINES line(s) "
        echo "but should have had $EXPECTED_LINE_COUNT_STDOUT line(s)"
        echo "[Test Script] Actual Output: "
        cat "$STDOUT_FILE"
        exit 1
    fi
    
    # Increase passed test count.
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

function runTest4
{
    # Runs the first test, full date string, full text, spaces, newline at end of input, duplicate entry.
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"
    
    INPUT="2,3,4,5,True,6,7,8,9,1,2,3,4,5,6,2018-01-01 00:31:17,2019-01-01 00:35:47,9\n3,4,5,6,True,7,8,9,1,2,3,4,5,6,7,2018-01-01 00:31:17,2019-01-01 00:35:48,8\n"
    STDIN="2018-01-01 00:31:17\n"
    
    # List of strings which should be present in the results file.
    # ( |^)([^,]*)
    # $1"$2"
    RESULTS_PRESENT=("2018-01-01 00:31:17 -->" "VendorID: 2 ||" "passenger_count: 3 ||" "trip_distance: 4 ||" "RatecodeID: 5 ||" "store_and_fwd_flag: True ||" "PULocationID: 6 ||" "DOLocationID: 7 ||" "payment_type: 8 ||" "fare_amount: 9 ||" "extra: 1 ||" "mta_tax: 2 ||" "tip_amount: 3 ||" "tolls_amount: 4 ||" "improvement_surcharge: 5 ||" "total_amount: 6 ||" "DOdatetime: 2019-01-01 00:35:47 ||" "trip_duration: 9 ||" "2018-01-01 00:31:17 -->" "VendorID: 3 ||" "passenger_count: 4 ||" "trip_distance: 5 ||" "RatecodeID: 6 ||" "store_and_fwd_flag: True ||" "PULocationID: 7 ||" "DOLocationID: 8 ||" "payment_type: 9 ||" "fare_amount: 1 ||" "extra: 2 ||" "mta_tax: 3 ||" "tip_amount: 4 ||" "tolls_amount: 5 ||" "improvement_surcharge: 6 ||" "total_amount: 7 ||" "DOdatetime: 2019-01-01 00:35:48 ||" "trip_duration: 8 ||")
    
    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=("2018-01-01 00:31:17 --> VendorID: 2 || passenger_count: 3 || trip_distance: 4 || RatecodeID: 5 || store_and_fwd_flag: True || PULocationID: 6 || DOLocationID: 7 || payment_type: 8 || fare_amount: 9 || extra: 1 || mta_tax: 2 || tip_amount: 3 || tolls_amount: 4 || improvement_surcharge: 5 || total_amount: 6 || DOdatetime: 2019-01-01 00:35:47 || trip_duration: 9 ||" "2018-01-01 00:31:17 --> VendorID: 3 || passenger_count: 4 || trip_distance: 5 || RatecodeID: 6 || store_and_fwd_flag: True || PULocationID: 7 || DOLocationID: 8 || payment_type: 9 || fare_amount: 1 || extra: 2 || mta_tax: 3 || tip_amount: 4 || tolls_amount: 5 || improvement_surcharge: 6 || total_amount: 7 || DOdatetime: 2019-01-01 00:35:48 || trip_duration: 8 ||")
    
    # Lines which should be present in the stdout file.
    STDOUT_LINES_PRESENT=("2018-01-01 00:31:17 --> 1")
    
    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=2
    
    # Expected lines in stdout file.
    EXPECTED_LINE_COUNT_STDOUT=1
    
    execTest "dict1" "$INPUT" "$STDIN"
    
    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$field"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in results file.
    for line in "${RESULTS_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in stdout file.
    for line in "${STDOUT_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $STDOUT_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Standard Output Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$STDOUT_FILE"
            exit 1
        fi
    done
    
    #check_line_count 
    # Test expected number of lines in results file.
    RF_LINES=$(wc -l "$RESULTS_FILE" | awk -F ' ' '{print $1}')
    RF_LINES=$(tr -d '\n' <<< "$RF_LINES")
    if [ $RF_LINES != $EXPECTED_LINE_COUNT_RESULTS ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Results file contained $RF_LINES line(s) but should "
        echo "have had $EXPECTED_LINE_COUNT_RESULTS line(s)"
        echo "[Test Script] Actual Output: "
        cat "$RESULTS_FILE"
        exit 1
    fi
    
    # Test expected line count in stdout file.
    SO_LINES=$(wc -l "$STDOUT_FILE" | awk -F ' ' '{print $1}')
    SO_LINES=$(tr -d '\n' <<< "$SO_LINES")
    if [ $SO_LINES != $EXPECTED_LINE_COUNT_STDOUT ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Standard output file contained $SO_LINES line(s) "
        echo "but should have had $EXPECTED_LINE_COUNT_STDOUT line(s)"
        echo "[Test Script] Actual Output: "
        cat "$STDOUT_FILE"
        exit 1
    fi
    
    # Increase passed test count.
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

function runTest5
{
    # Runs the first test, full date string, full text, spaces, newline at end of input, duplicate entry.
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"
    
    INPUT="0,3,4,5,True,6,7,8,9,1,2,3,4,5,6,2018-01-01 00:31:17,2019-01-01 00:35:47,9\n3,4,5,6,True,7,8,9,1,2,3,4,5,6,7,2018-01-01 00:32:17,2019-01-01 00:35:48,8\n"
    STDIN="2018-01-01 00:32:17\n"
    
    # List of strings which should be present in the results file.
    # ( |^)([^,]*)
    # $1"$2"
    RESULTS_PRESENT=("2018-01-01 00:32:17 -->" "VendorID: 3 ||" "passenger_count: 4 ||" "trip_distance: 5 ||" "RatecodeID: 6 ||" "store_and_fwd_flag: True ||" "PULocationID: 7 ||" "DOLocationID: 8 ||" "payment_type: 9 ||" "fare_amount: 1 ||" "extra: 2 ||" "mta_tax: 3 ||" "tip_amount: 4 ||" "tolls_amount: 5 ||" "improvement_surcharge: 6 ||" "total_amount: 7 ||" "DOdatetime: 2019-01-01 00:35:48 ||" "trip_duration: 8 ||")
    
    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=("2018-01-01 00:32:17 --> VendorID: 3 || passenger_count: 4 || trip_distance: 5 || RatecodeID: 6 || store_and_fwd_flag: True || PULocationID: 7 || DOLocationID: 8 || payment_type: 9 || fare_amount: 1 || extra: 2 || mta_tax: 3 || tip_amount: 4 || tolls_amount: 5 || improvement_surcharge: 6 || total_amount: 7 || DOdatetime: 2019-01-01 00:35:48 || trip_duration: 8 ||")
    
    # Lines which should be present in the stdout file.
    STDOUT_LINES_PRESENT=("2018-01-01 00:32:17 --> 2")
    
    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=1
    
    # Expected lines in stdout file.
    EXPECTED_LINE_COUNT_STDOUT=1
    
    execTest "dict1" "$INPUT" "$STDIN"
    
    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$field"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in results file.
    for line in "${RESULTS_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in stdout file.
    for line in "${STDOUT_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $STDOUT_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Standard Output Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$STDOUT_FILE"
            exit 1
        fi
    done
    
    #check_line_count 
    # Test expected number of lines in results file.
    RF_LINES=$(wc -l "$RESULTS_FILE" | awk -F ' ' '{print $1}')
    RF_LINES=$(tr -d '\n' <<< "$RF_LINES")
    if [ $RF_LINES != $EXPECTED_LINE_COUNT_RESULTS ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Results file contained $RF_LINES line(s) but should "
        echo "have had $EXPECTED_LINE_COUNT_RESULTS line(s)"
        echo "[Test Script] Actual Output: "
        cat "$RESULTS_FILE"
        exit 1
    fi
    
    # Test expected line count in stdout file.
    SO_LINES=$(wc -l "$STDOUT_FILE" | awk -F ' ' '{print $1}')
    SO_LINES=$(tr -d '\n' <<< "$SO_LINES")
    if [ $SO_LINES != $EXPECTED_LINE_COUNT_STDOUT ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Standard output file contained $SO_LINES line(s) "
        echo "but should have had $EXPECTED_LINE_COUNT_STDOUT line(s)"
        echo "[Test Script] Actual Output: "
        cat "$STDOUT_FILE"
        exit 1
    fi
    
    # Increase passed test count.
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

function runTest6
{
    # Runs the sixth test, minimal data, no spaces, no newline at end of input.
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"
    
    INPUT="2,3,4,5,F,6,7,8,9,1,2,3,4,5,6,2018-01-01,2019-01-01,9"
    STDIN="6"
    
    # List of strings which should be present in the results file.
    RESULTS_PRESENT=("6 -->" "2018-01-01")
    
    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=("6 --> 2018-01-01")
    
    # Lines which should be present in the stdout file.
    STDOUT_LINES_PRESENT=("6 --> 1")
    
    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=1
    
    # Expected lines in stdout file.
    EXPECTED_LINE_COUNT_STDOUT=1
    
    execTest "dict2" "$INPUT" "$STDIN"
    
    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$field"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in results file.
    for line in "${RESULTS_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in stdout file.
    for line in "${STDOUT_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $STDOUT_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Standard Output Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$STDOUT_FILE"
            exit 1
        fi
    done
    
    # Test expected number of lines in results file.
    RF_LINES=$(wc -l "$RESULTS_FILE" | awk -F ' ' '{print $1}')
    RF_LINES=$(tr -d '\n' <<< "$RF_LINES")
    if [ $RF_LINES != $EXPECTED_LINE_COUNT_RESULTS ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Results file contained $RF_LINES line(s) but should "
        echo "have had $EXPECTED_LINE_COUNT_RESULTS line(s)"
        echo "[Test Script] Actual Output: "
        cat "$RESULTS_FILE"
        exit 1
    fi
    
    # Test expected line count in stdout file.
    SO_LINES=$(wc -l "$STDOUT_FILE" | awk -F ' ' '{print $1}')
    SO_LINES=$(tr -d '\n' <<< "$SO_LINES")
    if [ $SO_LINES != $EXPECTED_LINE_COUNT_STDOUT ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Standard output file contained $SO_LINES line(s) "
        echo "but should have had $EXPECTED_LINE_COUNT_STDOUT line(s)"
        echo "[Test Script] Actual Output: "
        cat "$STDOUT_FILE"
        exit 1
    fi
    
    # Increase passed test count.
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

function runTest7
{
    # Runs the first test, minimal data, no spaces, newline at end of input.
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"
    
    INPUT="2,3,4,5,F,6,7,8,9,1,2,3,4,5,6,2018-01-01,2019-01-01,9\n"
    STDIN="6\n"
    
    # List of strings which should be present in the results file.
    RESULTS_PRESENT=("6 -->" "2018-01-01")
    
    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=("6 --> 2018-01-01")
    
    # Lines which should be present in the stdout file.
    STDOUT_LINES_PRESENT=("6 --> 1")
    
    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=1
    
    # Expected lines in stdout file.
    EXPECTED_LINE_COUNT_STDOUT=1
    
    execTest "dict2" "$INPUT" "$STDIN"
    
    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$field"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in results file.
    for line in "${RESULTS_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in stdout file.
    for line in "${STDOUT_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $STDOUT_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Standard Output Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$STDOUT_FILE"
            exit 1
        fi
    done
    
    #check_line_count 
    # Test expected number of lines in results file.
    RF_LINES=$(wc -l "$RESULTS_FILE" | awk -F ' ' '{print $1}')
    RF_LINES=$(tr -d '\n' <<< "$RF_LINES")
    if [ $RF_LINES != $EXPECTED_LINE_COUNT_RESULTS ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Results file contained $RF_LINES line(s) but should "
        echo "have had $EXPECTED_LINE_COUNT_RESULTS line(s)"
        echo "[Test Script] Actual Output: "
        cat "$RESULTS_FILE"
        exit 1
    fi
    
    # Test expected line count in stdout file.
    SO_LINES=$(wc -l "$STDOUT_FILE" | awk -F ' ' '{print $1}')
    SO_LINES=$(tr -d '\n' <<< "$SO_LINES")
    if [ $SO_LINES != $EXPECTED_LINE_COUNT_STDOUT ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Standard output file contained $SO_LINES line(s) "
        echo "but should have had $EXPECTED_LINE_COUNT_STDOUT line(s)"
        echo "[Test Script] Actual Output: "
        cat "$STDOUT_FILE"
        exit 1
    fi
    
    # Increase passed test count.
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

function runTest8
{
    # Runs the first test, full date string, full text, spaces, newline at end of input.
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"
    
    INPUT="2,3,4,5,True,6,7,8,9,1,2,3,4,5,6,2018-01-01 00:31:17,2019-01-01 00:35:47,9\n"
    STDIN="6\n"
    
    # List of strings which should be present in the results file.
    RESULTS_PRESENT=("6 -->" "2018-01-01 00:31:17")
    
    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=("6 --> 2018-01-01 00:31:17")
    
    # Lines which should be present in the stdout file.
    STDOUT_LINES_PRESENT=("6 --> 1")
    
    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=1
    
    # Expected lines in stdout file.
    EXPECTED_LINE_COUNT_STDOUT=1
    
    execTest "dict2" "$INPUT" "$STDIN"
    
    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$field"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in results file.
    for line in "${RESULTS_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in stdout file.
    for line in "${STDOUT_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $STDOUT_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Standard Output Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$STDOUT_FILE"
            exit 1
        fi
    done
    
    #check_line_count 
    # Test expected number of lines in results file.
    RF_LINES=$(wc -l "$RESULTS_FILE" | awk -F ' ' '{print $1}')
    RF_LINES=$(tr -d '\n' <<< "$RF_LINES")
    if [ $RF_LINES != $EXPECTED_LINE_COUNT_RESULTS ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Results file contained $RF_LINES line(s) but should "
        echo "have had $EXPECTED_LINE_COUNT_RESULTS line(s)"
        echo "[Test Script] Actual Output: "
        cat "$RESULTS_FILE"
        exit 1
    fi
    
    # Test expected line count in stdout file.
    SO_LINES=$(wc -l "$STDOUT_FILE" | awk -F ' ' '{print $1}')
    SO_LINES=$(tr -d '\n' <<< "$SO_LINES")
    if [ $SO_LINES != $EXPECTED_LINE_COUNT_STDOUT ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Standard output file contained $SO_LINES line(s) "
        echo "but should have had $EXPECTED_LINE_COUNT_STDOUT line(s)"
        echo "[Test Script] Actual Output: "
        cat "$STDOUT_FILE"
        exit 1
    fi
    
    # Increase passed test count.
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

function runTest9
{
    # Runs the first test, full date string, full text, spaces, newline at end of input, duplicate entry.
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"
    
    INPUT="2,3,4,5,True,6,7,8,9,1,2,3,4,5,6,2018-01-01 00:31:17,2019-01-01 00:35:47,9\n3,4,5,7,True,6,8,9,1,2,3,4,5,6,7,2018-01-02 00:31:17,2019-01-01 00:35:48,8\n"
    STDIN="6\n"
    
    # List of strings which should be present in the results file.
    RESULTS_PRESENT=("6 -->" "2018-01-01 00:31:17" "6 -->" "2018-01-02 00:31:17")
    
    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=("6 --> 2018-01-01 00:31:17" "6 --> 2018-01-02 00:31:17")
    
    # Lines which should be present in the stdout file.
    STDOUT_LINES_PRESENT=("6 --> 2")
    
    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=2
    
    # Expected lines in stdout file.
    EXPECTED_LINE_COUNT_STDOUT=1
    
    execTest "dict2" "$INPUT" "$STDIN"
    
    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$field"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in results file.
    for line in "${RESULTS_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in stdout file.
    for line in "${STDOUT_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $STDOUT_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Standard Output Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$STDOUT_FILE"
            exit 1
        fi
    done
    
    #check_line_count 
    # Test expected number of lines in results file.
    RF_LINES=$(wc -l "$RESULTS_FILE" | awk -F ' ' '{print $1}')
    RF_LINES=$(tr -d '\n' <<< "$RF_LINES")
    if [ $RF_LINES != $EXPECTED_LINE_COUNT_RESULTS ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Results file contained $RF_LINES line(s) but should "
        echo "have had $EXPECTED_LINE_COUNT_RESULTS line(s)"
        echo "[Test Script] Actual Output: "
        cat "$RESULTS_FILE"
        exit 1
    fi
    
    # Test expected line count in stdout file.
    SO_LINES=$(wc -l "$STDOUT_FILE" | awk -F ' ' '{print $1}')
    SO_LINES=$(tr -d '\n' <<< "$SO_LINES")
    if [ $SO_LINES != $EXPECTED_LINE_COUNT_STDOUT ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Standard output file contained $SO_LINES line(s) "
        echo "but should have had $EXPECTED_LINE_COUNT_STDOUT line(s)"
        echo "[Test Script] Actual Output: "
        cat "$STDOUT_FILE"
        exit 1
    fi
    
    # Increase passed test count.
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

function runTest10
{
    # Runs the first test, full date string, full text, spaces, newline at end of input, duplicate entry.
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"
    
    INPUT="0,3,4,5,True,6,7,8,9,1,2,3,4,5,6,2018-01-01 00:31:17,2019-01-01 00:35:47,9\n3,4,5,6,True,7,8,9,1,2,3,4,5,6,7,2018-01-01 00:32:17,2019-01-01 00:35:48,8\n"
    STDIN="7\n"
    
    # List of strings which should be present in the results file.
    RESULTS_PRESENT=("7 -->" "2018-01-01 00:32:17")
    
    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=("7 --> 2018-01-01 00:32:17")
    
    # Lines which should be present in the stdout file.
    STDOUT_LINES_PRESENT=("7 --> 2")
    
    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=1
    
    # Expected lines in stdout file.
    EXPECTED_LINE_COUNT_STDOUT=1
    
    execTest "dict2" "$INPUT" "$STDIN"
    
    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$field"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in results file.
    for line in "${RESULTS_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
            exit 1
        fi
    done
    
    # Test all lines are present as expected in stdout file.
    for line in "${STDOUT_LINES_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$line")
        MIDDLE="$REGEX_LINE"
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $STDOUT_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Standard Output Line: "
            echo "$line"
            echo "[Test Script] Actual Output: "
            cat "$STDOUT_FILE"
            exit 1
        fi
    done
    
    #check_line_count 
    # Test expected number of lines in results file.
    RF_LINES=$(wc -l "$RESULTS_FILE" | awk -F ' ' '{print $1}')
    RF_LINES=$(tr -d '\n' <<< "$RF_LINES")
    if [ $RF_LINES != $EXPECTED_LINE_COUNT_RESULTS ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Results file contained $RF_LINES line(s) but should "
        echo "have had $EXPECTED_LINE_COUNT_RESULTS line(s)"
        echo "[Test Script] Actual Output: "
        cat "$RESULTS_FILE"
        exit 1
    fi
    
    # Test expected line count in stdout file.
    SO_LINES=$(wc -l "$STDOUT_FILE" | awk -F ' ' '{print $1}')
    SO_LINES=$(tr -d '\n' <<< "$SO_LINES")
    if [ $SO_LINES != $EXPECTED_LINE_COUNT_STDOUT ]
    then
        echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
        echo "[Test Script] Standard output file contained $SO_LINES line(s) "
        echo "but should have had $EXPECTED_LINE_COUNT_STDOUT line(s)"
        echo "[Test Script] Actual Output: "
        cat "$STDOUT_FILE"
        exit 1
    fi
    
    # Increase passed test count.
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

# Declare this here so we have access to it globally.
TIMEOUT=0

RESULTS_FILE="$RESULTS_FOLDER/$TEMP_RESULTS_FILE"
STDOUT_FILE="$RESULTS_FOLDER/$TEMP_COMPARISONS_FILE"
INPUT_DATA_FILE="$RESULTS_FOLDER/$TEMP_INPUT_DATA_FILE"
STDIN_DATA_FILE="$RESULTS_FOLDER/$TEMP_STDIN_INPUT_FILE"

PASSED_TESTS=0
TOTAL_TESTS=10
# Give 2 seconds for solution to run before killing.
TIMEOUT_LENGTH=2

buildProgram
runTest1
runTest2
runTest3
runTest4
runTest5
runTest6
runTest7
runTest8
runTest9
runTest10

echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"
