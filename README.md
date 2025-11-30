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

2. Sign the dylib (required for distributed plugins):

   ```bash
   codesign -s "Developer ID Application: Your Name (TEAMID)" ./libEmacs.dylib
   ```

   > **Note:** For local development/testing, you can skip signing. It's only required when distributing the plugin.

3. Install:
   ```bash
   osaurus tools install .
   ```

## Publishing

This repository includes a portable GitHub Actions workflow that automatically builds, signs, and releases your plugin.

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

#### 2. Export Your Apple Developer Certificate

To code sign the dylib for distribution, you need a Developer ID Application certificate:

1. Open Keychain Access on your Mac
2. Find your "Developer ID Application" certificate
3. Right-click → Export → Save as `.p12` with a password
4. Base64 encode it:
   ```bash
   base64 -i certificate.p12 | pbcopy
   ```

#### 3. Add Repository Secrets

Go to **Settings → Secrets and variables → Actions → Secrets** and add:

| Secret                                | Value                                                               |
| ------------------------------------- | ------------------------------------------------------------------- |
| `MINISIGN_SECRET_KEY`                 | Contents of `minisign.key` (the entire private key file)            |
| `MINISIGN_PUBLIC_KEY`                 | Public key string (second line of `.pub` file, starts with `RW...`) |
| `MINISIGN_PASSWORD`                   | Password you set when generating the key (leave empty if none)      |
| `DEVELOPER_ID_CERTIFICATE_P12_BASE64` | Base64-encoded `.p12` certificate (from step 2)                     |
| `DEVELOPER_ID_CERTIFICATE_PASSWORD`   | Password you set when exporting the certificate                     |

### Creating a Release

Tag and push a version:

```bash
git tag 1.0.0
git push origin 1.0.0
```

The workflow will automatically:

- ✅ Build the plugin for macOS arm64
- ✅ Code sign the dylib (if certificate secrets are configured)
- ✅ Sign artifact with minisign
- ✅ Create a GitHub Release with artifacts
- ✅ Generate the registry entry JSON in `release/` folder

### Submitting to the Registry

After the workflow completes, you'll find the registry entry at `release/<plugin-id>.json`. To submit:

1. Fork [dinoki-ai/osaurus-tools](https://github.com/dinoki-ai/osaurus-tools)
2. Copy `release/<plugin-id>.json` to `plugins/<plugin-id>.json` in your fork
3. If updating an existing plugin, merge the new version into the `versions` array
4. Create a PR to the upstream repository

### Manual Publishing

If you prefer to publish manually:

```bash
swift build -c release

# Sign the dylib (REQUIRED for distributed plugins)
codesign --force --options runtime --timestamp \
  --sign "Developer ID Application: Your Name (TEAMID)" \
  .build/release/libEmacs.dylib

mkdir dist && cp .build/release/libEmacs.dylib manifest.json dist/
cd dist && zip -r ../osaurus.emacs-1.0.0.zip .
minisign -Slm osaurus.emacs-1.0.0.zip -s minisign.key
```

Then upload to GitHub Releases and submit a PR to the registry.
