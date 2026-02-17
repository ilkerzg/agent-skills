---
name: fal-lip-sync
description: Create talking head videos, lip sync audio to video, and animate portraits with expressions. Use when the user requests "Talking head", "Lip sync", "Make this person talk", "Animate portrait", "Live portrait", "Avatar video".
metadata:
  author: fal-ai
  version: "1.0.0"
---

# fal-lip-sync

Create talking head videos, sync lips to audio, and animate portraits using fal.ai models.

## Scripts

| Script | Purpose |
|--------|---------|
| `talking-head.sh` | Generate a talking head video from an image + audio/text |
| `lip-sync.sh` | Sync lips in an existing video to new audio |

## Usage

### Talking Head (Image + Audio → Video)
```bash
./scripts/talking-head.sh --image-url "https://example.com/portrait.jpg" --audio-url "https://example.com/speech.mp3" --model fal-ai/veed/fabric-1.0
```

### Talking Head (Image + Text → Video with auto TTS)
```bash
./scripts/talking-head.sh --image-url "https://example.com/portrait.jpg" --text "Hello, welcome to our presentation" --model fal-ai/creatify/aurora
```

### Lip Sync (Video + Audio → Synced Video)
```bash
./scripts/lip-sync.sh --video-url "https://example.com/video.mp4" --audio-url "https://example.com/new-speech.mp3"
```

## Arguments

### talking-head.sh
| Argument | Description | Required |
|----------|-------------|----------|
| `--image-url` | URL of portrait/face image | Yes |
| `--audio-url` | URL of audio to sync | Yes (or --text) |
| `--text` | Text to speak (auto TTS) | Yes (or --audio-url) |
| `--model` / `-m` | Model endpoint | No (default: fal-ai/veed/fabric-1.0) |
| `--tts-model` | TTS model for --text mode | No (default: fal-ai/minimax/speech-2.6-turbo) |
| `--wait` / `-w` | Wait for completion | No (default: true) |
| `--async` / `-a` | Return request ID immediately | No |

### lip-sync.sh
| Argument | Description | Required |
|----------|-------------|----------|
| `--video-url` | URL of video to lip sync | Yes |
| `--audio-url` | URL of audio to sync to | Yes |
| `--model` / `-m` | Model endpoint | No (default: fal-ai/sync-lipsync/v2) |

## Recommended Models

| Use Case | Model | Notes |
|----------|-------|-------|
| Best talking head | `fal-ai/veed/fabric-1.0` | VEED Fabric. High fidelity. |
| Audio-correlated motion | `fal-ai/bytedance/omnihuman/v1.5` | OmniHuman. Strong audio-motion correlation. |
| Avatar speaking/singing | `fal-ai/creatify/aurora` | Aurora. High-fidelity avatar videos. |
| Best lip sync | `fal-ai/sync-lipsync/v2` | Sync Lipsync 2.0. Best video lip sync. |
| Alternative lip sync | `fal-ai/pixverse/lipsync` | PixVerse. Good quality. |
| Live portrait | `fal-ai/live-portrait` | Transfer expressions from driving video. |

## Output Format
```json
{
  "video": {
    "url": "https://fal.media/files/...",
    "content_type": "video/mp4"
  }
}
```

Present the video URL directly to the user.
