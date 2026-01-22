---
name: fal-image-edit
description: Edit images using AI on fal.ai. Style transfer, object removal, background changes, and more. Use when the user requests "Edit image", "Remove object", "Change background", "Apply style", or similar image editing tasks.
metadata:
  author: fal-ai
  version: "1.0.0"
---

# fal.ai Image Edit

Edit images using AI: style transfer, object removal, background changes, and more.

## How It Works

1. User provides image URL and editing instructions
2. Script selects appropriate model
3. Sends request to fal.ai API
4. Returns edited image URL

## Recommended Models

| Model | Best For |
|-------|----------|
| `fal-ai/nano-banana-pro` | **Best overall** - T2I and editing |
| `fal-ai/flux-kontext` | Background change, context-aware editing |
| `fal-ai/flux/dev/image-to-image` | Style transfer |
| `fal-ai/bria/fibo-edit` | Object removal |
| `fal-ai/flux/dev/inpainting` | Masked inpainting |

## Supported Operations

| Operation | Model | Description |
|-----------|-------|-------------|
| General Edit | `fal-ai/nano-banana-pro` | Best quality edits |
| Style Transfer | `fal-ai/flux/dev/image-to-image` | Apply style to image |
| Object Removal | `fal-ai/bria/fibo-edit` | Remove objects from image |
| Background Change | `fal-ai/flux-kontext` | Change/replace background |
| Inpainting | `fal-ai/flux/dev/inpainting` | Fill in masked areas |

## Usage

```bash
bash /mnt/skills/user/fal-image-edit/scripts/edit-image.sh [options]
```

**Arguments:**
- `--image-url` - URL of image to edit (required)
- `--prompt` - Description of desired edit (required)
- `--operation` - Edit operation: `style`, `remove`, `background`, `inpaint` (default: `style`)
- `--mask-url` - URL of mask image (required for inpainting/removal)
- `--strength` - Edit strength 0.0-1.0 (default: 0.75)

**Examples:**

```bash
# Style transfer
bash /mnt/skills/user/fal-image-edit/scripts/edit-image.sh \
  --image-url "https://example.com/photo.jpg" \
  --prompt "Convert to anime style" \
  --operation style

# Remove object
bash /mnt/skills/user/fal-image-edit/scripts/edit-image.sh \
  --image-url "https://example.com/photo.jpg" \
  --prompt "Remove the person on the left" \
  --operation remove

# Change background
bash /mnt/skills/user/fal-image-edit/scripts/edit-image.sh \
  --image-url "https://example.com/portrait.jpg" \
  --prompt "Place in a tropical beach setting" \
  --operation background

# Inpainting with mask
bash /mnt/skills/user/fal-image-edit/scripts/edit-image.sh \
  --image-url "https://example.com/photo.jpg" \
  --mask-url "https://example.com/mask.png" \
  --prompt "Fill with flowers" \
  --operation inpaint
```

## MCP Tool Alternative

### General Edit (Recommended)
```javascript
mcp__fal-ai__generate({
  modelId: "fal-ai/nano-banana-pro",
  input: {
    image_url: "https://example.com/photo.jpg",
    prompt: "Make the sky more dramatic with sunset colors"
  }
})
```

### Style Transfer
```javascript
mcp__fal-ai__generate({
  modelId: "fal-ai/flux/dev/image-to-image",
  input: {
    image_url: "https://example.com/photo.jpg",
    prompt: "Convert to anime style",
    strength: 0.75
  }
})
```

### Object Removal
```javascript
mcp__fal-ai__generate({
  modelId: "bria/fibo-edit",
  input: {
    image_url: "https://example.com/photo.jpg",
    prompt: "Remove the person on the left"
  }
})
```

### Background Change (Kontext)
```javascript
mcp__fal-ai__generate({
  modelId: "fal-ai/flux-kontext",
  input: {
    image_url: "https://example.com/portrait.jpg",
    prompt: "Place the subject in a tropical beach setting"
  }
})
```

### Inpainting
```javascript
mcp__fal-ai__generate({
  modelId: "fal-ai/flux/dev/inpainting",
  input: {
    image_url: "https://example.com/photo.jpg",
    mask_url: "https://example.com/mask.png",
    prompt: "Fill with flowers"
  }
})
```

## Output

```
Editing image...
Model: fal-ai/flux/dev/image-to-image
Operation: style transfer

Edit complete!

Image URL: https://v3.fal.media/files/abc123/edited.png
Dimensions: 1024x1024
```

JSON output:
```json
{
  "images": [
    {
      "url": "https://v3.fal.media/files/abc123/edited.png",
      "width": 1024,
      "height": 1024
    }
  ]
}
```

## Present Results to User

```
Here's your edited image:

![Edited Image](https://v3.fal.media/files/...)

• 1024×1024 | Operation: Style Transfer
```

## Model Selection Guide

### General Editing (Recommended)
**Nano Banana Pro** (`fal-ai/nano-banana-pro`)
- **Best overall** for image editing and T2I
- High quality, versatile
- Good for most editing tasks

### Style Transfer
**FLUX Image-to-Image** (`fal-ai/flux/dev/image-to-image`)
- Best for: Artistic style changes
- Strength: 0.3-0.5 for subtle, 0.7-0.9 for dramatic

### Object Removal
**Bria Fibo Edit** (`fal-ai/bria/fibo-edit`)
- Best for: Removing objects, people, text
- Works without masks (AI detects objects from prompt)

### Background Change
**FLUX Kontext** (`fal-ai/flux-kontext`)
- Best for: Placing subjects in new environments
- Preserves subject identity well

### Inpainting
**FLUX Inpainting** (`fal-ai/flux/dev/inpainting`)
- Best for: Precise edits with mask control
- Requires binary mask (white = edit area)

## Mask Tips

For inpainting and some removal tasks:
- White pixels = areas to edit
- Black pixels = areas to preserve
- Use PNG format with transparency or solid colors
- Feathered edges create smoother transitions

## Troubleshooting

### Edit Too Subtle
```
The edit is barely visible.

Increase the strength parameter:
--strength 0.85
```

### Edit Too Dramatic
```
The edit changed too much of the image.

Decrease the strength parameter:
--strength 0.3
```

### Object Not Removed
```
The object wasn't fully removed.

Tips:
1. Be more specific in the prompt
2. Try using an explicit mask
3. Use the inpainting model for precise control
```

### Background Artifacts
```
The new background has artifacts around the subject.

Tips:
1. Use a cleaner source image
2. Try FLUX Kontext which handles edges better
3. Adjust the strength for smoother blending
```
