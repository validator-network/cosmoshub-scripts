## Cosmos Hub reinvestment script for rewards

Courtesy of [Validator🌐Network](https://validator.network).

The provided script enable delegators to claim all their staking rewards and reinvest them, to receive compounded interest.

You do not need to run a local full node as the script defaults to using the https://cosmoshub.validator.network:443 RPC endpoint.


### Installation

First download the script and make it executable:
```
curl -O https://raw.githubusercontent.com/block-finance/cosmoshub-scripts/master/cosmoshub-reinvest-rewards.sh
chmod +x cosmoshub-reinvest-rewards.sh
```

### Configure settings
Now use your favorite text editor to change the *User settings* section of the file.

```
##############################################################################
# User settings.
##############################################################################

KEY="testkey1"
PASSPHRASE=""
VALIDATOR="cosmosvaloper1sxx9mszve0gaedz5ld7qdkjkfv8z992ax69k08"
SIGNING_DEVICE=""

##############################################################################
```

You should modify the `KEY` setting so that it matches the output of the NAME: column of `gaiacli keys list`:

![keychain](https://validator.network/img/gaiacli01.png "gaiacli keys list output")

If you are using a Ledger device, also specify `SIGNING_DEVICE="--ledger"`.

If you are using a local password-protected key, you __do not need__ to specify it as the script will prompt you for it.
The PASSPHRASE setting is merely provided as a convenience.

You can delegate to any validator you prefer by changing `VALIDATOR` variable.

### Enjoy the show

You can now run the script and expect output such as:
```
======================================================
Account: testkey1
Address: cosmos1mjgh0rejtljxg8rurmxlrff0kk2ztxmgc8mvzj
======================================================
Account balance:   20000122217uatom
Available rewards: 23588169uatom
Net balance:       20023710386uatom
Reservation:       100000000uatom

You are about to delegate 19923710386uatom to cosmosvaloper1sxx9mszve0gaedz5ld7qdkjkfv8z992ax69k08:
  Moniker: Validator🌐Network
  Details: Highly resilient and secure validator operating out of Northern Europe. See website for terms of service.
```
