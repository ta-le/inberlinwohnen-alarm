#!/bin/bash

URL="https://inberlinwohnen.de/wohnungsfinder/?JDH43880-nn"
INTERVAL=90

fetch_results() {
    curl -s $URL | pup '#_tb_relevant_results'
}

echo "Starting script"

OLD_HTML=$(fetch_results)

while true; do
    NEW_HTML=$(fetch_results)
    TIMESTAMP=$(echo $(date +%H:%M:%S))

    if [ -z "$NEW_HTML" ]; then
        echo "An error occurred when fetching results, exiting..."
        exit 1
    fi

    if [ "$OLD_HTML" != "$NEW_HTML" ]; then
        echo $TIMESTAMP "Changes detected!"
        DIFF=$(diff <(echo "$OLD_HTML") <(echo "$NEW_HTML") | grep '^>')
        if [ -z "$DIFF" ]; then
            echo "(Only removals)"
        else
            echo "New flat(s)"
            echo $DIFF | cut -c 4- | pup '._tb_left' | sed 's/<[^>]*>//g' | tr -s ' ' | tr -d '\n' | cut -c 2-
            # Play sound
            afplay /System/Library/Sounds/Submarine.aiff
        fi

        OLD_HTML="$NEW_HTML"
    else
        echo $TIMESTAMP "No changes, try again in ${INTERVAL}s"
    fi

    sleep $INTERVAL
done
