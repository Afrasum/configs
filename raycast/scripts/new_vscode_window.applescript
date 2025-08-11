#!/usr/bin/osascript
# @raycast.schemaVersion 1
# @raycast.title   Nytt VS Code-vindu
# @raycast.mode    silent
# @raycast.packageName  VS Code

-- Åpner et helt nytt vindu i VS Code
do shell script "open -n -a 'Visual Studio Code' --args --new-window"
