---
name: fal-video-edit
description: Edit existing videos using AI — remix style, edit content, upscale resolution, remove background, or add audio/sound effects. Use when the user requests "Edit video", "Remix video", "Upscale video", "Remove video background", "Add sound to video", "Video to audio".
metadata:
  author: fal-ai
  version: "1.0.0"
---

# fal-video-edit

Edit, remix, upscale, and enhance existing videos using fal.ai models.

## Scripts

| Script | Purpose |
|--------|---------|
| `edit-video.sh` | Edit or remix a video with AI |
| `video-audio.sh` | Add synchronized audio/sound effects to a video |

## Usage

### Remix / Restyle Video
```bash
./scripts/edit-video.sh --video-url "https://example.com/video.mp4" --prompt "Transform into anime style" --operation remix
```

### Edit Video Content
```bash
./scripts/edit-video.sh --video-url "https://example.com/video.mp4" --prompt "Remove the person in the background" --operation edit
```

### Upscale Video
```bash
./scripts/edit-video.sh --video-url "https://example.com/video.mp4" --operation upscale
```

### Remove Video Background
```bash
./scripts/edit-video.sh --video-url "https://example.com/video.mp4" --operation remove-bg
```

### Add Audio to Video
```bash
./scripts/video-audio.sh --video-url "https://example.com/silent-video.mp4" --prompt "City street ambiance with car horns and people talking"
```

## Arguments

### edit-video.sh
| Argument | Description | Required |
|----------|-------------|----------|
| `--video-url` | URL of video to edit | Yes |
| `--prompt` / `-p` | Edit instructions or style description | For remix/edit |
| `--operation` | remix, edit, upscale, remove-bg | Yes |
| `--model` / `-m` | Override model endpoint | No |

### video-audio.sh
| Argument | Description | Required |
|----------|-------------|----------|
| `--video-url` | URL of video to add audio to | Yes |
| `--prompt` / `-p` | Description of desired audio/sounds | No |
| `--model` / `-m` | Model endpoint | No (default: fal-ai/mmaudio-v2) |

## Recommended Models

| Operation | Model | Notes |
|-----------|-------|-------|
| Remix (pro) | `fal-ai/kling-video/o3/pro/video-to-video/reference` | Best quality remix |
| Remix (fast) | `fal-ai/kling-video/o3/standard/video-to-video/reference` | Faster |
| Edit (pro) | `fal-ai/kling-video/o3/pro/video-to-video/edit` | Best quality edit |
| Edit (fast) | `fal-ai/kling-video/o3/standard/video-to-video/edit` | Faster |
| Upscale (pro) | `fal-ai/topaz/upscale/video` | Professional quality |
| Upscale (fast) | `fal-ai/flashvsr` | Fast super-resolution |
| Remove BG | `fal-ai/bria/video/background-removal` | Clean removal |
| Add audio | `fal-ai/mmaudio-v2` | Synchronized audio from video |
| Sound effects | `fal-ai/pixverse/sound-effects` | Add SFX and music |
