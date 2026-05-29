#!/bin/bash

URL="http://3.37.40.205"
FILE="/home/ubuntu/chkNginx/IsNGINXLive/t5.md"
TIMESTAMP=$(TZ='Asia/Seoul' date '+%Y-%m-%d %H:%M:%S')

# curl 실행: 본문을 받으면서 HTTP 코드도 함께 확인
BODY=$(curl -s -w "\n%{http_code}" --max-time 10 "$URL")
CURL_EXIT=$?

# 마지막 줄 = HTTP 코드, 나머지 = 본문 분리
HTTP_CODE=$(echo "$BODY" | tail -n1)
HTML=$(echo "$BODY" | sed '$d')

if [ "$CURL_EXIT" -ne 0 ]; then
    # 접속 자체 실패 (서버 다운, 타임아웃, DNS 오류 등)
    case "$CURL_EXIT" in
        6)  REASON="DNS 조회 실패 (호스트를 찾을 수 없음)" ;;
        7)  REASON="접속 실패 (서버 다운 또는 포트 거부)" ;;
        28) REASON="타임아웃 (10초 내 응답 없음)" ;;
        *)  REASON="curl 오류 (exit code: $CURL_EXIT)" ;;
    esac
    echo "$TIMESTAMP - [ERROR] $URL - 접속 불가: $REASON" >> "$FILE"

elif [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 400 ]; then
    # 정상 응답 → h1 태그 추출
    H1=$(echo "$HTML" | grep -oP '<h1[^>]*>\K.*?(?=</h1>)' | head -n1)

    if [ -z "$H1" ]; then
        # h1 태그가 없음
        echo "$TIMESTAMP - [ERROR] $URL - h1 태그 없음 (HTTP $HTTP_CODE)" >> "$FILE"
    elif echo "$H1" | grep -q "NginX"; then
        # h1 안에 NginX 문자열 존재 → 정상
        echo "$TIMESTAMP - [OK] $URL/index.html - h1 내용: $H1 (HTTP $HTTP_CODE)" >> "$FILE"
    else
        # h1은 있으나 NginX 문자열이 없음
        echo "$TIMESTAMP - [ERROR] $URL - h1에 NginX 없음 (h1 내용: $H1) (HTTP $HTTP_CODE)" >> "$FILE"
    fi

elif [ "$HTTP_CODE" -ge 400 ] && [ "$HTTP_CODE" -lt 500 ]; then
    echo "$TIMESTAMP - [ERROR] $URL - 클라이언트 오류 (HTTP $HTTP_CODE)" >> "$FILE"

elif [ "$HTTP_CODE" -ge 500 ]; then
    echo "$TIMESTAMP - [ERROR] $URL - 서버 오류 (HTTP $HTTP_CODE)" >> "$FILE"

else
    echo "$TIMESTAMP - [ERROR] $URL - 알 수 없는 응답 (HTTP $HTTP_CODE)" >> "$FILE"
fi
