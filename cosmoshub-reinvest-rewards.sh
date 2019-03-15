#!/bin/bash -e
# Copyright (C) 2019 Validator ApS -- https://validator.network

# This script comes without warranties of any kind. Use at your own risk.

# The purpose of this script is to withdraw rewards (if any) and delegate them to an appointed validator. This way you can reinvest (compound) rewards.
# Cosmos Hub does currently not support automatic compounding but this is planned: https://github.com/cosmos/cosmos-sdk/issues/3448

# Requirements: gaiacli and jq must be in the path.


##############################################################################################################################################################
# User settings.
##############################################################################################################################################################

KEY=""                                  # This is the key you wish to use for signing transactions, listed in first column of "gaiacli keys list".
PASSPHRASE=""                           # Only populate if you want to run the script periodically. This is UNSAFE and should only be done if you know what you are doing.
SIGNING_DEVICE=""                       # Set to "--ledger" if you are using a Ledger for signing.
DENOM="uatom"                           # Coin denominator is uatom ("microoatom"). 1 atom = 1000000 uatom.
MINIMUM_DELEGATION_AMOUNT="25000000"    # Only perform delegations above this amount of uatom. Default: 25atom.
RESERVATION_AMOUNT="100000000"          # Keep this amount of uatom in account. Default: 100atom.
VALIDATOR="cosmosvaloper1sxx9mszve0gaedz5ld7qdkjkfv8z992ax69k08"        # Default is Validator Network. Thank you for your patronage :-)

##############################################################################################################################################################


##############################################################################################################################################################
# Sensible defaults.
##############################################################################################################################################################

CHAIN_ID="cosmoshub-1"                          # Current chain id.
NODE="https://cosmoshub.validator.network:443"  # Either run a local full node or choose one you trust.
GAS_PRICES="0.025uatom"                         # Gas prices to pay for transaction.
GAS_ADJUSTMENT="1.25"                           # Adjustment for estimated gas

##############################################################################################################################################################


# Use first command line argument in case KEY is not defined.
if [ -z "${KEY}" ] && [ ! -z "${1}" ]
then
  KEY=${1}
fi


# Get current account balance.
ADDRESS=$(gaiacli keys show ${KEY} --address)
ACCOUNT_STATUS=$(gaiacli query account ${ADDRESS} --chain-id ${CHAIN_ID} --node ${NODE} --output json)
ACCOUNT_BALANCE=$(echo ${ACCOUNT_STATUS} | jq -r ".value.coins[] | select(.denom == \"${DENOM}\") | .amount" || true)
if [ -z "${ACCOUNT_BALANCE}" ]
then
    # Empty response means zero balance.
    ACCOUNT_BALANCE=0
fi

# Get available rewards.
REWARDS_STATUS=$(gaiacli query distr rewards ${ADDRESS} --chain-id ${CHAIN_ID} --node ${NODE} --output json)
REWARDS_BALANCE=$(echo ${REWARDS_STATUS} | jq -r ".[] | select(.denom == \"${DENOM}\") | .amount" || true)
if [ -z "${REWARDS_BALANCE}" ]
then
    # Empty response means zero balance.
    REWARDS_BALANCE="0"
else
    # Remove decimals.
    REWARDS_BALANCE=${REWARDS_BALANCE%.*}
fi

# Calculate net balance and amount to delegate.
NET_BALANCE=$((${ACCOUNT_BALANCE} + ${REWARDS_BALANCE}))
if [ "${NET_BALANCE}" -gt $((${MINIMUM_DELEGATION_AMOUNT} + ${RESERVATION_AMOUNT})) ]
then
    DELEGATION_AMOUNT=$((${NET_BALANCE} - ${RESERVATION_AMOUNT}))
else
    DELEGATION_AMOUNT="0"
fi

# Display what we know so far.
echo "======================================================"
echo "Account: ${KEY}"
echo "Address: ${ADDRESS}"
echo "======================================================"
echo "Account balance:   ${ACCOUNT_BALANCE}${DENOM}"
echo "Available rewards: ${REWARDS_BALANCE}${DENOM}"
echo "Net balance:       ${NET_BALANCE}${DENOM}"
echo "Reservation:       ${RESERVATION_AMOUNT}${DENOM}"
echo

if [ "${DELEGATION_AMOUNT}" -eq 0 ]
then
    echo "Nothing to delegate."
    exit 0
fi

# Display delegation information.
VALIDATOR_STATUS=$(gaiacli query staking validator ${VALIDATOR} --chain-id ${CHAIN_ID} --node ${NODE} --output json)
VALIDATOR_MONIKER=$(echo ${VALIDATOR_STATUS} | jq -r ".description.moniker")
VALIDATOR_DETAILS=$(echo ${VALIDATOR_STATUS} | jq -r ".description.details")
echo "You are about to delegate ${DELEGATION_AMOUNT}${DENOM} to ${VALIDATOR}:"
echo "  Moniker: ${VALIDATOR_MONIKER}"
echo "  Details: ${VALIDATOR_DETAILS}"
echo

# Ask for passphrase to sign transactions.
if [ -z "${SIGNING_DEVICE}"] && [ -z "${PASSPHRASE}" ]
then
    read -s -p "Enter passphrase required to sign for \"${KEY}\": " PASSPHRASE
    echo ""
fi

# Run transactions
GAS_FLAGS="--gas auto --gas-prices ${GAS_PRICES} --gas-adjustment ${GAS_ADJUSTMENT}"
echo "Withdrawing rewards..."
echo ${PASSPHRASE} | gaiacli tx distr withdraw-all-rewards --from ${KEY} --chain-id ${CHAIN_ID} --node ${NODE} ${GAS_FLAGS} ${SIGNING_DEVICE} --yes
echo "Delegating..."
echo ${PASSPHRASE} | gaiacli tx staking delegate ${VALIDATOR} ${DELEGATION_AMOUNT}${DENOM} --from ${KEY} --chain-id ${CHAIN_ID} --node ${NODE} ${GAS_FLAGS} ${SIGNING_DEVICE} --yes

echo
echo "Have a Cosmic day!"
