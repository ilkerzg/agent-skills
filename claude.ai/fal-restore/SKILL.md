---
name: fal-restore
description: Restore and fix image quality — deblur, denoise, dehaze, fix faces, restore documents. Use when the user requests "Fix blurry image", "Remove noise", "Fix face", "Restore photo", "Enhance document", "Deblur", "Denoise".
metadata:
  author: fal-ai
  version: "1.0.0"
---

# fal-restore

Restore and enhance image quality using AI — fix blur, noise, haze, faces, and documents.

## Scripts

| Script | Purpose |
|--------|---------|
| `restore.sh` | Restore an image (deblur, denoise, dehaze, fix-face, document) |

## Usage

### Deblur
```bash
./scripts/restore.sh --image-url "https://example.com/blurry.jpg" --operation deblur
```

### Denoise
```bash
./scripts/restore.sh --image-url "https://example.com/noisy.jpg" --operation denoise
```

### Fix Face
```bash
./scripts/restore.sh --image-url "https://example.com/bad-face.jpg" --operation fix-face
```

### Restore Document
```bash
./scripts/restore.sh --image-url "https://example.com/scan.jpg" --operation document
```

## Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `--image-url` | URL of image to restore | Yes |
| `--operation` | deblur, denoise, dehaze, fix-face, document | Yes |
| `--model` / `-m` | Override model endpoint | No |
| `--fidelity` | For fix-face: 0.0-1.0 (0=max quality, 1=most faithful) | No |

## Recommended Models

| Operation | Model | Notes |
|-----------|-------|-------|
| Deblur | `fal-ai/nafnet/deblur` | NAFNet. Motion blur removal. |
| Denoise | `fal-ai/nafnet/denoise` | NAFNet. Noise/grain removal. |
| Dehaze | `fal-ai/mix-dehaze-net` | MixDehazer. Haze/fog removal. |
| Fix face | `fal-ai/codeformer` | CodeFormer. Controllable face restoration. |
| Document restore | `fal-ai/docres` | DocRes. Deshadow, deblur, binarize. |
| Document dewarp | `fal-ai/docres/dewarp` | DocRes. Fix curved/bent documents. |
