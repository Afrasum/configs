#!/usr/bin/env osascript
# @raycast.schemaVersion 1
# @raycast.title Nytt Safari-vindu
# @raycast.mode silent

tell application "Safari"
  activate
  -- Oppretter et nytt vindu (dokument)
  make new document at end of documents
end tell
