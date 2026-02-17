#!/bin/bash

# fal.ai Usage Script
# Usage: ./usage.sh [--model MODEL] [--start DATE] [--end DATE] [--timeframe TF]
# Returns usage information and billing

set -e

FAL_API_BASE="https://api.fal.ai/v1"

# Default values
MODEL=""
START_DATE=""
END_DATE=""
TIMEFRAME=""
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
        --start|-s)
            START_DATE="$2"
            shift 2
            ;;
        --end|-e)
            END_DATE="$2"
            shift 2
            ;;
        --timeframe|-t)
            TIMEFRAME="$2"
            shift 2
            ;;
        --json)
            OUTPUT_JSON=true
            shift
            ;;
        --help|-h)
            echo "fal.ai Usage Script" >&2
            echo "" >&2
            echo "Usage:" >&2
            echo "  ./usage.sh                           Get current usage" >&2
            echo "  ./usage.sh --model MODEL             Filter by model" >&2
            echo "  ./usage.sh --start DATE --end DATE   Date range" >&2
            echo "" >&2
            echo "Options:" >&2
            echo "  --model, -m      Model ID to filter" >&2
            echo "  --start, -s      Start date (ISO8601 or YYYY-MM-DD)" >&2
            echo "  --end, -e        End date" >&2
            echo "  --timeframe, -t  Aggregation: minute, hour, day, week, month" >&2
            echo "  --json           Output raw JSON" >&2
            echo "  --add-fal-key    Setup FAL_KEY" >&2
            echo "" >&2
            echo "Examples:" >&2
            echo "  ./usage.sh" >&2
            echo "  ./usage.sh --model \"fal-ai/flux/dev\"" >&2
            echo "  ./usage.sh --start \"2024-01-01\" --end \"2024-01-31\"" >&2
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

echo "Fetching usage information..." >&2

# Build query parameters
PARAMS="expand=time_series,summary"

if [ -n "$MODEL" ]; then
    ENCODED_MODEL=$(echo "$MODEL" | sed 's/\//%2F/g')
    PARAMS="$PARAMS&endpoint_id=$ENCODED_MODEL"
fi

if [ -n "$START_DATE" ]; then
    PARAMS="$PARAMS&start=$START_DATE"
fi

if [ -n "$END_DATE" ]; then
    PARAMS="$PARAMS&end=$END_DATE"
fi

if [ -n "$TIMEFRAME" ]; then
    PARAMS="$PARAMS&timeframe=$TIMEFRAME"
fi

# Make API request
RESPONSE=$(curl -s -X GET "$FAL_API_BASE/models/usage?$PARAMS" \
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

# Parse and display usage
echo "" >&2
if command -v python3 &> /dev/null; then
    python3 << 'PYTHON_EOF' - "$RESPONSE"
import json
import sys

response = json.loads(sys.argv[1])

# Handle both dict and list responses
if isinstance(response, list):
    data = response
else:
    data = response.get('time_series', response.get('data', []))

    # Summary if available
    summary = response.get('summary', {})
    if isinstance(summary, dict) and summary:
        print("Usage Summary", file=sys.stderr)
        print("=============", file=sys.stderr)
        total_cost = summary.get('total_cost', summary.get('cost', 0))
        total_requests = summary.get('total_requests', summary.get('request_count', 0))
        print(f"  Total Cost: ${total_cost:.4f}", file=sys.stderr)
        print(f"  Total Requests: {total_requests}", file=sys.stderr)
        print("", file=sys.stderr)

# Process time_series data
if isinstance(data, list) and len(data) > 0:
    by_endpoint = {}
    for bucket in data:
        results = bucket.get('results', [bucket]) if isinstance(bucket, dict) else [bucket]
        for item in results:
            if not isinstance(item, dict):
                continue
            endpoint = item.get('endpoint_id', '')
            if not endpoint:
                continue
            if endpoint not in by_endpoint:
                by_endpoint[endpoint] = {'cost': 0, 'quantity': 0}
            by_endpoint[endpoint]['cost'] += float(item.get('cost', 0))
            by_endpoint[endpoint]['quantity'] += float(item.get('quantity', item.get('request_count', 0)))

    if by_endpoint:
        print("Usage by Endpoint", file=sys.stderr)
        print("=================", file=sys.stderr)
        for endpoint, stats in by_endpoint.items():
            print(f"  {endpoint}", file=sys.stderr)
            print(f"    Cost: ${stats['cost']:.4f}", file=sys.stderr)
            print(f"    Quantity: {stats['quantity']:.2f}", file=sys.stderr)
    else:
        print("No usage data found for this period", file=sys.stderr)
PYTHON_EOF
fi

echo "$RESPONSE"
