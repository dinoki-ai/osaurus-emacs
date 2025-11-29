# Emacs MCP Plugin

An Osaurus plugin that enables executing Emacs Lisp code in a running Emacs instance via `emacsclient`.

Based on [emacs-mcp-server](https://github.com/vivekhaldar/emacs-mcp-server).

## Prerequisites

- Emacs with server mode enabled (`M-x server-start` or add `(server-start)` to your init file)
- `emacsclient` available (auto-detected or specify path)

## Tools

### `execute_emacs_lisp_code`

Execute Emacs Lisp code in a running Emacs instance.

**Parameters:**

- `code` (required): The Emacs Lisp code to execute
- `emacsclient_path` (optional): Path to emacsclient binary. Auto-detected if not provided.

**Example:**

```json
{
  "code": "(buffer-name)",
  "emacsclient_path": "/opt/homebrew/bin/emacsclient"
}
```

## Development

1. Build:
   ```bash
   swift build -c release
   cp .build/release/libEmacs.dylib ./libEmacs.dylib
   ```
2. Install:
   ```bash
   osaurus tools install .
   ```

## Publishing (Automated)

This repository includes a portable GitHub Actions workflow that automatically builds, signs, releases, and registers your plugin.

### Using This Workflow for Your Own Plugin

The workflow at `.github/workflows/release.yml` is designed to be easily reusable. To use it for your own Osaurus plugin:

1. Copy the workflow file to your repository
2. Update the configuration section at the top:

```yaml
env:
  PLUGIN_ID: your.plugin.id # Must match manifest.json
  PLUGIN_NAME: Your Plugin # Display name
  PLUGIN_DESCRIPTION: What it does
  DYLIB_NAME: YourLibrary # Without lib prefix and .dylib extension
  LICENSE: MIT
  MIN_MACOS: "13.0"
  MIN_OSAURUS: "0.5.0"
  REGISTRY_REPO: dinoki-ai/osaurus-tools
```

### Setup (One-time)

#### 1. Generate a Minisign Key Pair

```bash
brew install minisign
minisign -G -p minisign.pub -s minisign.key
```

This creates:

- `minisign.pub` - Public key (share this)
- `minisign.key` - Private key (keep secret!)

#### 2. Add Repository Secrets

Go to **Settings → Secrets and variables → Actions → Secrets** and add:

| Secret                | Value                                                                                                             |
| --------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `REGISTRY_PAT`        | Personal Access Token with `repo` scope for [dinoki-ai/osaurus-tools](https://github.com/dinoki-ai/osaurus-tools) |
| `MINISIGN_SECRET_KEY` | Contents of `minisign.key` (the entire private key file)                                                          |
| `MINISIGN_PUBLIC_KEY` | Public key string (second line of `.pub` file, starts with `RW...`)                                               |
| `MINISIGN_PASSWORD`   | Password you set when generating the key (leave empty if none)                                                    |

### Creating a Release

Tag and push a version:

```bash
git tag 1.0.0
git push origin 1.0.0
```

The workflow will automatically:

- ✅ Build the plugin for macOS arm64
- ✅ Sign with minisign
- ✅ Create a GitHub Release with artifacts
- ✅ Open a PR to the [osaurus-tools registry](https://github.com/dinoki-ai/osaurus-tools)

### Manual Publishing

If you prefer to publish manually:

```bash
swift build -c release
mkdir dist && cp .build/release/libEmacs.dylib manifest.json dist/
cd dist && zip -r ../osaurus.emacs-1.0.0.zip .
minisign -Slm osaurus.emacs-1.0.0.zip -s minisign.key
```

Then upload to GitHub Releases and submit a PR to the registry.
