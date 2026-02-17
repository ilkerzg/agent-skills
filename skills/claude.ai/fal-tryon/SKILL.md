---
name: fal-tryon
description: Virtual try-on — see how clothes look on a person. Use when the user requests "Try on clothes", "Virtual try-on", "How does this look on me", "Fashion try-on", "Garment transfer".
metadata:
  author: fal-ai
  version: "1.0.0"
---

# fal-tryon

Virtual try-on — transfer garments onto person photos using fal.ai models.

## Scripts

| Script | Purpose |
|--------|---------|
| `tryon.sh` | Apply a garment onto a person photo |

## Usage

### Basic Try-On
```bash
./scripts/tryon.sh --person-url "https://example.com/person.jpg" --garment-url "https://example.com/dress.jpg"
```

### With Garment Type
```bash
./scripts/tryon.sh --person-url "https://example.com/person.jpg" --garment-url "https://example.com/jacket.jpg" --type top
```

## Arguments

| Argument | Description | Required |
|----------|-------------|----------|
| `--person-url` | URL of person/model photo | Yes |
| `--garment-url` | URL of garment/clothing image | Yes |
| `--type` | Garment type: top, bottom, full-body, dress | No (auto-detect) |
| `--model` / `-m` | Model endpoint | No (default: fal-ai/fashn/tryon/v1.5) |
| `--quality` | speed, balanced, quality | No (default: balanced) |

## Recommended Models

| Use Case | Model | Notes |
|----------|-------|-------|
| Best quality | `fal-ai/fashn/tryon/v1.5` | FASHN v1.5. 3 quality modes. |
| Alternative | `fal-ai/cat-vton` | CatVTON. Good results. |
| Kling-based | `fal-ai/kling/v1-5/kolors-virtual-try-on` | Kolors Virtual Try-On. |

## Tips

- Person photo should show clear full or upper body
- Garment image works best on plain/white background (flat-lay or mannequin)
- Remove garment background first for best results
- Specify garment type (top/bottom/dress) for more accurate placement
