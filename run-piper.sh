#!/usr/bin/env bash
set -euo pipefail

API_KEY="${PIPER_API_KEY:-change_me}"
VOICE="${PIPER_VOICE:-en_US-lessac-medium}"
PORT="${PIPER_PORT:-50000}"
VOICES_DIR="$(pwd)/voices"
IMAGE="piper"
CONTAINER="piper"

mkdir -p "$VOICES_DIR"

echo ">> Building image: $IMAGE"
docker build -t "$IMAGE" .

echo ">> Downloading voice: $VOICE"
docker run --rm -v "$VOICES_DIR:/data" "$IMAGE" download "$VOICE"

echo ">> Starting server on port $PORT (container: $CONTAINER)"
docker rm -f "$CONTAINER" >/dev/null 2>&1 || true
docker run -d \
  --name "$CONTAINER" \
  -p "$PORT:5000" \
  -v "$VOICES_DIR:/data" \
  -e PIPER_API_KEY="$API_KEY" \
  "$IMAGE" server -m "$VOICE"

echo ">> Running. API key: $API_KEY"
echo ">> Logs: docker logs -f $CONTAINER"
