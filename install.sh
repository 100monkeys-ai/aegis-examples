#!/usr/bin/env bash
# Copyright (c) 2026 100monkeys.ai
# SPDX-License-Identifier: AGPL-3.0
#
# install.sh — One-shot AEGIS installer for Ubuntu
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

# ── Sanity checks ─────────────────────────────────────────────────────────────
[[ "$(uname -s)" == "Linux" ]] || die "This script targets Linux (Ubuntu). Detected: $(uname -s)"

if ! command -v apt-get &>/dev/null; then
    die "apt-get not found. This script requires an Ubuntu/Debian system."
fi

# ── Step 1: System dependencies ───────────────────────────────────────────────
info "Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y --no-install-recommends \
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates

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
cargo install aegis-orchestrator --locked
success "aegis installed: $(aegis --version)"

# Ensure the cargo bin dir is on PATH for the aegis up call and future sessions.
CARGO_BIN="${CARGO_HOME:-$HOME/.cargo}/bin"
if [[ ":$PATH:" != *":$CARGO_BIN:"* ]]; then
    export PATH="$CARGO_BIN:$PATH"
fi

# Persist to shell profile so it survives reboots.
SHELL_RC="$HOME/.bashrc"
if [[ -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.zshrc"
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
