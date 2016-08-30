#!/usr/bin/env bash

content=$(echo "<html>Hello World</html>" | base64)
footer=$(echo "<html>Lorem ipsum</html>" | base64)

curl -vvv -H "Content-Type: application/json" -X POST -d \
    '{"contents": "'"$content"'",
      "token": "travisci",
      "options": {
        "margin-top": "20",
        "margin-left": "20",
        "margin-right": "20",
        "margin-bottom": "30"
      },
      "footer": "'"$footer"'"}' \
    http://localhost -o -
