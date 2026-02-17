---
name: fal-3d
description: Generate 3D models from text or images. Use when the user requests "Create 3D model", "Text to 3D", "Image to 3D", "3D generation", "Generate mesh", "3D asset".
metadata:
  author: fal-ai
  version: "1.0.0"
---

# fal-3d

Generate 3D models (GLB/OBJ/PLY) from text descriptions or images using fal.ai.

## Scripts

| Script | Purpose |
|--------|---------|
| `generate-3d.sh` | Generate a 3D model from text or image |

## Usage

### Image to 3D
```bash
./scripts/generate-3d.sh --image-url "https://example.com/object.jpg" --model fal-ai/hunyuan-3d/v3.1
```

### Text to 3D
```bash
./scripts/generate-3d.sh --prompt "A medieval sword with ornate handle" --model fal-ai/meshy/v6/text-to-3d
```

## Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `--image-url` | URL of image to convert to 3D | Yes (or --prompt) |
| `--prompt` / `-p` | Text description for text-to-3D | Yes (or --image-url) |
| `--model` / `-m` | Model endpoint | No (default: fal-ai/hunyuan-3d/v3.1) |
| `--param` | Extra param as key=value (repeatable) | No |

## Recommended Models

| Use Case | Model | Notes |
|----------|-------|-------|
| Best image-to-3D | `fal-ai/hunyuan-3d/v3.1` | Hunyuan3D v3.1. Highest quality. |
| Fast image-to-3D | `fal-ai/trellis` | TRELLIS. Fast conversion. |
| Text-to-3D | `fal-ai/meshy/v6/text-to-3d` | Meshy v6. Best text-to-3D. |
| Image-to-3D alt | `fal-ai/meshy/v6/image-to-3d` | Meshy v6. Good alternative. |
| Game assets | `fal-ai/rodin/generation` | Rodin. Designed for game assets. |
| Single image | `fal-ai/triposr` | TripoSR. Fast single-image 3D. |

## Tips

- For best results from images: use a clear photo with a single object on a plain background
- Remove background first if needed (use fal-image-edit or fal-generate with birefnet)
- Simple, well-defined objects work best — complex scenes don't reconstruct well yet
- 3D generation takes 1-5 minutes — jobs use the queue API

## Output Format
```json
{
  "mesh": {
    "url": "https://fal.media/files/.../model.glb",
    "content_type": "model/gltf-binary",
    "file_name": "model.glb"
  }
}
```
