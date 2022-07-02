#!/usr/bin/env bash

# Jenkins -> smee.io -> Bitbucket webhook example: bash smee-client.sh "https://smee.io/XXXXXXXXXXXXXXXX" "https://jenkins/bitbucket-hook" "^x-event-key:"

SMEE_URL="$1"
TARGET_URL="$2"
HEADERS_REGEX="$3"

if [ -z "$SMEE_URL" ] || [ -z "$TARGET_URL" ]; then
  echo "Usage: $(basename "$0") SMEE_URL TARGET_URL [HEADERS_REGEX]"
  exit 1
fi

if [ -z "$HEADERS_REGEX" ]; then
  HEADERS_REGEX=".\+"
fi

SMEE_DATA=""

curl -s -N -H "Accept: text/event-stream" "$SMEE_URL" | while read -r LINE; do
  echo "$LINE"
  if [ -n "$LINE" ]; then
    if echo "$LINE" | grep -q '^data:'; then
      SMEE_DATA="$(echo "$LINE" | cut -d":" -f2- | jq --raw-output 'to_entries | map("\(.key): \(.value)") | .[]')"
    fi
  else
    if [ -n "$SMEE_DATA" ]; then
      #echo + \
          curl -s --retry 3 --retry-delay 0 --connect-timeout 10 --max-time 30 "$TARGET_URL" \
              $(echo "$SMEE_DATA" | grep -v "^\(content-type\|body\|query\|timestamp\):" | grep "$HEADERS_REGEX" | xargs -I{} echo "-H '{}'") \
              -H "'$(echo "$SMEE_DATA" | grep "^content-type:")'" \
              -d "'$(echo "$SMEE_DATA" | grep "^body:" |  cut -d":" -f2-)'"
      echo
    fi
  fi
done
