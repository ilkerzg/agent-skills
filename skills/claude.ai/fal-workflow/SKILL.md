---
name: fal-workflow
description: Generate production-ready fal.ai workflow JSON files. Use when user requests "create workflow", "chain models", "multi-step generation", "image to video pipeline", or complex AI generation pipelines.
metadata:
  author: fal-ai
  version: "3.0.0"
---

# fal.ai Workflow Generator

Generate **100% working, production-ready fal.ai workflow JSON files**. Workflows chain multiple AI models together for complex generation pipelines.

---

## A. Core Architecture

### A1: Basic Workflow Structure

Every workflow MUST have:
1. **Input node** - receives user input
2. **Run nodes** - execute fal models
3. **Output/Display node** - returns results

### Minimal Working Example

```json
{
  "input": {
    "id": "input",
    "type": "input",
    "depends": [],
    "input": {
      "prompt": ""
    }
  },
  "node_1": {
    "id": "node_1",
    "type": "run",
    "depends": ["input"],
    "app": "fal-ai/flux/dev",
    "input": {
      "prompt": "$input.prompt"
    }
  },
  "node_2": {
    "id": "node_2",
    "type": "run",
    "depends": ["node_1"],
    "app": "fal-ai/bria/background/remove",
    "input": {
      "image_url": "$node_1.images.0.url"
    }
  },
  "output": {
    "id": "output",
    "type": "display",
    "depends": ["node_2"],
    "fields": {
      "image": "$node_2.image"
    }
  }
}
```

### Extended UI Format

```json
{
  "name": "workflow-slug-name",
  "title": "Human Readable Title",
  "contents": {
    "name": "workflow",
    "nodes": {
      "output": { ... },
      "node-id-1": { ... },
      "node-id-2": { ... }
    },
    "output": { ... },
    "schema": {
      "input": { ... },
      "output": { ... }
    },
    "version": "1",
    "metadata": {
      "input": {
        "position": { "x": -100, "y": 0 }
      },
      "description": "Workflow description"
    }
  },
  "is_public": true,
  "user_id": "",
  "user_nickname": "",
  "created_at": ""
}
```

---

### A2: Node Types

#### Input Node
```json
"input": {
  "id": "input",
  "type": "input",
  "depends": [],
  "input": {
    "field_name": ""
  }
}
```

#### Run Node
```json
"node-id": {
  "type": "run",
  "id": "node-id",
  "depends": ["input", "other-node"],
  "input": {
    "param": "$input.field",
    "param2": "$other-node.output"
  },
  "app": "fal-ai/model-id",
  "metadata": {
    "position": { "x": 500, "y": 0 }
  }
}
```

#### Display/Output Node
```json
"output": {
  "id": "output",
  "type": "display",
  "depends": ["final-node-1", "final-node-2"],
  "fields": {
    "result1": "$final-node-1.video",
    "result2": "$final-node-2.images.0.url"
  },
  "input": {},
  "metadata": {
    "position": { "x": 2000, "y": 0 }
  }
}
```

---

### A3: Reference Syntax

| Reference | Use Case | Example |
|-----------|----------|---------|
| `$input.field` | Input value | `$input.prompt` |
| `$node.output` | LLM text output | `$node-llm.output` |
| `$node.images.0.url` | First image URL | `$node-img.images.0.url` |
| `$node.images.1.url` | Second image URL | `$node-img.images.1.url` |
| `$node.image.url` | Single image URL | `$node-upscale.image.url` |
| `$node.video` | Video object | `$node-vid.video` |
| `$node.video.url` | Video URL | `$node-vid.video.url` |
| `$node.audio_file.url` | Audio URL | `$node-music.audio_file.url` |
| `$node.frame.url` | Extracted frame | `$node-extract.frame.url` |

### CRITICAL: No String Interpolation

```json
// ❌ WRONG
"prompt": "Create image of $input.subject in $input.style"

// ✅ CORRECT - Use LLM to combine inputs
"prompt": "$input.subject",
"system_prompt": "Create a detailed image based on the subject provided..."
```

---

### A4: Finding Model Schemas

Every model's input/output schema:
```
https://fal.ai/api/openapi/queue/openapi.json?endpoint_id=[endpoint_id]
```

Example:
```
https://fal.ai/api/openapi/queue/openapi.json?endpoint_id=fal-ai/nano-banana-pro
```

---

## B. Model Reference

### B1: Image Generation

#### Nano Banana Pro (DEFAULT)
```json
{
  "app": "fal-ai/nano-banana-pro",
  "input": {
    "prompt": "$node-prompt.output",
    "aspect_ratio": "16:9",
    "num_images": 1
  }
}
```
**Output:** `$node.images.0.url`

#### Nano Banana Pro Edit (DEFAULT for editing)
```json
{
  "app": "fal-ai/nano-banana-pro/edit",
  "input": {
    "prompt": "$node-prompt.output",
    "image_urls": ["$input.source_image"],
    "aspect_ratio": "16:9",
    "resolution": "4K"
  }
}
```
**Output:** `$node.images.0.url`

#### Other Image Models

| Model | App ID |
|-------|--------|
| FLUX.1 Dev | `fal-ai/flux/dev` |
| FLUX.1 Schnell | `fal-ai/flux/schnell` |
| FLUX.1 Pro | `fal-ai/flux-pro` |
| Ideogram v3 | `fal-ai/ideogram/v3` |
| Recraft v3 | `fal-ai/recraft-v3` |

---

### B2: Video Generation

#### Seedance 1.5 Pro (DEFAULT)
```json
{
  "app": "fal-ai/bytedance/seedance/v1.5/pro/image-to-video",
  "input": {
    "prompt": "$node-video-prompt.output",
    "image_url": "$node-image.images.0.url",
    "aspect_ratio": "16:9",
    "resolution": "720p",
    "duration": "5",
    "generate_audio": true
  }
}
```
**Output:** `$node.video.url`

#### Kling Video O1 (Image-to-Video with First/Last Frame)
```json
{
  "app": "fal-ai/kling-video/o1/image-to-video",
  "input": {
    "prompt": "$node-prompt.output",
    "image_url": "$node-start-frame.images.0.url",
    "tail_image_url": "$node-end-frame.images.0.url",
    "duration": "5",
    "aspect_ratio": "16:9"
  }
}
```
**Output:** `$node.video.url`

#### Other Video Models

| Model | App ID | Notes |
|-------|--------|-------|
| Veo 3.1 Fast | `fal-ai/veo3.1/fast/image-to-video` | High quality |
| Kling 1.6 Pro | `fal-ai/kling-video/v1.6/pro/image-to-video` | Cinematic |
| Kling 2.6 Pro | `fal-ai/kling-video/v2.6/pro/image-to-video` | **Best I2V** |
| Hunyuan | `fal-ai/hunyuan-video` | Text-to-video |
| Wan 2.1 | `fal-ai/wan/v2.1/image-to-video` | I2V |
| LTX Video | `fal-ai/ltx-video` | Fast T2V |

---

### B3: LLM Models

#### Text LLM (DEFAULT - No images)
```json
{
  "app": "openrouter/router",
  "input": {
    "prompt": "$input.user_input",
    "system_prompt": "Your instructions here...",
    "model": "google/gemini-2.5-flash",
    "temperature": 0.7
  }
}
```
**Output:** `$node.output`

#### Vision LLM (When image analysis needed)
```json
{
  "app": "openrouter/router/vision",
  "input": {
    "prompt": "$input.user_request",
    "system_prompt": "Analyze the image and...",
    "image_urls": ["$node-image.images.0.url"],
    "model": "google/gemini-3-pro-preview",
    "reasoning": true
  }
}
```
**Output:** `$node.output`

**Available LLM Models:**
- `google/gemini-2.5-flash` - Fast, good quality
- `google/gemini-3-pro-preview` - Best reasoning
- `anthropic/claude-sonnet-4.5` - Best for complex tasks

---

### B4: Audio/Music Generation

#### ElevenLabs Music
```json
{
  "app": "fal-ai/elevenlabs/music",
  "input": {
    "prompt": "Mysterious soundtrack, jungle themes, tribal percussion",
    "respect_sections_durations": true,
    "output_format": "mp3_44100_128"
  }
}
```
**Output:** `$node.audio_file.url`

#### MMAudio (Video to Audio)
```json
{
  "app": "fal-ai/mmaudio",
  "input": {
    "video_url": "$node-video.video.url",
    "prompt": "Ambient nature sounds"
  }
}
```

#### Stable Audio
```json
{
  "app": "fal-ai/stable-audio",
  "input": {
    "prompt": "Cinematic orchestral music"
  }
}
```

#### Other Music Models

| Model | App ID |
|-------|--------|
| MiniMax Music v2 | `fal-ai/minimax-music/v2` |
| MiniMax Music v1.5 | `fal-ai/minimax-music/v1.5` |
| Lyria2 | `fal-ai/lyria2` |
| Sonauto v2 | `fal-ai/sonauto/v2` |
| Ace Step | `fal-ai/ace-step` |
| Beatoven | `fal-ai/beatoven` |

---

### B5: FFmpeg Utilities (CRITICAL)

#### Extract Frame from Video
```json
{
  "app": "fal-ai/ffmpeg-api/extract-frame",
  "input": {
    "video_url": "$node-video.video.url",
    "frame_type": "first"
  }
}
```
**Output:** `$node.frame.url`

**frame_type options:** `"first"` or `"last"`

**Use Cases:**
- Get last frame for video extension
- Get first frame for transitions
- Extract frame for first/last frame video generation

#### Merge Multiple Videos
```json
{
  "app": "fal-ai/ffmpeg-api/merge-videos",
  "input": {
    "video_urls": [
      "$node-video-1.video.url",
      "$node-video-2.video.url",
      "$node-video-3.video.url"
    ]
  }
}
```
**Output:** `$node.video.url`

#### Merge Audio and Video
```json
{
  "app": "fal-ai/ffmpeg-api/merge-audio-video",
  "input": {
    "video_url": "$node-video.video.url",
    "audio_url": "$node-music.audio_file.url"
  }
}
```
**Output:** `$node.video.url`

---

### B6: Image Processing

#### Upscale Image
```json
{
  "app": "fal-ai/seedvr/upscale/image",
  "input": {
    "image_url": "$node-image.images.0.url"
  }
}
```
**Output:** `$node.image.url`

#### Remove Background
```json
{
  "app": "fal-ai/bria/background/remove",
  "input": {
    "image_url": "$node-image.images.0.url"
  }
}
```
**Output:** `$node.image.url`

#### Face Swap
```json
{
  "app": "fal-ai/face-swap",
  "input": {
    "base_image_url": "$input.target_image",
    "swap_image_url": "$input.face_image"
  }
}
```

---

## C. Critical Rules

### C1: Dependencies Must Match References

Every `$node-id.xxx` reference MUST have that node in `depends`:

```json
// ❌ WRONG
"node-b": {
  "depends": [],
  "input": { "data": "$node-a.output" }
}

// ✅ CORRECT
"node-b": {
  "depends": ["node-a"],
  "input": { "data": "$node-a.output" }
}
```

### C2: ID Must Match Object Key

```json
// ❌ WRONG
"my-node": { "id": "different-id" }

// ✅ CORRECT
"my-node": { "id": "my-node" }
```

### C3: Use Correct LLM Type

- `openrouter/router` → Text only, no image_urls
- `openrouter/router/vision` → ONLY when analyzing images

### C4: Schema modelId Required

```json
"schema": {
  "input": {
    "field": {
      "modelId": "first-consuming-node"
    }
  }
}
```

### C5: Output Depends on All Referenced Nodes

```json
"output": {
  "depends": ["node-a", "node-b", "node-c"],
  "fields": {
    "a": "$node-a.video",
    "b": "$node-b.images.0.url",
    "c": "$node-c.output"
  }
}
```

---

## D. Common Patterns

### D1: LLM Prompt → Image → Video

```
[Input] → [LLM: Image Prompt] → [Image Gen]
                ↓
          [LLM: Video Prompt] → [Video Gen] → [Output]
```

### D2: Parallel Processing (Fan-Out)

```
                → [Process A] →
[Hub Node] → [Process B] → [Merge] → [Output]
                → [Process C] →
```

All parallel nodes depend on hub, NOT on each other.

### D3: Video Extension with Extract Frame

```
[Video 1] → [Extract Last Frame] → [Video 2 with Start Frame] → [Merge] → [Output]
```

```json
"node-extract": {
  "depends": ["node-video-1"],
  "app": "fal-ai/ffmpeg-api/extract-frame",
  "input": {
    "video_url": "$node-video-1.video.url",
    "frame_type": "last"
  }
},
"node-video-2": {
  "depends": ["node-extract", "node-prompt-2"],
  "app": "fal-ai/kling-video/o1/image-to-video",
  "input": {
    "prompt": "$node-prompt-2.output",
    "image_url": "$node-extract.frame.url"
  }
}
```

### D4: First/Last Frame Video (Kling O1)

```
[Start Image] →
                → [Kling O1 Video] → [Output]
[End Image]   →
```

```json
"node-video": {
  "depends": ["node-start-frame", "node-end-frame", "node-prompt"],
  "app": "fal-ai/kling-video/o1/image-to-video",
  "input": {
    "prompt": "$node-prompt.output",
    "image_url": "$node-start-frame.images.0.url",
    "tail_image_url": "$node-end-frame.images.0.url"
  }
}
```

### D5: Video with Custom Music

```
[Video Gen] →                    → [Merge Audio/Video] → [Output]
[Music Gen] → [audio_file.url] →
```

```json
"node-music": {
  "depends": ["input"],
  "app": "fal-ai/elevenlabs/music",
  "input": {
    "prompt": "$input.music_style"
  }
},
"node-merge": {
  "depends": ["node-video", "node-music"],
  "app": "fal-ai/ffmpeg-api/merge-audio-video",
  "input": {
    "video_url": "$node-video.video.url",
    "audio_url": "$node-music.audio_file.url"
  }
}
```

### D6: Multi-Destination Campaign (Complex)

Pattern for multi-destination marketing videos:

```
[Input: dest_1] → [Vision LLM: Prompt] → [Edit Image] → [Upscale] →
                                                                    → [Vision LLM: Video Prompt] → [Video Gen]
                  [Edit: Remove Text] → [Upscale] →

[Input: dest_2] → [Same pattern...]
[Input: dest_3] → [Same pattern...]

All Videos → [Merge Videos] → [Output]
```

---

## E. Real-World Example

### Turkish Airlines Campaign Workflow

This workflow:
1. Takes multiple destinations as input
2. Uses Vision LLM to analyze template and generate edit prompts
3. Creates destination-specific images
4. Removes backgrounds
5. Upscales all images
6. Generates videos with 360° camera tours
7. Merges all videos into final output

#### Key Pattern: Edit → Remove Text → Upscale → Video

```json
// Step 1: Vision LLM analyzes template, generates edit prompt
"openrouter/router/vision_3": {
  "id": "openrouter/router/vision_3",
  "type": "run",
  "depends": ["input"],
  "app": "openrouter/router/vision",
  "input": {
    "image_urls": ["https://template-image.jpg"],
    "prompt": "$input.destination_2",
    "system_prompt": "Generate prompt to change background to destination, keep layout...",
    "model": "google/gemini-3-pro-preview",
    "reasoning": true
  }
},

// Step 2: Edit image with new destination
"fal_ai/nano_banana_pro/edit_2": {
  "id": "fal_ai/nano_banana_pro/edit_2",
  "type": "run",
  "depends": ["openrouter/router/vision_3"],
  "app": "fal-ai/nano-banana-pro/edit",
  "input": {
    "image_urls": ["https://template-image.jpg"],
    "prompt": "$openrouter/router/vision_3.output",
    "aspect_ratio": "16:9"
  }
},

// Step 3: Create text-free version for video background
"fal_ai/nano_banana_pro/edit_4": {
  "id": "fal_ai/nano_banana_pro/edit_4",
  "type": "run",
  "depends": ["fal_ai/nano_banana_pro/edit_2"],
  "app": "fal-ai/nano-banana-pro/edit",
  "input": {
    "image_urls": ["$fal_ai/nano_banana_pro/edit_2.images.0.url"],
    "prompt": "Remove all text and logo, leave only background scene"
  }
},

// Step 4: Upscale both versions
"fal_ai/seedvr/upscale/image_2": {
  "id": "fal_ai/seedvr/upscale/image_2",
  "type": "run",
  "depends": ["fal_ai/nano_banana_pro/edit_2"],
  "app": "fal-ai/seedvr/upscale/image",
  "input": {
    "image_url": "$fal_ai/nano_banana_pro/edit_2.images.0.url"
  }
},

// Step 5: Vision LLM creates video prompt from both images
"openrouter/router/vision_4": {
  "id": "openrouter/router/vision_4",
  "type": "run",
  "depends": ["fal_ai/seedvr/upscale/image_4", "fal_ai/seedvr/upscale/image_2", "input"],
  "app": "openrouter/router/vision",
  "input": {
    "image_urls": [
      "$fal_ai/seedvr/upscale/image_4.image.url",
      "$fal_ai/seedvr/upscale/image_2.image.url"
    ],
    "prompt": "$input.destination_2",
    "system_prompt": "Create video prompt: camera tours 360° then transitions to tail image..."
  }
},

// Step 6: Generate video with first/last frame
"fal_ai/kling_video/o1/image_to_video_2": {
  "id": "fal_ai/kling_video/o1/image_to_video_2",
  "type": "run",
  "depends": ["openrouter/router/vision_4", "fal_ai/seedvr/upscale/image_4", "fal_ai/seedvr/upscale/image_2"],
  "app": "fal-ai/kling-video/o1/image-to-video",
  "input": {
    "prompt": "$openrouter/router/vision_4.output",
    "image_url": "$fal_ai/seedvr/upscale/image_4.image.url",
    "tail_image_url": "$fal_ai/seedvr/upscale/image_2.image.url"
  }
},

// Step 7: Merge all destination videos
"fal_ai/ffmpeg_api/merge_videos": {
  "id": "fal_ai/ffmpeg_api/merge_videos",
  "type": "run",
  "depends": ["fal_ai/kling_video/o1/image_to_video", "fal_ai/kling_video/o1/image_to_video_2", "fal_ai/kling_video/o1/image_to_video_3"],
  "app": "fal-ai/ffmpeg-api/merge-videos",
  "input": {
    "video_urls": [
      "$fal_ai/kling_video/o1/image_to_video.video.url",
      "$fal_ai/kling_video/o1/image_to_video_2.video.url",
      "$fal_ai/kling_video/o1/image_to_video_3.video.url"
    ]
  }
}
```

---

## F. Input Schema

```json
"schema": {
  "input": {
    "text_field": {
      "name": "text_field",
      "label": "Display Label",
      "type": "string",
      "description": "Help text",
      "required": true,
      "examples": ["Example"],
      "ui": { "placeholder": "Enter..." },
      "modelId": "consuming-node"
    },

    "image_urls": {
      "name": "image_urls",
      "type": { "kind": "list", "elementType": "string" },
      "required": true,
      "modelId": "node-id"
    },

    "count": {
      "name": "count",
      "type": "number",
      "default": 5,
      "modelId": "node-id"
    },

    "enable": {
      "name": "enable",
      "type": "boolean",
      "default": true,
      "modelId": "node-id"
    }
  }
}
```

---

## G. Pre-Output Checklist

Before outputting any workflow, verify:

- [ ] Every `$node.xxx` has matching `depends` entry
- [ ] Every node `id` matches object key
- [ ] No string interpolation in references
- [ ] Input schema has `modelId` for each field
- [ ] Output depends on ALL referenced nodes
- [ ] Correct LLM type (router vs router/vision)
- [ ] Correct output references (.output, .images.0.url, .video.url, .image.url, .audio_file.url, .frame.url)
- [ ] Positions arranged left-to-right

---

## H. Default Models

When user doesn't specify:

| Task | Default Model |
|------|---------------|
| Image generation | `fal-ai/nano-banana-pro` |
| Image editing | `fal-ai/nano-banana-pro/edit` |
| Video (I2V) | `fal-ai/bytedance/seedance/v1.5/pro/image-to-video` |
| Text LLM | `openrouter/router` with `google/gemini-2.5-flash` |
| Vision LLM | `openrouter/router/vision` with `google/gemini-3-pro-preview` |
| Music | `fal-ai/elevenlabs/music` |
| Upscale | `fal-ai/seedvr/upscale/image` |
| Video merge | `fal-ai/ffmpeg-api/merge-videos` |
| Audio+Video merge | `fal-ai/ffmpeg-api/merge-audio-video` |
| Frame extract | `fal-ai/ffmpeg-api/extract-frame` |

---

## I. Quick Reference Card

### Output References

| Model Type | Output Reference |
|------------|------------------|
| LLM | `$node.output` |
| Image Gen (array) | `$node.images.0.url` |
| Image Process (single) | `$node.image.url` |
| Video | `$node.video.url` |
| Music | `$node.audio_file.url` |
| Frame Extract | `$node.frame.url` |
| Merged Video | `$node.video.url` |

### Common App IDs

```
fal-ai/nano-banana-pro
fal-ai/nano-banana-pro/edit
fal-ai/bytedance/seedance/v1.5/pro/image-to-video
fal-ai/kling-video/o1/image-to-video
fal-ai/kling-video/v2.6/pro/image-to-video
fal-ai/veo3.1/fast/image-to-video
fal-ai/elevenlabs/music
fal-ai/ffmpeg-api/merge-videos
fal-ai/ffmpeg-api/merge-audio-video
fal-ai/ffmpeg-api/extract-frame
fal-ai/seedvr/upscale/image
fal-ai/bria/background/remove
openrouter/router
openrouter/router/vision
```

---

## Usage

### Using Script

```bash
bash /mnt/skills/user/fal-workflow/scripts/create-workflow.sh \
  --name "my-workflow" \
  --title "My Workflow Title" \
  --nodes '[...]' \
  --outputs '{...}'
```

### Using MCP Tool

```javascript
mcp__fal-ai__create-workflow({
  smartMode: true,
  intent: "Generate a story with LLM, create an illustration, then animate it"
})
```

Or manual mode:
```javascript
mcp__fal-ai__create-workflow({
  workflowName: "story-to-video",
  workflowTitle: "Story to Video",
  description: "Generate story, illustration, and video",
  nodes: [...],
  outputs: {...}
})
```

### Direct JSON Generation

Generate the JSON directly following the structure in this document.

---

## Troubleshooting

### Dependency Error
```
Error: Node references $node-x but doesn't depend on it
```
**Solution:** Add the referenced node to the `depends` array.

### ID Mismatch Error
```
Error: Node key "my-node" doesn't match id "different-id"
```
**Solution:** Ensure the object key matches the `id` field exactly.

### Invalid Reference
```
Error: Cannot resolve $node.invalid.path
```
**Solution:** Check the model's output schema and use correct reference path.

### LLM Vision Error
```
Error: image_urls provided but using text-only router
```
**Solution:** Switch to `openrouter/router/vision` when analyzing images.
