#!/bin/bash

# fal.ai Requests Management Script
# Usage: ./requests.sh --model MODEL [--limit N] | --delete REQUEST_ID
# List and manage API requests

set -e

FAL_API_BASE="https://api.fal.ai/v1"

# Default values
MODEL=""
LIMIT=10
DELETE_ID=""
OUTPUT_JSON=false

# Check for --add-fal-key first
for arg in "$@"; do
    if [ "$arg" = "--add-fal-key" ]; then
        bash "$(dirname "$0")/setup.sh" "$@"
        exit $?
    fi
done

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --model|-m)
            MODEL="$2"
            shift 2
            ;;
        --limit|-l)
            LIMIT="$2"
            shift 2
            ;;
        --delete|-d)
            DELETE_ID="$2"
            shift 2
            ;;
        --json)
            OUTPUT_JSON=true
            shift
            ;;
        --help|-h)
            echo "fal.ai Requests Management Script" >&2
            echo "" >&2
            echo "Usage:" >&2
            echo "  ./requests.sh --model MODEL          List requests for model" >&2
            echo "  ./requests.sh --delete REQUEST_ID    Delete request payloads" >&2
            echo "" >&2
            echo "Options:" >&2
            echo "  --model, -m   Model ID to filter" >&2
            echo "  --limit, -l   Max results (default: 10)" >&2
            echo "  --delete, -d  Request ID to delete payloads" >&2
            echo "  --json        Output raw JSON" >&2
            echo "  --add-fal-key Setup FAL_KEY" >&2
            echo "" >&2
            echo "Examples:" >&2
            echo "  ./requests.sh --model \"fal-ai/flux/dev\" --limit 5" >&2
            echo "  ./requests.sh --delete \"req_abc123\"" >&2
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

# Load .env if exists
if [ -f ".env" ]; then
    source .env 2>/dev/null || true
fi

# Check for FAL_KEY
if [ -z "$FAL_KEY" ]; then
    echo "Error: FAL_KEY required" >&2
    echo "" >&2
    echo "Run: ./setup.sh --add-fal-key" >&2
    exit 1
fi

# Delete request payloads
if [ -n "$DELETE_ID" ]; then
    echo "Deleting payloads for request $DELETE_ID..." >&2

    RESPONSE=$(curl -s -X DELETE "$FAL_API_BASE/models/requests/$DELETE_ID/payloads" \
        -H "Authorization: Key $FAL_KEY" \
        -H "Content-Type: application/json")

    if echo "$RESPONSE" | grep -q '"error"'; then
        ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo "Error: $ERROR_MSG" >&2
        exit 1
    fi

    echo "Payloads deleted successfully" >&2
    echo "$RESPONSE"
    exit 0
fi

# List requests
if [ -z "$MODEL" ]; then
    echo "Error: --model is required for listing requests" >&2
    exit 1
fi

echo "Fetching requests for $MODEL..." >&2

ENCODED_MODEL=$(echo "$MODEL" | sed 's/\//%2F/g')

RESPONSE=$(curl -s -X GET "$FAL_API_BASE/models/requests/by-endpoint?endpoint_id=$ENCODED_MODEL&limit=$LIMIT" \
    -H "Authorization: Key $FAL_KEY" \
    -H "Content-Type: application/json")

# Check for errors
if echo "$RESPONSE" | grep -q '"error"'; then
    ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Error: $ERROR_MSG" >&2
    exit 1
fi

if [ "$OUTPUT_JSON" = true ]; then
    echo "$RESPONSE"
    exit 0
fi

# Parse and display requests
echo "" >&2
if command -v python3 &> /dev/null; then
    python3 << 'PYTHON_EOF' - "$RESPONSE"
import json
import sys

response = json.loads(sys.argv[1])
data = response.get('data', response)

if isinstance(data, list):
    print(f"Recent Requests ({len(data)} shown)", file=sys.stderr)
    print("=" * 40, file=sys.stderr)

    for req in data:
        request_id = req.get('request_id', req.get('id', 'unknown'))
        status = req.get('status', 'unknown')
        created = req.get('created_at', req.get('timestamp', ''))[:19]
        duration = req.get('duration', 0)

        print(f"", file=sys.stderr)
        print(f"  ID: {request_id}", file=sys.stderr)
        print(f"  Status: {status}", file=sys.stderr)
        print(f"  Created: {created}", file=sys.stderr)
        if duration:
            print(f"  Duration: {duration:.2f}s", file=sys.stderr)
else:
    print("No requests found", file=sys.stderr)
PYTHON_EOF
fi

echo "$RESPONSE"
