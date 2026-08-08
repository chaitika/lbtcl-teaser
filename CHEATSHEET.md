# 🟠 LBTCL Teaser — One-Page Cheat Sheet

Keep this open in a split pane. Every command starts with `bitcoin-cli`.

| Goal | Command |
|---|---|
| Start the node (if not running) | `start-node` |
| Check the chain | `bitcoin-cli getblockchaininfo` |
| Count your peers | `bitcoin-cli getconnectioncount` |
| Create a wallet | `bitcoin-cli createwallet "cli-wallet"` |
| New address | `bitcoin-cli getnewaddress` |
| Save an address to a variable | `ADDR=$(bitcoin-cli getnewaddress)` |
| Mine 101 blocks to yourself | `bitcoin-cli generatetoaddress 101 "$ADDR"` |
| Check spendable balance | `bitcoin-cli getbalance` |
| Full balance (incl. immature) | `bitcoin-cli getbalances` |
| Send 10 BTC | `TXID=$(bitcoin-cli sendtoaddress "$RECIPIENT" 10)` |
| See unmined (pending) txs | `bitcoin-cli getrawmempool` |
| Raw transaction (hex) | `bitcoin-cli getrawtransaction "$TXID"` |
| Decode a transaction | `bitcoin-cli decoderawtransaction $(bitcoin-cli getrawtransaction "$TXID")` |
| Confirm it (mine 1 block) | `bitcoin-cli generatetoaddress 1 "$ADDR"` |
| List your coins (UTXOs) | `bitcoin-cli listunspent` |
| Stop the node | `bitcoin-cli stop` |

### The mental model to walk away with

```
Bitcoin has NO accounts and NO balances.
It has UTXOs — chunks of value, each locked to an address.

  Your "balance"  =  the sum of your UTXOs
  A transaction   =  spend some UTXOs (inputs)  →  create new ones (outputs)
                     leftover value comes back to you as "change"
```

### Handy extras (if you finish early)

| Goal | Command |
|---|---|
| Inspect any block by height | `bitcoin-cli getblockhash 1` then `bitcoin-cli getblock <hash>` |
| Details of one of your txs | `bitcoin-cli gettransaction "$TXID"` |
| Info about an address | `bitcoin-cli getaddressinfo "$ADDR"` |
| Every command there is | `bitcoin-cli help` |
| Help for one command | `bitcoin-cli help sendtoaddress` |
