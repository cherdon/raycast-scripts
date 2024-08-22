#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Job Scrape
# @raycast.mode silent
# @raycast.packageName Arc Browser
#
# Optional parameters:
# @raycast.icon 🧭
#
# Documentation:
# @raycast.description This script sends the current URL to n8n to parse and add job details into chrome
# @raycast.author Cher Don
# @raycast.authorURL https://github.com/cherdon

# Get the URL of the active tab in Arc Browser
URL=$(osascript -e 'tell application "Arc" to get URL of active tab of first window')

# Define the webhook URL and append the Arc URL as a query parameter
WEBHOOK_URL="https://example.com/webhook/kjhaksfjha?parse=$URL"

# Send the URL to the webhook
curl -X GET "$WEBHOOK_URL"

echo "URL sent to webhook"