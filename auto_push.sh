#!/bin/bash

cd /home/ubuntu/chkNginx || exit 1

git add -A
git diff --cached --quiet || git commit -m "update $(date '+%F %T')"
git push
