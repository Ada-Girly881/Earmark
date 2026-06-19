#!/usr/bin/env bash
# Seed a few verified demo institutions so the "direct-to-purpose" and attestation
# flows have something to point at. Reads contract ids from frontend/.env.local.
#
# Usage: ./scripts/seed.sh [testnet|mainnet] [key-alias]
set -euo pipefail

NETWORK="${1:-testnet}"
KEY="${2:-deployer}"

# shellcheck disable=SC1091
set -a; source frontend/.env.local; set +a
REGISTRY_ID="$NEXT_PUBLIC_REGISTRY_CONTRACT_ID"
ATTEST_ID="$NEXT_PUBLIC_ATTESTATION_CONTRACT_ID"
ADMIN=$(stellar keys address "$KEY")

_invoke() {
  local id="$1"; shift
  stellar contract invoke --id "$id" --source "$KEY" --network "$NETWORK" -- "$@"
}

echo "Seeding demo institutions into $REGISTRY_ID ..."

# For the demo all payouts go to the admin address so released funds are easy to see.
# In production each institution supplies its own payout + attestor key.
add_and_verify() {
  local name="$1"; local category="$2"
  local id
  # Soroban unit-enum variants are passed as JSON strings, e.g. '"School"'.
  id=$(_invoke "$REGISTRY_ID" add_institution --name "$name" --category "\"$category\"" --payout "$ADMIN")
  id=${id//\"/}
  _invoke "$REGISTRY_ID" set_verified --id "$id" --verified true
  echo " ✓ [$id] $name ($category) — verified"
}

add_and_verify "Unity Grammar School"   School
add_and_verify "St. Mary Medical Clinic" Clinic
add_and_verify "Greenfield Apartments"   Landlord
add_and_verify "PowerGrid Utility"       Utility

# Let the admin act as the demo oracle/attestor (already implicit as admin, but make
# it explicit so a separate bursar key could be swapped in later).
_invoke "$ATTEST_ID" add_attestor --attestor "$ADMIN" || true

echo "Done. Institutions are verified and ready for direct-to-purpose earmarks."
