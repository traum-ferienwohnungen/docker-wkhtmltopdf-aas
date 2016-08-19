#!/usr/bin/env bash

content=$(echo "<html>Hello World</html>" | base64) 
footer=$(echo "<html>Lorem ipsum</html>" | base64) 

curl -vvv -H "Content-Type: application/json" -X POST -d \
    '{"contents":"'"$content"'",
      "token":"travisci-test123456789",
      "footer":"'"$footer"'"}' \
    http://localhost:80 -o test.pdf
