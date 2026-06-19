#!/usr/bin/env bash
# Deploy the Earmark contracts and wire them up against real USDC.
#
# Usage: ./scripts/deploy.sh [testnet|mainnet] [key-alias]
#   Default key alias: deployer  (stellar keys generate deployer --network testnet)
#
# What it does:
#   1. Builds the WASM.
#   2. Resolves the USDC Stellar Asset Contract (SAC) address for the network,
#      deploying the SAC wrapper if it doesn't exist yet (testnet).
#   3. Deploys registry, attestation, escrow, streaming.
#   4. Initializes each contract and wires escrow -> {token, registry, attestation}.
#   5. Writes frontend/.env.local.
set -euo pipefail

NETWORK="${1:-testnet}"
KEY="${2:-deployer}"

if [[ "$NETWORK" == "testnet" ]]; then
  RPC_URL="https://soroban-testnet.stellar.org"
  PASSPHRASE="Test SDF Network ; September 2015"
  USDC_ISSUER="GBBD47IF6LWK7P7MDEVSCWR7DPUWV3NY3DTQEVFL4NAT4AQH3ZLLFLA5"
else
  RPC_URL="https://soroban-rpc.stellar.org"
  PASSPHRASE="Public Global Stellar Network ; September 2015"
  USDC_ISSUER="GA5ZSEJYB37JRC5AVCIA5MOP4RHTM335X2KGX3IHOJAPP5RE34K4KZVN"  # Circle USDC mainnet issuer
fi

USDC="USDC:${USDC_ISSUER}"
ADMIN=$(stellar keys address "$KEY")

# Testnet RPC occasionally drops HTTP/2 streams; retry individual commands so a single
# blip doesn't force a full redeploy.
retry() {
  local n=0
  until "$@"; do
    n=$((n + 1))
    if [[ $n -ge 5 ]]; then echo "  ✗ failed after $n attempts: $*" >&2; return 1; fi
    echo "  … retry $n: $*" >&2
    sleep 3
  done
}

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Earmark Deploy  |  $NETWORK"
echo " Admin:  $ADMIN"
echo " USDC:   $USDC"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Building WASM..."
stellar contract build --quiet 2>/dev/null || stellar contract build
WASM="target/wasm32v1-none/release"

# ── Resolve the USDC SAC address ────────────────────────────────────────────────
# `stellar contract id asset` is deterministic. On testnet the SAC may not be
# instantiated yet, so deploy it (ignore the error if it already exists).
echo "Resolving USDC Stellar Asset Contract..."
stellar contract asset deploy --asset "$USDC" --source "$KEY" --network "$NETWORK" >/dev/null 2>&1 || true
USDC_ID=$(stellar contract id asset --asset "$USDC" --network "$NETWORK")
echo " USDC SAC: $USDC_ID"

_deploy() {
  retry stellar contract deploy \
    --wasm "$WASM/$1.wasm" \
    --source "$KEY" \
    --network "$NETWORK"
}

_invoke() {
  local id="$1"; shift
  retry stellar contract invoke --id "$id" --source "$KEY" --network "$NETWORK" -- "$@"
}

echo "Deploying contracts..."
REGISTRY_ID=$(_deploy earmark_registry)
ATTEST_ID=$(_deploy earmark_attestation)
ESCROW_ID=$(_deploy earmark_escrow)
STREAM_ID=$(_deploy earmark_streaming)

echo "Initializing..."
_invoke "$REGISTRY_ID" initialize --admin "$ADMIN"
_invoke "$ATTEST_ID"   initialize --admin "$ADMIN"
_invoke "$ESCROW_ID"   initialize --admin "$ADMIN" --token "$USDC_ID" --registry "$REGISTRY_ID" --attestation "$ATTEST_ID"
_invoke "$STREAM_ID"   initialize --admin "$ADMIN" --token "$USDC_ID"

# write frontend env
cat > frontend/.env.local <<EOF
NEXT_PUBLIC_NETWORK=$([[ "$NETWORK" == "testnet" ]] && echo TESTNET || echo MAINNET)
NEXT_PUBLIC_RPC_URL=$RPC_URL
NEXT_PUBLIC_NETWORK_PASSPHRASE="$PASSPHRASE"
NEXT_PUBLIC_USDC_CODE=USDC
NEXT_PUBLIC_USDC_ISSUER=$USDC_ISSUER
NEXT_PUBLIC_USDC_CONTRACT_ID=$USDC_ID
NEXT_PUBLIC_REGISTRY_CONTRACT_ID=$REGISTRY_ID
NEXT_PUBLIC_ATTESTATION_CONTRACT_ID=$ATTEST_ID
NEXT_PUBLIC_ESCROW_CONTRACT_ID=$ESCROW_ID
NEXT_PUBLIC_STREAMING_CONTRACT_ID=$STREAM_ID
EOF

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Deployed on $NETWORK"
echo " USDC SAC    : $USDC_ID"
echo " Registry    : $REGISTRY_ID"
echo " Attestation : $ATTEST_ID"
echo " Escrow      : $ESCROW_ID"
echo " Streaming   : $STREAM_ID"
echo " frontend/.env.local written"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next: seed demo institutions with  ./scripts/seed.sh $NETWORK $KEY"
