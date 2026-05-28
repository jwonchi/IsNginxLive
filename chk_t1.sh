#!/bin/bash

URL="http://13.125.248.48"
FILE="/home/ubuntu/chkNginx/IsNGINXLive/t1.md"

# 페이지 접속 확인 (HTTP 응답 코드가 200~399면 정상)
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$URL")

if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 400 ]; then
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$TIMESTAMP - $URL/index.html -  Team 1" >> "$FILE"
fi
