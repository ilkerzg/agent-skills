#!/bin/bash

# fal.ai File Upload Script
# Usage: ./upload.sh --file /path/to/file
# Returns: CDN URL for the uploaded file
#
# Upload flow:
#   1. Get CDN token from rest.alpha.fal.ai
#   2. Upload file to CDN (v3b.fal.media)
#   3. Return access_url

set -e

FAL_TOKEN_ENDPOINT="https://rest.alpha.fal.ai/storage/auth/token?storage_type=fal-cdn-v3"

# Default values
FILE_PATH=""
OUTPUT_JSON=false

# Check for --add-fal-key first
for arg in "$@"; do
    if [ "$arg" = "--add-fal-key" ]; then
        shift
        KEY_VALUE=""
        if [[ -n "$1" && ! "$1" =~ ^-- ]]; then
            KEY_VALUE="$1"
        fi
        if [ -z "$KEY_VALUE" ]; then
            echo "Enter your fal.ai API key:" >&2
            read -r KEY_VALUE
        fi
        if [ -n "$KEY_VALUE" ]; then
            grep -v "^FAL_KEY=" .env > .env.tmp 2>/dev/null || true
            mv .env.tmp .env 2>/dev/null || true
            echo "FAL_KEY=$KEY_VALUE" >> .env
            echo "FAL_KEY saved to .env" >&2
        fi
        exit 0
    fi
done

# Load .env if exists
if [ -f ".env" ]; then
    source .env 2>/dev/null || true
fi

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --file|-f)
            FILE_PATH="$2"
            shift 2
            ;;
        --json)
            OUTPUT_JSON=true
            shift
            ;;
        --help|-h)
            echo "fal.ai File Upload Script" >&2
            echo "" >&2
            echo "Usage:" >&2
            echo "  ./upload.sh --file /path/to/file" >&2
            echo "" >&2
            echo "Options:" >&2
            echo "  --file, -f      Local file path (required)" >&2
            echo "  --json          Output raw JSON response" >&2
            echo "  --add-fal-key   Setup FAL_KEY in .env" >&2
            echo "" >&2
            echo "Supported file types:" >&2
            echo "  Images: jpg, jpeg, png, gif, webp, bmp, tiff" >&2
            echo "  Videos: mp4, mov, avi, webm, mkv" >&2
            echo "  Audio:  mp3, wav, flac, ogg, m4a" >&2
            echo "" >&2
            echo "Examples:" >&2
            echo "  ./upload.sh --file photo.jpg" >&2
            echo "  ./upload.sh --file video.mp4" >&2
            echo "" >&2
            echo "Usage with generate.sh:" >&2
            echo "  URL=\$(./upload.sh --file photo.jpg)" >&2
            echo "  ./generate.sh --image-url \"\$URL\" --prompt \"...\"" >&2
            exit 0
            ;;
        *)
            # If no flag, treat as file path
            if [ -z "$FILE_PATH" ] && [ -f "$1" ]; then
                FILE_PATH="$1"
            fi
            shift
            ;;
    esac
done

# Validate FAL_KEY
if [ -z "$FAL_KEY" ]; then
    echo "Error: FAL_KEY not set" >&2
    echo "" >&2
    echo "Run: ./upload.sh --add-fal-key" >&2
    echo "Or:  export FAL_KEY=your_key_here" >&2
    exit 1
fi

# Validate file
if [ -z "$FILE_PATH" ]; then
    echo "Error: --file is required" >&2
    exit 1
fi

if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File not found: $FILE_PATH" >&2
    exit 1
fi

# Get filename
FILENAME=$(basename "$FILE_PATH")

# Detect content type
EXTENSION="${FILENAME##*.}"
EXTENSION_LOWER=$(echo "$EXTENSION" | tr '[:upper:]' '[:lower:]')

case "$EXTENSION_LOWER" in
    jpg|jpeg) CONTENT_TYPE="image/jpeg" ;;
    png) CONTENT_TYPE="image/png" ;;
    gif) CONTENT_TYPE="image/gif" ;;
    webp) CONTENT_TYPE="image/webp" ;;
    bmp) CONTENT_TYPE="image/bmp" ;;
    tiff|tif) CONTENT_TYPE="image/tiff" ;;
    mp4) CONTENT_TYPE="video/mp4" ;;
    mov) CONTENT_TYPE="video/quicktime" ;;
    avi) CONTENT_TYPE="video/x-msvideo" ;;
    webm) CONTENT_TYPE="video/webm" ;;
    mkv) CONTENT_TYPE="video/x-matroska" ;;
    mp3) CONTENT_TYPE="audio/mpeg" ;;
    wav) CONTENT_TYPE="audio/wav" ;;
    flac) CONTENT_TYPE="audio/flac" ;;
    ogg) CONTENT_TYPE="audio/ogg" ;;
    m4a) CONTENT_TYPE="audio/mp4" ;;
    *) CONTENT_TYPE="application/octet-stream" ;;
esac

# Get file size
FILE_SIZE=$(stat -f%z "$FILE_PATH" 2>/dev/null || stat -c%s "$FILE_PATH" 2>/dev/null)
FILE_SIZE_MB=$((FILE_SIZE / 1024 / 1024))

# Check if file is too large (>100MB needs multipart)
if [ "$FILE_SIZE" -gt 104857600 ]; then
    echo "Error: File too large (${FILE_SIZE_MB}MB > 100MB)" >&2
    echo "Large file multipart upload not yet supported." >&2
    echo "Please use the Python client for files >100MB." >&2
    exit 1
fi

echo "Uploading: $FILENAME (${FILE_SIZE_MB}MB)" >&2

# Step 1: Get CDN token
echo "Getting CDN token..." >&2

TOKEN_RESPONSE=$(curl -s -X POST "$FAL_TOKEN_ENDPOINT" \
    -H "Authorization: Key $FAL_KEY" \
    -H "Content-Type: application/json" \
    -d '{}')

# Check for token error
if echo "$TOKEN_RESPONSE" | grep -q '"detail"'; then
    ERROR_MSG=$(echo "$TOKEN_RESPONSE" | grep -o '"msg":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Token error: $ERROR_MSG" >&2
    exit 1
fi

TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
TOKEN_TYPE=$(echo "$TOKEN_RESPONSE" | grep -o '"token_type":"[^"]*"' | cut -d'"' -f4)
BASE_URL=$(echo "$TOKEN_RESPONSE" | grep -o '"base_url":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ] || [ -z "$BASE_URL" ]; then
    echo "Error: Failed to get CDN token" >&2
    echo "$TOKEN_RESPONSE" >&2
    exit 1
fi

# Step 2: Upload file
echo "Uploading to CDN..." >&2

UPLOAD_RESPONSE=$(curl -s -X POST "${BASE_URL}/files/upload" \
    -H "Authorization: $TOKEN_TYPE $TOKEN" \
    -H "Content-Type: $CONTENT_TYPE" \
    -H "X-Fal-File-Name: $FILENAME" \
    --data-binary "@$FILE_PATH")

# Check for upload error
if echo "$UPLOAD_RESPONSE" | grep -q '"error"'; then
    ERROR_MSG=$(echo "$UPLOAD_RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -z "$ERROR_MSG" ]; then
        ERROR_MSG=$(echo "$UPLOAD_RESPONSE" | grep -o '"error":"[^"]*"' | cut -d'"' -f4)
    fi
    echo "Upload error: $ERROR_MSG" >&2
    exit 1
fi

# Extract URL
ACCESS_URL=$(echo "$UPLOAD_RESPONSE" | grep -o '"access_url":"[^"]*"' | cut -d'"' -f4)

if [ -z "$ACCESS_URL" ]; then
    echo "Error: Failed to get URL from response" >&2
    echo "$UPLOAD_RESPONSE" >&2
    exit 1
fi

echo "Upload complete!" >&2
echo "URL: $ACCESS_URL" >&2

# Output
if [ "$OUTPUT_JSON" = true ]; then
    echo "$UPLOAD_RESPONSE"
else
    # Output just the URL for easy piping
    echo "$ACCESS_URL"
fi
