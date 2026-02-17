#!/bin/bash

# fal.ai Speech-to-Text Script
# Usage: ./speech-to-text.sh --audio-url URL [--model MODEL] [--language LANG]
# Returns: JSON with transcription

set -e

FAL_API_ENDPOINT="https://fal.run"

# Default values
MODEL="fal-ai/whisper"
AUDIO_URL=""
LANGUAGE=""

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
        --audio-url)
            AUDIO_URL="$2"
            shift 2
            ;;
        --model)
            MODEL="$2"
            shift 2
            ;;
        --language)
            LANGUAGE="$2"
            shift 2
            ;;
        --help|-h)
            echo "fal.ai Speech-to-Text Script" >&2
            echo "" >&2
            echo "Usage:" >&2
            echo "  ./speech-to-text.sh --audio-url URL [options]" >&2
            echo "" >&2
            echo "Options:" >&2
            echo "  --audio-url     Audio URL to transcribe (required)" >&2
            echo "  --model         Model ID (default: fal-ai/whisper)" >&2
            echo "  --language      Language code (auto-detected if omitted)" >&2
            echo "  --add-fal-key   Setup FAL_KEY in .env" >&2
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# Validate required inputs
if [ -z "$FAL_KEY" ]; then
    echo "Error: FAL_KEY not set" >&2
    echo "" >&2
    echo "Run: ./speech-to-text.sh --add-fal-key" >&2
    echo "Or:  export FAL_KEY=your_key_here" >&2
    exit 1
fi

if [ -z "$AUDIO_URL" ]; then
    echo "Error: --audio-url is required" >&2
    exit 1
fi

# Create temp directory
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo "Transcribing audio..." >&2
echo "Model: $MODEL" >&2
echo "" >&2

# Build payload
if [ -n "$LANGUAGE" ]; then
    PAYLOAD=$(cat <<EOF
{
  "audio_url": "$AUDIO_URL",
  "language": "$LANGUAGE"
}
EOF
)
else
    PAYLOAD=$(cat <<EOF
{
  "audio_url": "$AUDIO_URL"
}
EOF
)
fi

# Make API request
RESPONSE=$(curl -s -X POST "$FAL_API_ENDPOINT/$MODEL" \
    -H "Authorization: Key $FAL_KEY" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

# Check for errors
if echo "$RESPONSE" | grep -q '"error"'; then
    ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
    if [ -z "$ERROR_MSG" ]; then
        ERROR_MSG=$(echo "$RESPONSE" | grep -o '"error":"[^"]*"' | cut -d'"' -f4)
    fi
    echo "Error: $ERROR_MSG" >&2
    exit 1
fi

echo "Transcription complete!" >&2
echo "" >&2

# Extract text
TEXT=$(echo "$RESPONSE" | grep -o '"text":"[^"]*"' | head -1 | cut -d'"' -f4)
echo "Text: $TEXT" >&2

# Output JSON for programmatic use
echo "$RESPONSE"
