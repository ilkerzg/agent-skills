---
name: fal-audio
description: Text-to-speech and speech-to-text using fal.ai audio models. Use when the user requests "Convert text to speech", "Transcribe audio", "Generate voice", "Speech to text", "TTS", "STT", or similar audio tasks.
metadata:
  author: fal-ai
  version: "1.0.0"
---

# fal.ai Audio

Text-to-speech and speech-to-text using state-of-the-art audio models on fal.ai.

## How It Works

1. User provides text (for TTS) or audio URL (for STT)
2. Script selects appropriate model
3. Sends request to fal.ai API
4. Returns audio URL (TTS) or transcription text (STT)

## Text-to-Speech Models

| Model | Notes |
|-------|-------|
| `fal-ai/minimax/speech-2.6-hd` | **Best quality** |
| `fal-ai/minimax/speech-2.6-turbo` | Fast, good quality |
| `fal-ai/elevenlabs/eleven-v3` | Natural voices |
| `fal-ai/chatterbox/multilingual` | Multi-language, fast |
| `fal-ai/kling-video/v1/tts` | For video sync |

## Text-to-Music Models

| Model | Notes |
|-------|-------|
| `fal-ai/minimax-music/v2` | **Best quality** |
| `fal-ai/minimax-music/v1.5` | Fast |
| `fal-ai/lyria2` | Google's model |
| `fal-ai/elevenlabs/music` | Song generation |
| `fal-ai/sonauto/v2` | Instrumental |
| `fal-ai/ace-step` | Short clips |
| `fal-ai/beatoven` | Background music |

## Speech-to-Text Models

| Model | Features | Speed |
|-------|----------|-------|
| `fal-ai/whisper` | Multi-language, timestamps | Fast |
| `fal-ai/elevenlabs/scribe` | Speaker diarization | Medium |

## Usage

### Text-to-Speech

```bash
bash /mnt/skills/user/fal-audio/scripts/text-to-speech.sh [options]
```

**Arguments:**
- `--text` - Text to convert to speech (required)
- `--model` - TTS model (defaults to `fal-ai/minimax/speech-2.6-turbo`)
- `--voice` - Voice ID or name (model-specific)

**Examples:**

```bash
# Basic TTS (fast, good quality)
bash /mnt/skills/user/fal-audio/scripts/text-to-speech.sh \
  --text "Hello, welcome to the future of AI."

# High quality with MiniMax HD
bash /mnt/skills/user/fal-audio/scripts/text-to-speech.sh \
  --text "This is premium quality speech." \
  --model "fal-ai/minimax/speech-2.6-hd"

# Natural voices with ElevenLabs
bash /mnt/skills/user/fal-audio/scripts/text-to-speech.sh \
  --text "Natural sounding voice generation" \
  --model "fal-ai/elevenlabs/eleven-v3"

# Multi-language TTS
bash /mnt/skills/user/fal-audio/scripts/text-to-speech.sh \
  --text "Bonjour, bienvenue dans le futur." \
  --model "fal-ai/chatterbox/multilingual"
```

### Speech-to-Text

```bash
bash /mnt/skills/user/fal-audio/scripts/speech-to-text.sh [options]
```

**Arguments:**
- `--audio-url` - URL of audio file to transcribe (required)
- `--model` - STT model (defaults to `fal-ai/whisper`)
- `--language` - Language code (optional, auto-detected)

**Examples:**

```bash
# Transcribe with Whisper
bash /mnt/skills/user/fal-audio/scripts/speech-to-text.sh \
  --audio-url "https://example.com/audio.mp3"

# Transcribe with speaker diarization
bash /mnt/skills/user/fal-audio/scripts/speech-to-text.sh \
  --audio-url "https://example.com/meeting.mp3" \
  --model "fal-ai/elevenlabs/scribe"

# Transcribe specific language
bash /mnt/skills/user/fal-audio/scripts/speech-to-text.sh \
  --audio-url "https://example.com/spanish.mp3" \
  --language "es"
```

## MCP Tool Alternative

### Text-to-Speech
```javascript
mcp__fal-ai__generate({
  modelId: "fal-ai/minimax/speech-2.6-turbo",
  input: {
    text: "Hello, welcome to the future of AI."
  }
})
```

### Speech-to-Text
```javascript
mcp__fal-ai__generate({
  modelId: "fal-ai/whisper",
  input: {
    audio_url: "https://example.com/audio.mp3"
  }
})
```

## Output

### Text-to-Speech Output
```
Generating speech...
Model: fal-ai/minimax/speech-2.6-turbo

Speech generated!

Audio URL: https://v3.fal.media/files/abc123/speech.mp3
Duration: 5.2s
```

### Speech-to-Text Output
```
Transcribing audio...
Model: fal-ai/whisper

Transcription complete!

Text: "Hello, this is the transcribed text from the audio file."
Duration: 12.5s
Language: en
```

## Present Results to User

### For TTS:
```
Here's the generated speech:

[Download audio](https://v3.fal.media/files/.../speech.mp3)

• Duration: 5.2s | Model: Maya TTS
```

### For STT:
```
Here's the transcription:

"Hello, this is the transcribed text from the audio file."

• Duration: 12.5s | Language: English
```

## Model Selection Guide

### Text-to-Speech

**MiniMax Speech 2.6 HD** (`fal-ai/minimax/speech-2.6-hd`)
- Best for: Premium quality requirements
- Quality: **Highest**
- Speed: Medium

**MiniMax Speech 2.6 Turbo** (`fal-ai/minimax/speech-2.6-turbo`)
- Best for: General use with good quality
- Quality: High
- Speed: Fast

**ElevenLabs v3** (`fal-ai/elevenlabs/eleven-v3`)
- Best for: Natural, realistic voices
- Quality: High
- Features: Many voice options

**Chatterbox Multilingual** (`fal-ai/chatterbox/multilingual`)
- Best for: Multi-language support
- Quality: Good
- Speed: Fast

### Text-to-Music

**MiniMax Music v2** (`fal-ai/minimax-music/v2`)
- Best for: High quality music generation
- Quality: **Highest**

**Lyria2** (`fal-ai/lyria2`)
- Best for: Google's music model
- Quality: High

### Speech-to-Text

**Whisper** (`fal-ai/whisper`)
- Best for: General transcription, timestamps
- Languages: 99+ languages
- Features: Word-level timestamps

**ElevenLabs Scribe** (`fal-ai/elevenlabs/scribe`)
- Best for: Multi-speaker recordings
- Features: Speaker diarization
- Quality: Professional-grade

## Troubleshooting

### Empty Audio
```
Error: Generated audio is empty

Check that your text is not empty and contains valid content.
```

### Unsupported Audio Format
```
Error: Audio format not supported

Supported formats: MP3, WAV, M4A, FLAC, OGG
Convert your audio to a supported format.
```

### Language Detection Failed
```
Warning: Could not detect language, defaulting to English

Specify the language explicitly with --language option.
```
