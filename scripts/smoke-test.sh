#!/bin/bash
set -e

# Smoke test for a deployed Tikka raffle instance.
#
# The script exercises the read-only entry points of the raffle instance and
# then finalizes the raffle.  Since #1253 `finalize_raffle` is permissionless:
# it takes the address that triggers the draw as its first argument and that
# address must authorise the call.  The `DrawTriggered` event then reports the
# triggering address instead of always reporting the creator.

# Source environment variables if .env exists locally
if [ -f .env ]; then
  export $(cat .env | xargs)
fi

NETWORK="${STELLAR_NETWORK:-testnet}"
CONTRACT_ID="${RAFFLE_CONTRACT_ADDRESS}"
CALLER="${RAFFLE_CALLER_ADDRESS:-${RAFFLE_CREATOR_ADDRESS:-${DEPLOYER_PUBLIC_KEY}}}"

if [ -z "$CONTRACT_ID" ]; then
    echo "Error: RAFFLE_CONTRACT_ADDRESS is required"
    exit 1
fi

if [ -z "$CALLER" ]; then
    echo "Error: RAFFLE_CALLER_ADDRESS (or RAFFLE_CREATOR_ADDRESS) is required"
    echo "       It is the address that authorises the finalize_raffle call."
    exit 1
fi

invoke() {
    stellar contract invoke \
      --id "$CONTRACT_ID" \
      --network "$NETWORK" \
      --source "${DEPLOYER_SECRET_KEY}" \
      -- "$@"
}

echo "Smoke-testing raffle $CONTRACT_ID on $NETWORK (caller: $CALLER)..."

echo "-> get_raffle"
invoke get_raffle

echo "-> get_fairness_data"
invoke get_fairness_data

# #1253: the caller address must be supplied explicitly.
echo "-> finalize_raffle (caller: $CALLER)"
invoke finalize_raffle "$CALLER"

echo "-> get_raffle (after finalize)"
invoke get_raffle

echo "Smoke test completed successfully."
