#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Service VMF extract from FIRE repo
# @raycast.mode silent
# @raycast.packageName Arc Browser
#
# Optional parameters:
# @raycast.icon ☁️
#
# Documentation:
# @raycast.description This script gets service and resources vmf of the PR
# @raycast.author Cher Don
# @raycast.authorURL https://github.com/cherdon

# Define the error log file, output HTML file, and snippet JSON files
ERROR_LOG="error_log.txt"
OUTPUT_HTML="output.html"
SCRIPT_FILE=$(mktemp /tmp/arc_script.XXXXXX)

# Variables to store the results of the searches
vmf_out_res=""
vmf_out_serv=""
s3_url=""

# Write the AppleScript to the temporary file
cat <<EOF > $SCRIPT_FILE
tell application "Arc"
    execute front window's active tab javascript "document.documentElement.outerHTML"
end tell
EOF

# Run the AppleScript from the temporary file and capture the output
html_content=$(osascript $SCRIPT_FILE 2>>"$ERROR_LOG")

# Clean up the temporary file
rm $SCRIPT_FILE

# Check if the osascript command was successful
if [ $? -eq 0 ]; then
  # Write the HTML content to a file
  echo "$html_content" > "$OUTPUT_HTML"
  echo "HTML content captured and written to $OUTPUT_HTML"

  # Search for text that begins with 'vmf-out' and ends with 'resources-vmf.yaml', taking only the first match
  vmf_out_res=$(grep -Eo 'vmf-out[^ ]+resources-vmf.yaml' "$OUTPUT_HTML" | head -n 1)

  # Search for text that begins with 'vmf-out' and ends with 'service-vmf.yaml', taking only the first match
  vmf_out_serv=$(grep -Eo 'vmf-out[^ ]+service-vmf.yaml' "$OUTPUT_HTML" | head -n 1)

  # Search for text that looks like an S3 URL but without the last part (e.g., '*.zip'), taking only the first match
  s3_url=$(grep -Eo 's3://[^ ]+/fire-orchestration-vmfs/[0-9]{4}\.[0-9]{2}[a-z]\.[0-9]+/' "$OUTPUT_HTML" | head -n 1 | sed 's/archive/content/')

  # Check that all variables were successfully populated
  if [ -n "$vmf_out_res" ] && [ -n "$vmf_out_serv" ] && [ -n "$s3_url" ]; then
    # Combine the text and copy to clipboard
    combined_text="$s3_url$vmf_out_serv"
    echo "$combined_text" | pbcopy
    echo "Combined text copied to clipboard."

  else
    echo "One or more searches did not return expected results."
  fi

else
  echo "An error occurred. Check $ERROR_LOG for details."
fi

rm $OUTPUT_HTML