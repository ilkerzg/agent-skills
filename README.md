# Agent Skills

A collection of skills for AI coding agents. Skills are packaged instructions and scripts that extend agent capabilities.

Skills follow the [Agent Skills](https://agentskills.io/) format.

## Available Skills

### fal-generate

Generate images and videos using fal.ai's AI models with full queue support.

**Use when:**
- "Generate an image of..."
- "Create a video"
- "Search for models"
- "Check generation status"

**Scripts:**
- `generate.sh` - Generate images/videos (queue-based by default)
- `upload.sh` - Upload local files to fal CDN
- `search-models.sh` - Search and discover models
- `get-schema.sh` - Get OpenAPI schema for any model

**Key Features:**
- Queue mode (default) - reliable for long-running tasks
- `--file` - Auto-upload local files to CDN
- `--async` - Submit and return immediately with request_id
- `--status/--result/--cancel` - Queue operations

### fal-platform

Platform management: pricing, usage, cost estimation.

**Use when:**
- "Show pricing"
- "Check usage"
- "Estimate cost"
- "Setup fal key"

**Scripts:**
- `setup.sh` - Configure FAL_KEY (`--add-fal-key`)
- `pricing.sh` - Get model pricing
- `usage.sh` - Check usage and billing
- `estimate-cost.sh` - Cost estimation
- `requests.sh` - List/manage requests

### fal-upscale

Upscale and enhance image resolution.

**Use when:**
- "Upscale this image"
- "Enhance resolution"

**Models:** AuraSR, Clarity Upscaler, SeedVR

### fal-workflow

Generate production-ready fal.ai workflow JSON files.

**Use when:**
- "Create a workflow"
- "Chain models"
- "Multi-step pipeline"

**Features:** Node-based pipelines, LLM + Image + Video + Audio chaining

### fal-audio

Text-to-speech and speech-to-text.

**Use when:**
- "Convert text to speech"
- "Transcribe audio"

**Scripts:** `text-to-speech.sh`, `speech-to-text.sh`

### fal-image-edit

Image editing: style transfer, object removal, backgrounds.

**Use when:**
- "Edit this image"
- "Remove object"
- "Change background"

### react-best-practices

React/Next.js performance optimization guidelines.

### web-design-guidelines

Web interface best practices: accessibility, performance, UX.

## Getting Your API Key

1. Go to [fal.ai/dashboard/keys](https://fal.ai/dashboard/keys)
2. Create a new API key

**Key Types:**
| Key Type | Use For |
|----------|---------|
| **Normal API Key** | Image/video generation, model inference |
| **Admin API Key** | Usage tracking, pricing info, billing data |

> **Note:** For `pricing.sh`, `usage.sh`, and `estimate-cost.sh`, you need an **Admin API Key**. Generation scripts work with any key type.

## Recommended Models

### Text-to-Image & Image Editing

| Model | Best For |
|-------|----------|
| `fal-ai/nano-banana-pro` | **Best overall** - T2I and image editing |
| `fal-ai/flux-2-turbo` | Open source, high quality |
| `fal-ai/flux-2-klein-9b` | Open source, fast |

### Text-to-Video

| Model | Notes |
|-------|-------|
| `fal-ai/veo3.1` | High quality |
| `fal-ai/bytedance/seedance/v1/pro` | Fast, good quality |
| `fal-ai/sora-2/pro` | OpenAI Sora |
| `fal-ai/kling-video/v2.5-turbo/pro` | Fast, reliable |
| `fal-ai/minimax/hailuo-02/pro` | Good for characters |
| `fal-ai/pixverse/v5` | Creative styles |

### Image-to-Video

| Model | Notes |
|-------|-------|
| `fal-ai/kling-video/v2.6/pro` | **Best overall** |
| `fal-ai/veo3/fast` | Fast, high quality |
| `fal-ai/minimax/hailuo-02/standard` | Good balance |
| `fal-ai/bytedance/seedance/v1.5/pro` | Smooth motion |
| `fal-ai/wan-25-preview` | Experimental |

### Start + End Frame I2V

| Model | Notes |
|-------|-------|
| `fal-ai/veo3.1/first-last-frame` | Best quality |
| `fal-ai/kling-video/v2.6/pro` | Reliable |
| `fal-ai/bytedance/seedance/v1.5/pro` | Good transitions |
| `fal-ai/minimax/hailuo-02/pro` | Fast |
| `fal-ai/pixverse/v5/transition` | Creative |

### Video Upscale

| Model | Notes |
|-------|-------|
| `fal-ai/video-upscaler` | General purpose |
| `fal-ai/topaz/upscale/video` | Premium quality |
| `fal-ai/bria/video/increase-resolution` | Fast |
| `fal-ai/flashvsr` | Real-time |
| `fal-ai/seedvr/upscale/video` | High fidelity |

### Video Background Removal

| Model | Notes |
|-------|-------|
| `fal-ai/bria/video/background-removal` | Best quality |
| `fal-ai/birefnet/v2/video` | Fast |

### Text-to-Speech

| Model | Notes |
|-------|-------|
| `fal-ai/minimax/speech-2.6-hd` | **Best quality** |
| `fal-ai/minimax/speech-2.6-turbo` | Fast, good quality |
| `fal-ai/elevenlabs/eleven-v3` | Natural voices |
| `fal-ai/chatterbox/multilingual` | Multi-language |
| `fal-ai/kling-video/v1/tts` | Video sync |

### Text-to-Music

| Model | Notes |
|-------|-------|
| `fal-ai/minimax-music/v2` | Best quality |
| `fal-ai/minimax-music/v1.5` | Fast |
| `fal-ai/lyria2` | Google's model |
| `fal-ai/elevenlabs/music` | Song generation |
| `fal-ai/sonauto/v2` | Instrumental |
| `fal-ai/ace-step` | Short clips |
| `fal-ai/beatoven` | Background music |

## Quick Start

### 1. Setup API Key

```bash
# Any script supports --add-fal-key
bash generate.sh --add-fal-key "your_key_here"

# Or use dedicated setup
bash setup.sh --add-fal-key
```

### 2. Generate Content

```bash
# Image (queue mode - waits for completion)
bash generate.sh --prompt "a sunset over mountains" --model "fal-ai/nano-banana-pro"

# Image-to-Video with local file (auto-uploads)
bash generate.sh --file "photo.jpg" --model "fal-ai/kling-video/v2.6/pro/image-to-video" --prompt "zoom in"

# Video async (returns immediately with request_id)
bash generate.sh --prompt "ocean waves" --model "fal-ai/veo3.1" --async

# Check status / get result
bash generate.sh --status "request_id" --model "fal-ai/veo3.1"
bash generate.sh --result "request_id" --model "fal-ai/veo3.1"
```

### 3. Get Model Schema (OpenAPI)

```bash
# Get model parameters before generating
bash get-schema.sh --model "fal-ai/nano-banana-pro"

# Or via generate.sh
bash generate.sh --schema "fal-ai/kling-video/v2.6/pro/image-to-video"

# API endpoint
curl "https://fal.ai/api/openapi/queue/openapi.json?endpoint_id=fal-ai/nano-banana-pro"
```

### 4. Check Pricing & Usage

> **Note:** Requires Admin API Key

```bash
# Pricing
bash pricing.sh --model "fal-ai/nano-banana-pro"

# Usage
bash usage.sh

# Estimate cost
bash estimate-cost.sh --model "fal-ai/nano-banana-pro" --calls 100
```

## Common Flags

All fal.ai scripts support:

| Flag | Description |
|------|-------------|
| `--add-fal-key [KEY]` | Setup FAL_KEY in .env |
| `--help`, `-h` | Show help |
| `--json` | Raw JSON output |
| `--schema [MODEL]` | Get OpenAPI schema (generate.sh) |

## Installation

```bash
npx add-skill vercel-labs/agent-skills
```

## Environment Setup

```bash
# Option 1: Export directly
export FAL_KEY=your_api_key_here

# Option 2: Use .env file
echo "FAL_KEY=your_key" >> .env

# Option 3: Use --add-fal-key flag
bash generate.sh --add-fal-key
```

For claude.ai, add `*.fal.ai` to allowed domains at `claude.ai/settings/capabilities`.

## License

MIT
