# OpenTofu

**OpenTofu** can be installed via **Homebrew** on macOS, as it is supported in the Homebrew package manager.

### Steps to Install OpenTofu with Homebrew
1. **Ensure Homebrew is Installed:**

2. **Install OpenTofu:**
   Install OpenTofu:
   ```bash
   brew install opentofu
   ```
   > Returns
   ```powershell
   opentofu 1.8.2 is already installed but outdated (so it will be upgraded).
   ==> Downloading https://ghcr.io/v2/homebrew/core/opentofu/manifests/1.9.0
   ############################################################################################################ 100.0%
   ==> Fetching opentofu
   ==> Downloading https://ghcr.io/v2/homebrew/core/opentofu/blobs/sha256:b6c1fcc307e7c4d8cf2f5cd0daf1496a05a16cce15c1
   ############################################################################################################ 100.0%
   ==> Upgrading opentofu
     1.8.2 -> 1.9.0 
   ==> Pouring opentofu--1.9.0.arm64_sequoia.bottle.tar.gz
   🍺  /opt/homebrew/Cellar/opentofu/1.9.0: 7 files, 78.2MB
   ==> Running `brew cleanup opentofu`...
   Disable this behaviour by setting HOMEBREW_NO_INSTALL_CLEANUP.
   Hide these hints with HOMEBREW_NO_ENV_HINTS (see `man brew`).
   Removing: /opt/homebrew/Cellar/opentofu/1.8.2... (7 files, 78.0MB)
   Removing: /Users/valiha/Library/Caches/Homebrew/opentofu_bottle_manifest--1.8.2... (9.3KB)
   ```

4. **Verify the Installation:**
   Confirm that OpenTofu is installed and accessible:
   ```bash
   tofu --version
   ```
   > Returns
   ```powershell
   OpenTofu v1.9.0
   on darwin_arm64
   ```

   If installed correctly, this will display the version of OpenTofu.

5. **Keep OpenTofu Updated:**
   To update OpenTofu in the future, use:
   ```bash
   brew update
   brew upgrade opentofu
   ```

---

If OpenTofu is not available directly in Homebrew or the tap, you can download the binary from the [OpenTofu GitHub releases page](https://github.com/opentofu) and place it in a directory in your `$PATH`.
