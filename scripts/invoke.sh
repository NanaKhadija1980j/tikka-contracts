#!/bin/bash
set -e

# Source environment variables if .env exists locally
if [ -f .env ]; then
  export $(cat .env | xargs)
fi

# Configuration
NETWORK="${STELLAR_NETWORK:-testnet}"
CONTRACT_ID="${RAFFLE_CONTRACT_ADDRESS}"

if [ -z "$CONTRACT_ID" ]; then
    echo "Error: RAFFLE_CONTRACT_ADDRESS is required"
    exit 1
fi

if [ -z "$1" ]; then
    echo "Usage: ./scripts/invoke.sh <function_name> [args...]"
    echo "Example: ./scripts/invoke.sh buy_ticket --source \$DEPLOYER_SECRET_KEY"
    echo "Note: finalize_raffle is permissionless and takes the triggering caller:"
    echo "      ./scripts/invoke.sh finalize_raffle \$RAFFLE_CALLER_ADDRESS"
    exit 1
fi

FUNCTION_NAME=$1
shift # Shift arguments so $@ contains only the remaining args

# #1253: finalize_raffle requires the address that triggers the draw so the
# DrawTriggered event reports the real caller instead of always the creator.
if [ "$FUNCTION_NAME" = "finalize_raffle" ] && [ $# -eq 0 ]; then
    echo "Error: finalize_raffle requires the caller address as first argument"
    echo "Example: ./scripts/invoke.sh finalize_raffle \$RAFFLE_CALLER_ADDRESS"
    exit 1
fi

echo "Invoking $FUNCTION_NAME on contract $CONTRACT_ID ($NETWORK)..."

stellar contract invoke \
  --id "$CONTRACT_ID" \
  --network "$NETWORK" \
  --source "${DEPLOYER_SECRET_KEY}" \
  -- "$FUNCTION_NAME" "$@"
