#!/bin/bash
set -euo pipefail

: "${ENDPOINT:?Set ENDPOINT to your API Gateway /prod/detect URL}"
BUCKET="${BUCKET:-itc5205-yolov5-shanto}"
KEY="${KEY:-input/test3.jfif}"

curl -X POST "$ENDPOINT" \
  -H "Content-Type: application/json" \
  -d "{\"bucket\":\"$BUCKET\",\"key\":\"$KEY\"}"
