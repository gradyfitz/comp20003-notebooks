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
    rm -f *.o dict
    # Try to make dict1
    make dict
    if [ $? -ne 0 ]
    then
        echoerr "[ERROR] Failed making dict, please ensure your make rules are correct."
        exit 1
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
    # Runs the first test, correctly inserts and finds key with single item in dictionary
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"

    INPUT='Census year,Block ID,Property ID,Base property ID,CLUE small area,Trading name,Industry (ANZSIC4) code,Industry (ANZSIC4) description,x coordinate,y coordinate,Location\n2018,113,110689,108118,Melbourne (CBD),Amott Quality Meats,4121,"Fresh Meat, Fish and Poultry Retailing",144.95767,-37.80762,"(-37.80762482, 144.9576703)"'
    STDIN="Amott Quality Meats\n"

    # List of strings which should be present in the results file.
    # ( |^)([^,]*)
    # $1"$2"

    RESULTS_PRESENT=("Amott Quality Meats -->" "Census year: 2018 ||" "Block ID: 113 ||" "Property ID: 110689 ||" "Base property ID: 108118 ||" "CLUE small area: Melbourne \(CBD\) ||" "Industry \(ANZSIC4\) code: 4121 ||" "Industry \(ANZSIC4\) description: Fresh Meat, Fish and Poultry Retailing ||" "x coordinate: 144.95767 ||" "y coordinate: -37.80762 ||" "Location: \(-37.80762482, 144.9576703\) ||")

    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=("Amott Quality Meats --> Census year: 2018 || Block ID: 113 || Property ID: 110689 || Base property ID: 108118 || CLUE small area: Melbourne \(CBD\) || Industry \(ANZSIC4\) code: 4121 || Industry \(ANZSIC4\) description: Fresh Meat, Fish and Poultry Retailing || x coordinate: 144.95767 || y coordinate: -37.80762 || Location: \(-37.80762482, 144.9576703\) || ")

    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=1

    execTest "dict" "$INPUT" "$STDIN"

    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        # Replace \( with ( everywhere it occurs in the string for output
        # and likewise \) with ).
        BRACKETREPL=$(sed 's/\\(/(/g' <<< "$field")
        BRACKETREPL=$(sed 's/\\)/)/g' <<< "$BRACKETREPL")
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$BRACKETREPL"
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
        # Replace \( with ( everywhere it occurs in the string for output
        # and likewise \) with ).
        BRACKETREPL=$(sed 's/\\(/(/g' <<< "$line")
        BRACKETREPL=$(sed 's/\\)/)/g' <<< "$BRACKETREPL")
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$BRACKETREPL"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
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

    # Increase passed test count.
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

function runTest2
{
    # Runs the second test, can find all data for ten unique keys inserted in dictionary
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"

    INPUT='Census year,Block ID,Property ID,Base property ID,CLUE small area,Trading name,Industry (ANZSIC4) code,Industry (ANZSIC4) description,x coordinate,y coordinate,Location\n2018,113,110689,108118,Melbourne (CBD),Amott Quality Meats,4121,"Fresh Meat, Fish and Poultry Retailing",144.95767,-37.80762,"(-37.80762482, 144.9576703)"\n2018,113,110689,108118,Melbourne (CBD),QV Meats,4121,"Fresh Meat, Fish and Poultry Retailing",144.95767,-37.80762,"(-37.80762482, 144.9576703)"\n2018,113,110689,108118,Melbourne (CBD),Thanh Hung Butcher,4121,"Fresh Meat, Fish and Poultry Retailing",144.95767,-37.80762,"(-37.80762482, 144.9576703)"\n2018,113,110691,108118,Melbourne (CBD),The French Shop,4129,Other Specialised Food Retailing,144.95767,-37.80762,"(-37.80762482, 144.9576703)"\n2018,113,110691,108118,Melbourne (CBD),The Traditional Pasta Shop,4129,Other Specialised Food Retailing,144.95767,-37.80762,"(-37.80762482, 144.9576703)"\n2018,113,110691,108118,Melbourne (CBD),Polish Deli,4129,Other Specialised Food Retailing,144.95767,-37.80762,"(-37.80762482, 144.9576703)"\n2018,113,110691,108118,Melbourne (CBD),Gewurzhaus Herb & Spice Merchants,4129,Other Specialised Food Retailing,144.95767,-37.80762,"(-37.80762482, 144.9576703)"\n2018,113,110691,108118,Melbourne (CBD),The Land Of Soy & Honey,4129,Other Specialised Food Retailing,144.95767,-37.80762,"(-37.80762482, 144.9576703)"\n2018,113,110691,108118,Melbourne (CBD),Curds & Whey,4129,Other Specialised Food Retailing,144.95767,-37.80762,"(-37.80762482, 144.9576703)"\n2018,113,110691,108118,Melbourne (CBD),The Epicurean,4129,Other Specialised Food Retailing,144.95767,-37.80762,"(-37.80762482, 144.9576703)"\n'
    STDIN="Amott Quality Meats\nQV Meats\nThanh Hung Butcher\nThe French Shop\nThe Traditional Pasta Shop\nPolish Deli\nGewurzhaus Herb & Spice Merchants\nThe Land Of Soy & Honey\nCurds & Whey\nThe Epicurean\n"

    # List of strings which should be present in the results file.
    # ( |^)([^,]*)
    # $1"$2"
    RESULTS_PRESENT=("Amott Quality Meats -->" "Census year: 2018 ||" "Block ID: 113 ||" "Property ID: 110689 ||" "Base property ID: 108118 ||" "CLUE small area: Melbourne \(CBD\) ||" "Industry \(ANZSIC4\) code: 4121 ||" "Industry \(ANZSIC4\) description: Fresh Meat, Fish and Poultry Retailing ||" "x coordinate: 144.95767 ||" "y coordinate: -37.80762 ||" "Location: \(-37.80762482, 144.9576703\) ||" "QV Meats -->" "Census year: 2018 ||" "Block ID: 113 ||" "Property ID: 110689 ||" "Base property ID: 108118 ||" "CLUE small area: Melbourne \(CBD\) ||" "Industry \(ANZSIC4\) code: 4121 ||" "Industry \(ANZSIC4\) description: Fresh Meat, Fish and Poultry Retailing ||" "x coordinate: 144.95767 ||" "y coordinate: -37.80762 ||" "Location: \(-37.80762482, 144.9576703\) ||" "Thanh Hung Butcher -->" "Census year: 2018 ||" "Block ID: 113 ||" "Property ID: 110689 ||" "Base property ID: 108118 ||" "CLUE small area: Melbourne \(CBD\) ||" "Industry \(ANZSIC4\) code: 4121 ||" "Industry \(ANZSIC4\) description: Fresh Meat, Fish and Poultry Retailing ||" "x coordinate: 144.95767 ||" "y coordinate: -37.80762 ||" "Location: \(-37.80762482, 144.9576703\) ||" "The French Shop -->" "Census year: 2018 ||" "Block ID: 113 ||" "Property ID: 110691 ||" "Base property ID: 108118 ||" "CLUE small area: Melbourne \(CBD\) ||" "Industry \(ANZSIC4\) code: 4129 ||" "Industry \(ANZSIC4\) description: Other Specialised Food Retailing ||" "x coordinate: 144.95767 ||" "y coordinate: -37.80762 ||" "Location: \(-37.80762482, 144.9576703\) ||" "The Traditional Pasta Shop -->" "Census year: 2018 ||" "Block ID: 113 ||" "Property ID: 110691 ||" "Base property ID: 108118 ||" "CLUE small area: Melbourne \(CBD\) ||" "Industry \(ANZSIC4\) code: 4129 ||" "Industry \(ANZSIC4\) description: Other Specialised Food Retailing ||" "x coordinate: 144.95767 ||" "y coordinate: -37.80762 ||" "Location: \(-37.80762482, 144.9576703\) ||" "Polish Deli -->" "Census year: 2018 ||" "Block ID: 113 ||" "Property ID: 110691 ||" "Base property ID: 108118 ||" "CLUE small area: Melbourne \(CBD\) ||" "Industry \(ANZSIC4\) code: 4129 ||" "Industry \(ANZSIC4\) description: Other Specialised Food Retailing ||" "x coordinate: 144.95767 ||" "y coordinate: -37.80762 ||" "Location: \(-37.80762482, 144.9576703\) ||" "Gewurzhaus Herb & Spice Merchants -->" "Census year: 2018 ||" "Block ID: 113 ||" "Property ID: 110691 ||" "Base property ID: 108118 ||" "CLUE small area: Melbourne \(CBD\) ||" "Industry \(ANZSIC4\) code: 4129 ||" "Industry \(ANZSIC4\) description: Other Specialised Food Retailing ||" "x coordinate: 144.95767 ||" "y coordinate: -37.80762 ||" "Location: \(-37.80762482, 144.9576703\) ||" "The Land Of Soy & Honey -->" "Census year: 2018 ||" "Block ID: 113 ||" "Property ID: 110691 ||" "Base property ID: 108118 ||" "CLUE small area: Melbourne \(CBD\) ||" "Industry \(ANZSIC4\) code: 4129 ||" "Industry \(ANZSIC4\) description: Other Specialised Food Retailing ||" "x coordinate: 144.95767 ||" "y coordinate: -37.80762 ||" "Location: \(-37.80762482, 144.9576703\) ||" "Curds & Whey -->" "Census year: 2018 ||" "Block ID: 113 ||" "Property ID: 110691 ||" "Base property ID: 108118 ||" "CLUE small area: Melbourne \(CBD\) ||" "Industry \(ANZSIC4\) code: 4129 ||" "Industry \(ANZSIC4\) description: Other Specialised Food Retailing ||" "x coordinate: 144.95767 ||" "y coordinate: -37.80762 ||" "Location: \(-37.80762482, 144.9576703\) ||" "The Epicurean -->" "Census year: 2018 ||" "Block ID: 113 ||" "Property ID: 110691 ||" "Base property ID: 108118 ||" "CLUE small area: Melbourne \(CBD\) ||" "Industry \(ANZSIC4\) code: 4129 ||" "Industry \(ANZSIC4\) description: Other Specialised Food Retailing ||" "x coordinate: 144.95767 ||" "y coordinate: -37.80762 ||" "Location: \(-37.80762482, 144.9576703\) ||" )

    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=("Amott Quality Meats --> Census year: 2018 || Block ID: 113 || Property ID: 110689 || Base property ID: 108118 || CLUE small area: Melbourne \(CBD\) || Industry \(ANZSIC4\) code: 4121 || Industry \(ANZSIC4\) description: Fresh Meat, Fish and Poultry Retailing || x coordinate: 144.95767 || y coordinate: -37.80762 || Location: \(-37.80762482, 144.9576703\) || " "QV Meats --> Census year: 2018 || Block ID: 113 || Property ID: 110689 || Base property ID: 108118 || CLUE small area: Melbourne \(CBD\) || Industry \(ANZSIC4\) code: 4121 || Industry \(ANZSIC4\) description: Fresh Meat, Fish and Poultry Retailing || x coordinate: 144.95767 || y coordinate: -37.80762 || Location: \(-37.80762482, 144.9576703\) || " "Thanh Hung Butcher --> Census year: 2018 || Block ID: 113 || Property ID: 110689 || Base property ID: 108118 || CLUE small area: Melbourne \(CBD\) || Industry \(ANZSIC4\) code: 4121 || Industry \(ANZSIC4\) description: Fresh Meat, Fish and Poultry Retailing || x coordinate: 144.95767 || y coordinate: -37.80762 || Location: \(-37.80762482, 144.9576703\) || " "The French Shop --> Census year: 2018 || Block ID: 113 || Property ID: 110691 || Base property ID: 108118 || CLUE small area: Melbourne \(CBD\) || Industry \(ANZSIC4\) code: 4129 || Industry \(ANZSIC4\) description: Other Specialised Food Retailing || x coordinate: 144.95767 || y coordinate: -37.80762 || Location: \(-37.80762482, 144.9576703\) || " "The Traditional Pasta Shop --> Census year: 2018 || Block ID: 113 || Property ID: 110691 || Base property ID: 108118 || CLUE small area: Melbourne \(CBD\) || Industry \(ANZSIC4\) code: 4129 || Industry \(ANZSIC4\) description: Other Specialised Food Retailing || x coordinate: 144.95767 || y coordinate: -37.80762 || Location: \(-37.80762482, 144.9576703\) || " "Polish Deli --> Census year: 2018 || Block ID: 113 || Property ID: 110691 || Base property ID: 108118 || CLUE small area: Melbourne \(CBD\) || Industry \(ANZSIC4\) code: 4129 || Industry \(ANZSIC4\) description: Other Specialised Food Retailing || x coordinate: 144.95767 || y coordinate: -37.80762 || Location: \(-37.80762482, 144.9576703\) || " "Gewurzhaus Herb & Spice Merchants --> Census year: 2018 || Block ID: 113 || Property ID: 110691 || Base property ID: 108118 || CLUE small area: Melbourne \(CBD\) || Industry \(ANZSIC4\) code: 4129 || Industry \(ANZSIC4\) description: Other Specialised Food Retailing || x coordinate: 144.95767 || y coordinate: -37.80762 || Location: \(-37.80762482, 144.9576703\) || " "The Land Of Soy & Honey --> Census year: 2018 || Block ID: 113 || Property ID: 110691 || Base property ID: 108118 || CLUE small area: Melbourne \(CBD\) || Industry \(ANZSIC4\) code: 4129 || Industry \(ANZSIC4\) description: Other Specialised Food Retailing || x coordinate: 144.95767 || y coordinate: -37.80762 || Location: \(-37.80762482, 144.9576703\) || " "Curds & Whey --> Census year: 2018 || Block ID: 113 || Property ID: 110691 || Base property ID: 108118 || CLUE small area: Melbourne \(CBD\) || Industry \(ANZSIC4\) code: 4129 || Industry \(ANZSIC4\) description: Other Specialised Food Retailing || x coordinate: 144.95767 || y coordinate: -37.80762 || Location: \(-37.80762482, 144.9576703\) || " "The Epicurean --> Census year: 2018 || Block ID: 113 || Property ID: 110691 || Base property ID: 108118 || CLUE small area: Melbourne \(CBD\) || Industry \(ANZSIC4\) code: 4129 || Industry \(ANZSIC4\) description: Other Specialised Food Retailing || x coordinate: 144.95767 || y coordinate: -37.80762 || Location: \(-37.80762482, 144.9576703\) || " )

    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=10


    execTest "dict" "$INPUT" "$STDIN"

    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        # Replace \( with ( everywhere it occurs in the string for output
        # and likewise \) with ).
        BRACKETREPL=$(sed 's/\\(/(/g' <<< "$field")
        BRACKETREPL=$(sed 's/\\)/)/g' <<< "$BRACKETREPL")
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$BRACKETREPL"
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
        # Replace \( with ( everywhere it occurs in the string for output
        # and likewise \) with ).
        BRACKETREPL=$(sed 's/\\(/(/g' <<< "$line")
        BRACKETREPL=$(sed 's/\\)/)/g' <<< "$BRACKETREPL")
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$BRACKETREPL"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
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

    # Increase passed test count.
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

function runTest3
{
    # Runs the third test, Finds all duplicates for duplicate keys
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"

    INPUT='Census year,Block ID,Property ID,Base property ID,CLUE small area,Trading name,Industry (ANZSIC4) code,Industry (ANZSIC4) description,x coordinate,y coordinate,Location\n2018,44,105956,105956,Melbourne (CBD),In A Rush Espresso,4511,Cafes and Restaurants,144.96174,-37.81561,"(-37.81560561, 144.9617411)"\n2018,1101,108973,108973,Docklands,In A Rush Espresso,4511,Cafes and Restaurants,144.95223,-37.81761,"(-37.81761044, 144.9522269)"\n'
    STDIN="In A Rush Espresso\n"

    # List of strings which should be present in the results file.
    # ( |^)([^,]*)
    # $1"$2"
    RESULTS_PRESENT=( "In A Rush Espresso -->" "Census year: 2018 ||" "Block ID: 44 ||" "Property ID: 105956 ||" "Base property ID: 105956 ||" "CLUE small area: Melbourne \(CBD\) ||" "Industry \(ANZSIC4\) code: 4511 ||" "Industry \(ANZSIC4\) description: Cafes and Restaurants ||" "x coordinate: 144.96174 ||" "y coordinate: -37.81561 ||" "Location: \(-37.81560561, 144.9617411\) ||" "In A Rush Espresso -->" "Census year: 2018 ||" "Block ID: 1101 ||" "Property ID: 108973 ||" "Base property ID: 108973 ||" "CLUE small area: Docklands ||" "Industry \(ANZSIC4\) code: 4511 ||" "Industry \(ANZSIC4\) description: Cafes and Restaurants ||" "x coordinate: 144.95223 ||" "y coordinate: -37.81761 ||" "Location: \(-37.81761044, 144.9522269\) ||")

    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=("In A Rush Espresso --> Census year: 2018 || Block ID: 44 || Property ID: 105956 || Base property ID: 105956 || CLUE small area: Melbourne \(CBD\) || Industry \(ANZSIC4\) code: 4511 || Industry \(ANZSIC4\) description: Cafes and Restaurants || x coordinate: 144.96174 || y coordinate: -37.81561 || Location: \(-37.81560561, 144.9617411\) || " "In A Rush Espresso --> Census year: 2018 || Block ID: 1101 || Property ID: 108973 || Base property ID: 108973 || CLUE small area: Docklands || Industry \(ANZSIC4\) code: 4511 || Industry \(ANZSIC4\) description: Cafes and Restaurants || x coordinate: 144.95223 || y coordinate: -37.81761 || Location: \(-37.81761044, 144.9522269\) || ")

    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=2

    execTest "dict" "$INPUT" "$STDIN"

    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        # Replace \( with ( everywhere it occurs in the string for output
        # and likewise \) with ).
        BRACKETREPL=$(sed 's/\\(/(/g' <<< "$field")
        BRACKETREPL=$(sed 's/\\)/)/g' <<< "$BRACKETREPL")
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$BRACKETREPL"
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
        # Replace \( with ( everywhere it occurs in the string for output
        # and likewise \) with ).
        BRACKETREPL=$(sed 's/\\(/(/g' <<< "$line")
        BRACKETREPL=$(sed 's/\\)/)/g' <<< "$BRACKETREPL")
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$BRACKETREPL"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
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

    # Increase passed test count.
    PASSED_TESTS=$(($PASSED_TESTS + 1))
    echo "[Test Script] Test $PASSED_TESTS Passed"
}

function runTest4
{
    # Runs the fourth test, handles string containing double quotes
    echo "[Test Script] Running test $(($PASSED_TESTS + 1))"

    INPUT='Census year,Block ID,Property ID,Base property ID,CLUE small area,Trading name,Industry (ANZSIC4) code,Industry (ANZSIC4) description,x coordinate,y coordinate,Location\n2018,84,103210,103210,Melbourne (CBD),"Ithacan Philanthropic Society ""The Ulysses""",9559,Other Interest Group Services n.e.c.,144.96136,-37.81099,"(-37.81098646, 144.9613557)"\n'
    STDIN='Ithacan Philanthropic Society "The Ulysses"\n'

    # List of strings which should be present in the results file.
    # ( |^)([^,]*)
    # $1"$2"
    RESULTS_PRESENT=('Ithacan Philanthropic Society "The Ulysses" -->' 'Census year: 2018 ||' 'Block ID: 84 ||' 'Property ID: 103210 ||' 'Base property ID: 103210 ||' 'CLUE small area: Melbourne \(CBD\) ||' 'Industry \(ANZSIC4\) code: 9559 ||' 'Industry \(ANZSIC4\) description: Other Interest Group Services n\.e\.c\. ||' 'x coordinate: 144.96136 ||' 'y coordinate: -37.81099 ||' 'Location: \(-37.81098646, 144.9613557\) ||')

    # Lines which should be present in the results file.
    RESULTS_LINES_PRESENT=('Ithacan Philanthropic Society "The Ulysses" --> Census year: 2018 || Block ID: 84 || Property ID: 103210 || Base property ID: 103210 || CLUE small area: Melbourne \(CBD\) || Industry \(ANZSIC4\) code: 9559 || Industry \(ANZSIC4\) description: Other Interest Group Services n\.e\.c\. || x coordinate: 144.96136 || y coordinate: -37.81099 || Location: \(-37.81098646, 144.9613557\) || ')

    # Expected lines in results file.
    EXPECTED_LINE_COUNT_RESULTS=1
    
    execTest "dict" "$INPUT" "$STDIN"

    # Test all results are present in results file.
    for field in "${RESULTS_PRESENT[@]}"
    do
        # Replace | with \| everywhere it occurs in the string.
        #    s  / |  /  \\|  /               g
        REGEX_LINE=$(sed 's/|/\\|/g' <<< "$field")
        MIDDLE="$REGEX_LINE"
        # Replace \( with ( everywhere it occurs in the string for output
        # and likewise \) with ).
        BRACKETREPL=$(sed 's/\\(/(/g' <<< "$field")
        BRACKETREPL=$(sed 's/\\)/)/g' <<< "$BRACKETREPL")
        grep -E "$MIDDLE" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Expected Output Needed Field Value: "
            echo "$BRACKETREPL"
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
        # Replace \( with ( everywhere it occurs in the string for output
        # and likewise \) with ).
        BRACKETREPL=$(sed 's/\\(/(/g' <<< "$line")
        BRACKETREPL=$(sed 's/\\)/)/g' <<< "$BRACKETREPL")
        # ^ marks the start of a line, $ marks the end of the line.
        grep -E "^""$MIDDLE""$" $RESULTS_FILE > /dev/null

        if [ $? -ne 0 ]
        then
            echo "[Test Script] Passed Tests $PASSED_TESTS/$TOTAL_TESTS"
            echo "[Test Script] Input was:"
            echo "$INPUT"
            echo "[Test Script] Expected Results File Output Needed Line: "
            echo "$BRACKETREPL"
            echo "[Test Script] Actual Output: "
            cat "$RESULTS_FILE"
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
TOTAL_TESTS=4
# Give 10 seconds for solution to run before killing.
TIMEOUT_LENGTH=10

# Turn off core dumps.
ulimit -c 0

cd submission
buildProgram
runTest1
runTest2
runTest3
runTest4

echo "Passed Tests $PASSED_TESTS/$PASSED_TESTS"
