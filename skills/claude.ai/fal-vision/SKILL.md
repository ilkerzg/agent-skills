---
name: fal-vision
description: Analyze images using AI — segment objects, detect objects, extract text (OCR), describe images, ask questions about images. Use when the user requests "Segment image", "Detect objects", "OCR", "Extract text from image", "Describe image", "What's in this image", "Image analysis".
metadata:
  author: fal-ai
  version: "1.0.0"
---

# fal-vision

Analyze and understand images using fal.ai vision models — segmentation, detection, OCR, captioning, and visual QA.

## Scripts

| Script | Purpose |
|--------|---------|
| `analyze.sh` | Analyze an image (segment, detect, OCR, describe, QA) |

## Usage

### Segment Objects
```bash
./scripts/analyze.sh --image-url "https://example.com/photo.jpg" --operation segment --query "the red car"
```

### Detect Objects
```bash
./scripts/analyze.sh --image-url "https://example.com/photo.jpg" --operation detect
```

### Extract Text (OCR)
```bash
./scripts/analyze.sh --image-url "https://example.com/document.jpg" --operation ocr
```

### Describe Image
```bash
./scripts/analyze.sh --image-url "https://example.com/photo.jpg" --operation describe
```

### Visual QA
```bash
./scripts/analyze.sh --image-url "https://example.com/photo.jpg" --operation qa --query "How many people are in this image?"
```

## Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `--image-url` | URL of image to analyze | Yes |
| `--operation` | segment, detect, ocr, describe, qa | Yes |
| `--query` / `-q` | Text prompt for segment/qa operations | For segment/qa |
| `--model` / `-m` | Override model endpoint | No |

## Recommended Models

| Operation | Model | Notes |
|-----------|-------|-------|
| Segmentation | `fal-ai/sam-3/image` | SAM 3. Best segmentation, text/point/box prompts. |
| Auto-segment | `fal-ai/sam2/auto-segment` | SAM 2. Segment everything automatically. |
| Object detection | `fal-ai/florence-2-large/object-detection` | Florence-2. Standard detection. |
| Open vocab detection | `fal-ai/florence-2-large/open-vocabulary-detection` | Florence-2. Detect any object by description. |
| OCR (general) | `fal-ai/florence-2-large/ocr` | Florence-2 OCR. General text extraction. |
| OCR (documents) | `fal-ai/got-ocr/v2` | GOT OCR v2. Best for tables, formulas, documents. |
| Describe | `fal-ai/florence-2-large/detailed-caption` | Florence-2. Detailed captioning. |
| Visual QA | `fal-ai/llava-next` | LLaVA v1.6. Best for detailed image questions. |
| Lightweight QA | `fal-ai/moondream2` | Moondream. Fast, multi-task vision. |
