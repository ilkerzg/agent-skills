#!/bin/bash

# fal.ai Model Search Script
# Usage: ./search-models.sh [--query QUERY] [--category CATEGORY] [--limit N]
# Returns: JSON with matching models

set -e

FAL_API_ENDPOINT="https://api.fal.ai/v1/models"

# Default values
QUERY=""
CATEGORY=""
LIMIT=20

# Load .env if exists
if [ -f ".env" ]; then
    source .env 2>/dev/null || true
fi

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

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --query|-q)
            QUERY="$2"
            shift 2
            ;;
        --category|-c)
            CATEGORY="$2"
            shift 2
            ;;
        --limit|-l)
            LIMIT="$2"
            shift 2
            ;;
        --help|-h)
            echo "fal.ai Model Search Script" >&2
            echo "" >&2
            echo "Usage:" >&2
            echo "  ./search-models.sh [options]" >&2
            echo "" >&2
            echo "Options:" >&2
            echo "  --query, -q     Search query (e.g., 'flux', 'video', 'upscale')" >&2
            echo "  --category, -c  Filter by category:" >&2
            echo "                  text-to-image, image-to-image, text-to-video," >&2
            echo "                  image-to-video, text-to-speech, speech-to-text" >&2
            echo "  --limit, -l     Max results (default: 20)" >&2
            echo "  --add-fal-key   Setup FAL_KEY in .env" >&2
            echo "" >&2
            echo "Examples:" >&2
            echo "  ./search-models.sh --query 'flux'" >&2
            echo "  ./search-models.sh --category 'text-to-video'" >&2
            echo "  ./search-models.sh --query 'upscale' --limit 5" >&2
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# Validate FAL_KEY
if [ -z "$FAL_KEY" ]; then
    echo "Error: FAL_KEY not set" >&2
    echo "" >&2
    echo "Run: ./search-models.sh --add-fal-key" >&2
    echo "Or:  export FAL_KEY=your_key_here" >&2
    exit 1
fi

echo "Searching fal.ai models..." >&2

# Build query parameters
PARAMS="limit=$LIMIT"

if [ -n "$QUERY" ]; then
    PARAMS="$PARAMS&q=$(echo "$QUERY" | sed 's/ /%20/g')"
fi

if [ -n "$CATEGORY" ]; then
    PARAMS="$PARAMS&category=$CATEGORY"
fi

# Make API request
AUTH_HEADER=""
if [ -n "$FAL_KEY" ]; then
    AUTH_HEADER="-H \"Authorization: Key $FAL_KEY\""
fi

RESPONSE=$(curl -s -X GET "$FAL_API_ENDPOINT?$PARAMS" \
    -H "Content-Type: application/json" \
    -H "Authorization: Key $FAL_KEY")

# Check for errors
if echo "$RESPONSE" | grep -q '"error"'; then
    ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Error: $ERROR_MSG" >&2
    exit 1
fi

# Count results
COUNT=$(echo "$RESPONSE" | grep -o '"endpoint_id"' | wc -l | tr -d ' ')
echo "Found $COUNT models" >&2
echo "" >&2

# Display summary to stderr
if command -v python3 &> /dev/null; then
    python3 << 'PYTHON_EOF' - "$RESPONSE"
import json
import sys

response = json.loads(sys.argv[1])
models = response.get('data', response) if isinstance(response, dict) else response

if isinstance(models, list):
    for m in models[:10]:
        name = m.get('display_name', m.get('endpoint_id', 'Unknown'))
        endpoint = m.get('endpoint_id', '')
        category = m.get('category', '')
        print(f"  {name}", file=sys.stderr)
        print(f"    ID: {endpoint}", file=sys.stderr)
        if category:
            print(f"    Category: {category}", file=sys.stderr)
        print("", file=sys.stderr)

    if len(models) > 10:
        print(f"  ... and {len(models) - 10} more", file=sys.stderr)
PYTHON_EOF
fi

# Output JSON for programmatic use
echo "$RESPONSE"
