# AGENTS.md

This file provides guidance to AI coding agents (Claude Code, Cursor, Copilot, etc.) when working with code in this repository.

## Repository Overview

A collection of skills for Claude.ai and Claude Code for working with fal.ai AI generation. Skills are packaged instructions and scripts that extend Claude's capabilities.

## Creating a New Skill

### Directory Structure

```
skills/
  claude.ai/
    {skill-name}/           # kebab-case directory name
      SKILL.md              # Required: skill definition
      scripts/              # Required: executable scripts
        {script-name}.sh    # Bash scripts (preferred)
    {skill-name}.zip        # Required: packaged for distribution
```

### Naming Conventions

- **Skill directory**: `kebab-case` (e.g., `fal-generate`, `fal-workflow`)
- **SKILL.md**: Always uppercase, always this exact filename
- **Scripts**: `kebab-case.sh` (e.g., `generate.sh`, `train-lora.sh`)
- **Zip file**: Must match directory name exactly: `{skill-name}.zip`

### SKILL.md Format

```markdown
---
name: {skill-name}
description: {One sentence describing when to use this skill. Include trigger phrases like "Generate image", "Create video", etc.}
---

# {Skill Title}

{Brief description of what the skill does.}

## How It Works

{Numbered list explaining the skill's workflow}

## Usage

```bash
bash /mnt/skills/user/{skill-name}/scripts/{script}.sh [args]
```

**Arguments:**
- `arg1` - Description (defaults to X)

**Examples:**
{Show 2-3 common usage patterns}

## Output

{Show example output users will see}

## Present Results to User

{Template for how Claude should format results when presenting to users}

## Troubleshooting

{Common issues and solutions, especially network/permissions errors}
```

### Best Practices for Context Efficiency

Skills are loaded on-demand — only the skill name and description are loaded at startup. The full `SKILL.md` loads into context only when the agent decides the skill is relevant. To minimize context usage:

- **Keep SKILL.md under 500 lines** — put detailed reference material in separate files
- **Write specific descriptions** — helps the agent know exactly when to activate the skill
- **Use progressive disclosure** — reference supporting files that get read only when needed
- **Prefer scripts over inline code** — script execution doesn't consume context (only output does)
- **File references work one level deep** — link directly from SKILL.md to supporting files

### Script Requirements

- Use `#!/bin/bash` shebang
- Use `set -e` for fail-fast behavior
- Write status messages to stderr: `echo "Message" >&2`
- Write machine-readable output (JSON) to stdout
- Include a cleanup trap for temp files
- Reference the script path as `/mnt/skills/user/{skill-name}/scripts/{script}.sh`
- Require `FAL_KEY` environment variable for fal.ai API authentication

### Environment Requirements

fal.ai skills require:
- `FAL_KEY` environment variable set with valid API key
- Network access to `*.fal.ai` domains

### Creating the Zip Package

After creating or updating a skill:

```bash
cd skills/claude.ai
zip -r {skill-name}.zip {skill-name}/
```

### End-User Installation

Document these two installation methods for users:

**Claude Code:**
```bash
cp -r skills/claude.ai/{skill-name} ~/.claude/skills/
```

**claude.ai:**
Add the skill to project knowledge or paste SKILL.md contents into the conversation.

If the skill requires network access, instruct users to add required domains at `claude.ai/settings/capabilities`:
- `*.fal.ai` - for fal.ai API access

---

## Creating fal.ai Workflows

### Workflow JSON Structure

```json
{
  "name": "workflow-slug",
  "title": "Human Readable Title",
  "contents": {
    "name": "workflow",
    "nodes": { ... },
    "output": { ... },
    "schema": { "input": { ... }, "output": { ... } },
    "version": "1",
    "metadata": { "input": { "position": { "x": 0, "y": 0 } } }
  },
  "is_public": true,
  "user_id": "",
  "user_nickname": "",
  "created_at": ""
}
```

### Node Types

**Run Node:**
```json
"node-id": {
  "type": "run",
  "id": "node-id",
  "depends": ["input", "other-node"],
  "app": "fal-ai/model-id",
  "input": { "param": "$other-node.output" },
  "metadata": { "position": { "x": 500, "y": 0 } }
}
```

**Display/Output Node:**
```json
"output": {
  "type": "display",
  "id": "output",
  "depends": ["node-a", "node-b"],
  "input": {},
  "metadata": { "position": { "x": 2000, "y": 0 } },
  "fields": { "result": "$node-a.video.url" }
}
```

### CRITICAL: Variable Reference Rules

**⚠️ NO STRING INTERPOLATION - NEVER mix text with variables!**

```json
// ❌ WRONG - NEVER DO THIS:
"prompt": "Create image of $input.subject in $input.style"
"prompt": "Storyboard: $node.output\nStyle: $other.output"

// ✅ CORRECT - Variable must be the ENTIRE value:
"prompt": "$input.prompt"
"prompt": "$node.output"
```

**To combine multiple values, use Merge Text node:**
```json
"merge-context": {
  "type": "run",
  "id": "merge-context",
  "depends": ["node-a", "node-b"],
  "app": "fal-ai/merge-text",
  "input": {
    "texts": ["$node-a.output", "$node-b.output"],
    "separator": "\n\n"
  },
  "metadata": { "position": { "x": 400, "y": 0 } }
}

// Then reference the merged output:
"next-node": {
  "depends": ["merge-context"],
  "input": { "prompt": "$merge-context.output" }
}
```

### Dependency Rules

1. **Every `$node-id.xxx` reference MUST have that node in `depends`**
2. **Nodes using `$input.xxx` MUST have `depends: ["input"]`**
3. **Output node's `depends` must include ALL nodes referenced in `fields`**
4. **Node `id` must match the object key**

### Output Reference Types

| Model Type | Reference |
|------------|-----------|
| LLM | `$node.output` |
| Image Gen (array) | `$node.images.0.url` |
| Image Process (single) | `$node.image.url` |
| Video | `$node.video.url` |
| Music | `$node.audio_file.url` |
| Frame Extract | `$node.frame.url` |

### Default Models

| Task | App ID |
|------|--------|
| Image generation | `fal-ai/nano-banana-pro` |
| Image editing | `fal-ai/nano-banana-pro/edit` |
| Video (I2V) | `fal-ai/bytedance/seedance/v1.5/pro/image-to-video` |
| Text LLM | `openrouter/router` with `google/gemini-2.5-flash` |
| Vision LLM | `openrouter/router/vision` with `google/gemini-3-pro-preview` |
| Video merge | `fal-ai/ffmpeg-api/merge-videos` |
| Audio+Video merge | `fal-ai/ffmpeg-api/merge-audio-video` |
| Frame extract | `fal-ai/ffmpeg-api/extract-frame` |
| Upscale | `fal-ai/seedvr/upscale/image` |

### Schema Input Fields

```json
"schema": {
  "input": {
    "field_name": {
      "name": "field_name",
      "label": "Display Label",
      "type": "string",
      "description": "Help text",
      "required": true,
      "ui": { "placeholder": "Enter..." },
      "modelId": "first-consuming-node"  // REQUIRED
    }
  }
}
```

### Pre-Output Checklist

- [ ] Every `$node.xxx` has matching `depends` entry
- [ ] Every node `id` matches object key
- [ ] **NO string interpolation** - variables are entire values only
- [ ] Input schema has `modelId` for each field
- [ ] Output depends on ALL referenced nodes
- [ ] Nodes using `$input.xxx` have `depends: ["input"]`
