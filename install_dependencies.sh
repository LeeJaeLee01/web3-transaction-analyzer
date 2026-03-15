#!/usr/bin/env bash
# Cài đặt thư viện cần thiết cho toàn bộ source web3-transaction-analyzer
# (track-wallets, integrate-exchange-API, get-price-token, detect-protocol)

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=== web3-transaction-analyzer: install dependencies ==="

# Python 3.11 recommended
if command -v python3.11 &>/dev/null; then
    PYTHON=python3.11
elif command -v python3 &>/dev/null; then
    PYTHON=python3
else
    echo "Python 3 not found. Please install Python 3.11 or 3.10+."
    exit 1
fi

# Optional: tạo virtualenv nếu chưa có
if [ -z "$VIRTUAL_ENV" ] && [ ! -d ".venv" ]; then
    echo "Creating .venv..."
    $PYTHON -m venv .venv
    echo "Activate with: source .venv/bin/activate  (Linux/macOS)  or  .venv\\Scripts\\activate  (Windows)"
fi

# Kích hoạt venv nếu có
if [ -d ".venv" ]; then
    if [ -f ".venv/bin/activate" ]; then
        source .venv/bin/activate
    elif [ -f ".venv/Scripts/activate" ]; then
        source .venv/Scripts/activate
    fi
fi

# Cài từ requirements.txt
if [ -f "requirements.txt" ]; then
    echo "Installing from requirements.txt..."
    pip install --upgrade pip
    pip install -r requirements.txt
    echo "Done."
else
    echo "requirements.txt not found in $SCRIPT_DIR"
    exit 1
fi

echo ""
echo "Modules in this repo:"
echo "  - track-wallets/        (multi-chain wallet tracking)"
echo "  - integrate-exchange-API/ (exchange API integration)"
echo "  - get-price-token/      (token/asset price oracles)"
echo "  - detect-protocol/      (transaction decoding / protocol detection)"
echo ""
echo "Code depends on rotkehlchen types/db/utils; for full run use rotki env or copy missing modules."
