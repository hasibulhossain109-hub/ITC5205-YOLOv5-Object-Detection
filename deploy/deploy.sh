#!/bin/bash
set -euo pipefail

REGION="${REGION:-us-east-1}"
REPOSITORY="${REPOSITORY:-yolov5-lambda}"
ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
IMAGE_URI="${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com/${REPOSITORY}:latest"

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CODE_DIR="$PROJECT_ROOT/code"

# Prepare the Docker build context without committing large YOLOv5 files to GitHub.
if [ ! -d "$CODE_DIR/yolov5" ]; then
  git clone --depth 1 https://github.com/ultralytics/yolov5.git "$CODE_DIR/yolov5"
fi

if [ ! -f "$CODE_DIR/yolov5n.pt" ]; then
  curl -L -o "$CODE_DIR/yolov5n.pt" \
    https://github.com/ultralytics/yolov5/releases/download/v7.0/yolov5n.pt
fi

aws ecr get-login-password --region "$REGION" | \
  docker login --username AWS --password-stdin \
  "${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"

docker build -t "$REPOSITORY" "$CODE_DIR"
docker tag "${REPOSITORY}:latest" "$IMAGE_URI"
docker push "$IMAGE_URI"

echo "Image pushed successfully: $IMAGE_URI"
