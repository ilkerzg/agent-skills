#!/bin/bash

# fal.ai Setup Script
# Usage: ./setup.sh --add-fal-key [KEY] | --show-config
# Manages FAL_KEY and configuration

set -e

ENV_FILE=".env"
ACTION=""
FAL_KEY_VALUE=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --add-fal-key)
            ACTION="add-key"
            if [[ -n "$2" && ! "$2" =~ ^-- ]]; then
                FAL_KEY_VALUE="$2"
                shift
            fi
            shift
            ;;
        --show-config)
            ACTION="show-config"
            shift
            ;;
        --help|-h)
            echo "fal.ai Setup Script" >&2
            echo "" >&2
            echo "Usage:" >&2
            echo "  ./setup.sh --add-fal-key [KEY]  Add or update FAL_KEY" >&2
            echo "  ./setup.sh --show-config        Show current configuration" >&2
            echo "" >&2
            echo "Examples:" >&2
            echo "  ./setup.sh --add-fal-key                    # Interactive prompt" >&2
            echo "  ./setup.sh --add-fal-key \"your_key_here\"    # Direct set" >&2
            echo "" >&2
            echo "Get your API key at: https://fal.ai/dashboard/keys" >&2
            exit 0
            ;;
        *)
            echo "Unknown option: $1" >&2
            echo "Use --help for usage information" >&2
            exit 1
            ;;
    esac
done

# Show config
if [ "$ACTION" = "show-config" ]; then
    echo "fal.ai Configuration" >&2
    echo "===================" >&2

    if [ -f "$ENV_FILE" ]; then
        echo "Environment file: $ENV_FILE" >&2
        if grep -q "FAL_KEY" "$ENV_FILE" 2>/dev/null; then
            KEY=$(grep "FAL_KEY" "$ENV_FILE" | cut -d'=' -f2 | tr -d '"' | tr -d "'")
            MASKED="${KEY:0:8}...${KEY: -4}"
            echo "FAL_KEY: $MASKED (set)" >&2
        else
            echo "FAL_KEY: not set" >&2
        fi
    else
        echo "Environment file: not found" >&2
    fi

    if [ -n "$FAL_KEY" ]; then
        MASKED="${FAL_KEY:0:8}...${FAL_KEY: -4}"
        echo "FAL_KEY (env): $MASKED" >&2
    fi

    exit 0
fi

# Add FAL_KEY
if [ "$ACTION" = "add-key" ]; then
    # Get key value
    if [ -z "$FAL_KEY_VALUE" ]; then
        echo "Enter your fal.ai API key:" >&2
        echo "(Get it from https://fal.ai/dashboard/keys)" >&2
        read -r FAL_KEY_VALUE
    fi

    if [ -z "$FAL_KEY_VALUE" ]; then
        echo "Error: No API key provided" >&2
        exit 1
    fi

    # Validate key format (basic check)
    if [[ ! "$FAL_KEY_VALUE" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Warning: API key contains unusual characters" >&2
    fi

    # Update or create .env file
    if [ -f "$ENV_FILE" ]; then
        # Remove existing FAL_KEY line
        grep -v "^FAL_KEY=" "$ENV_FILE" > "$ENV_FILE.tmp" 2>/dev/null || true
        mv "$ENV_FILE.tmp" "$ENV_FILE"
    fi

    # Add new FAL_KEY
    echo "FAL_KEY=$FAL_KEY_VALUE" >> "$ENV_FILE"

    echo "" >&2
    echo "FAL_KEY saved to $ENV_FILE" >&2
    echo "" >&2
    echo "To use in current session, run:" >&2
    echo "  source $ENV_FILE" >&2
    echo "" >&2
    echo "Or export directly:" >&2
    echo "  export FAL_KEY=$FAL_KEY_VALUE" >&2

    # Output JSON
    echo "{\"success\": true, \"env_file\": \"$ENV_FILE\"}"
    exit 0
fi

# Default: show help
echo "fal.ai Setup Script" >&2
echo "" >&2
echo "Usage:" >&2
echo "  ./setup.sh --add-fal-key [KEY]  Add or update FAL_KEY" >&2
echo "  ./setup.sh --show-config        Show current configuration" >&2
echo "" >&2
echo "Get your API key at: https://fal.ai/dashboard/keys" >&2
