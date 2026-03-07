#!/usr/bin/env bash
# Copyright (c) 2026 100monkeys.ai
# SPDX-License-Identifier: AGPL-3.0
#
# install.sh — One-shot AEGIS installer for Ubuntu / macOS
#
# Installs the Rust toolchain (if absent), builds and installs the
# aegis-orchestrator CLI via cargo, then runs `aegis up` to bring the full
# local stack online.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/100monkeys-ai/aegis-examples/main/install.sh | bash
#   # or
#   chmod +x install.sh && ./install.sh

set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

info()    { echo -e "${CYAN}${BOLD}[aegis]${RESET} $*"; }
success() { echo -e "${GREEN}${BOLD}[aegis]${RESET} $*"; }
die()     { echo -e "${RED}${BOLD}[aegis] ERROR:${RESET} $*" >&2; exit 1; }

# ── Detect OS ─────────────────────────────────────────────────────────────────
OS="$(uname -s)"
case "$OS" in
    Linux)  PLATFORM="linux" ;;
    Darwin) PLATFORM="macos" ;;
    *)      die "Unsupported OS: $OS. This script supports Ubuntu/Debian and macOS." ;;
esac
info "Detected platform: $PLATFORM"

# ── Step 1: System dependencies ───────────────────────────────────────────────
info "Installing system dependencies..."

if [[ "$PLATFORM" == "linux" ]]; then
    command -v apt-get &>/dev/null \
        || die "apt-get not found. Linux installs require Ubuntu / Debian."
    sudo apt-get update -qq
    sudo apt-get install -y --no-install-recommends \
        curl \
        build-essential \
        pkg-config \
        libssl-dev \
        ca-certificates

elif [[ "$PLATFORM" == "macos" ]]; then
    # Ensure Homebrew is present
    if ! command -v brew &>/dev/null; then
        info "Homebrew not found — installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add brew to PATH for Apple Silicon or Intel
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    fi
    brew install openssl pkg-config
fi

# ── Step 2: Rust / Cargo ──────────────────────────────────────────────────────
if command -v cargo &>/dev/null; then
    success "Rust toolchain already installed ($(cargo --version)). Skipping."
else
    info "Installing Rust via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
        | sh -s -- -y --no-modify-path --profile minimal
    success "Rust installed."
fi

# Make cargo available in the current shell whether it was just installed or
# already present in a non-login environment (e.g. piped bash).
export PATH="${CARGO_HOME:-$HOME/.cargo}/bin:$PATH"

cargo --version &>/dev/null || die "cargo not found on PATH after install. Try: source \$HOME/.cargo/env"

# ── Step 3: Install aegis-orchestrator ────────────────────────────────────────
info "Installing aegis-orchestrator CLI via cargo..."
cargo install aegis-orchestrator --version 0.7.0-pre-alpha
success "aegis installed: $(aegis --version)"

# Ensure the cargo bin dir is on PATH for the aegis up call and future sessions.
CARGO_BIN="${CARGO_HOME:-$HOME/.cargo}/bin"
if [[ ":$PATH:" != *":$CARGO_BIN:"* ]]; then
    export PATH="$CARGO_BIN:$PATH"
fi

# Persist to shell profile so it survives reboots.
# macOS defaults to zsh; Linux defaults to bash.
if [[ "$PLATFORM" == "macos" ]]; then
    SHELL_RC="$HOME/.zshrc"
else
    SHELL_RC="$HOME/.bashrc"
    [[ -f "$HOME/.zshrc" ]] && SHELL_RC="$HOME/.zshrc"
fi
if ! grep -q 'cargo/bin' "$SHELL_RC" 2>/dev/null; then
    echo '' >> "$SHELL_RC"
    echo '# Added by AEGIS installer' >> "$SHELL_RC"
    echo "export PATH=\"\$HOME/.cargo/bin:\$PATH\"" >> "$SHELL_RC"
    info "Added ~/.cargo/bin to PATH in $SHELL_RC"
fi

# ── Step 4: Start the AEGIS stack ─────────────────────────────────────────────
info "Starting AEGIS stack (aegis up)..."
aegis up

success "AEGIS is ready! Run 'aegis --help' to get started."
