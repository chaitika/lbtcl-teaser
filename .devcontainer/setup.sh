#!/usr/bin/env bash
# One-time container setup: install Bitcoin Core, write regtest config,
# install the start-node + banner helpers.
set -euo pipefail

BITCOIN_VERSION="29.0"
ARCH="$(uname -m)"

# Checksums from https://bitcoincore.org/bin/bitcoin-core-29.0/SHA256SUMS
case "$ARCH" in
  x86_64)  SHA256="a681e4f6ce524c338a105f214613605bac6c33d58c31dc5135bbc02bc458bb6c" ;;
  aarch64) SHA256="7922ac99363dd28f79e57ef7098581fd48ebd1119b412b07e73b1fd19fd0443f" ;;
  *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;;
esac

TARBALL="bitcoin-${BITCOIN_VERSION}-${ARCH}-linux-gnu.tar.gz"
curl -fsSL -o "/tmp/${TARBALL}" "https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_VERSION}/${TARBALL}"
echo "${SHA256}  /tmp/${TARBALL}" | sha256sum -c -

sudo tar -xzf "/tmp/${TARBALL}" -C /usr/local --strip-components=1 \
  "bitcoin-${BITCOIN_VERSION}/bin/bitcoind" \
  "bitcoin-${BITCOIN_VERSION}/bin/bitcoin-cli"
rm "/tmp/${TARBALL}"

mkdir -p "$HOME/.bitcoin"
cat > "$HOME/.bitcoin/bitcoin.conf" <<'EOF'
regtest=1
server=1
txindex=1

[regtest]
fallbackfee=0.0001
EOF

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
sudo install -m 0755 "${SCRIPT_DIR}/start-node" /usr/local/bin/start-node
sudo install -m 0755 "${SCRIPT_DIR}/node-banner" /usr/local/bin/node-banner

# Show the status banner in every new interactive terminal.
echo 'node-banner' >> "$HOME/.bashrc"

echo "Setup complete: bitcoind $(bitcoind --version | head -1)"
