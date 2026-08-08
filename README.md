# 🟠 Your First Conversation with Bitcoin Core

Most people only ever experience Bitcoin through a **wallet app**. Tonight you're
going to skip the app and talk **directly to the software that runs the Bitcoin
network** — the same program (Bitcoin Core) that runs on thousands of computers
around the world.

You'll spin up your own private Bitcoin, **mine real blocks**, **send a
transaction**, and then crack one open to see what your wallet has been hiding
from you this whole time.

No installing anything. No real money. No way to break it. Let's go. 👇

---

## Step 0 — Launch your node (do this first)

1. Click the green **`< > Code`** button at the top of this repo.
2. Open the **Codespaces** tab → **Create codespace on main**.
3. Wait ~1–2 minutes while it builds. A browser-based VS Code opens with a
   **terminal** at the bottom.

When the terminal is ready you'll see a banner like this:

```
────────────────────────────────────────────────────────────
  🟠  LBTCL Teaser — your own private Bitcoin (regtest)
────────────────────────────────────────────────────────────
   Node status : ✅ running
```

> 🛟 **If it says `not running`:** just type `start-node` and press Enter.

Everything below happens in that terminal. Type the commands yourself — muscle
memory is the point.

---

## Part 1 — Say hello 👋

You're now running a full Bitcoin node in **regtest mode**: a private test
network where *you are the only participant.* Ask it how it's doing:

```bash
bitcoin-cli getblockchaininfo
```

**You'll see something like** (your exact numbers will differ):

```json
{
  "chain": "regtest",
  "blocks": 0,
  "headers": 0,
  "bestblockhash": "0f9188f13cb7b2c71f2a335e3a4fc328bf5beb436012afca590b1a11466e2206",
  "difficulty": 4.656542373906925e-10,
  ...
}
```

🔎 **Notice:** `"chain": "regtest"` and `"blocks": 0`. This is a brand-new,
empty blockchain that exists nowhere but your Codespace. You're going to fill it.

How many other computers are you connected to?

```bash
bitcoin-cli getconnectioncount
```

```
0
```

Zero. On the real network your node would be talking to dozens of peers. Here,
**you are the entire network** — miner, wallet, and validator all at once.

---

## Part 2 — A wallet is born 👛

Create a wallet:

```bash
bitcoin-cli createwallet "cli-wallet"
```

```json
{
  "name": "cli-wallet"
}
```

Now generate an address to receive coins:

```bash
bitcoin-cli getnewaddress
```

```
bcrt1qh8s6z2vxk9r0t3m4q7w8p2n5l9c0d1a2b3c4d5
```

That `bcrt1q…` string is a Bitcoin address (the `bcrt` prefix just means
"regtest"). Your phone wallet quietly generates **thousands** of these behind
the scenes — you just watched one get born, by hand.

We'll be reusing an address a lot, so let's save one into a variable so you
don't have to copy-paste long strings:

```bash
ADDR=$(bitcoin-cli getnewaddress)
echo $ADDR
```

```
bcrt1qw3f8k2j9r7t5m0q4p6n8l1c3d5a7b9e2f4g6h8
```

> 💡 `ADDR=$(…)` runs the command and stores its output. Now anywhere you type
> `$ADDR`, the shell swaps in your address for you.

---

## Part 3 — Mine your own money ⛏️

On the real Bitcoin network, mining a single block is a planet-wide computational
race that takes ~10 minutes and megawatts of power. On **your** private network,
*you* are the miner and you can just… ask for blocks.

Mine 101 of them, paying the rewards to your address:

```bash
bitcoin-cli generatetoaddress 101 "$ADDR"
```

**A wall of block hashes scrolls past** — you just created 101 blocks instantly:

```json
[
  "5f8e...a1c2",
  "2b9d...f4e6",
  "... (99 more) ...",
  "8c3a...b7d9"
]
```

Check the chain again:

```bash
bitcoin-cli getblockchaininfo
```

🔎 **Notice:** `"blocks"` is now **101**. You extended the blockchain. Now check
your balance:

```bash
bitcoin-cli getbalance
```

```
50.00000000
```

**You just minted 50 bitcoin out of thin air.** 🎉 (Play money, but the mechanism
is 100% real — this is literally how every bitcoin that exists first came into
being.)

### "Wait — I mined 101 blocks. Why only 50?"

Great question. Newly mined coins have to **mature for 100 blocks** before you're
allowed to spend them (a rule that protects the chain). Peek at the full picture:

```bash
bitcoin-cli getbalances
```

```json
{
  "mine": {
    "trusted": 50.00000000,
    "untrusted_pending": 0.00000000,
    "immature": 5000.00000000
  }
}
```

🔎 There's your other 5000 BTC sitting in `immature` — real, but not spendable
yet. Only your very first block's reward has aged enough to use.

---

## Part 4 — Crack open a transaction 🔬

Here's the part almost no wallet user ever sees. Let's send some coins and then
look at what a transaction **actually is**.

Make a second address (pretend it belongs to a friend) and send it 10 BTC:

```bash
RECIPIENT=$(bitcoin-cli getnewaddress)
TXID=$(bitcoin-cli sendtoaddress "$RECIPIENT" 10)
echo $TXID
```

```
a3f5c9e1b2d4...7890
```

That long string is your **transaction ID**. Your transaction now exists, but it
hasn't been mined into a block yet — it's waiting in the "mempool":

```bash
bitcoin-cli getrawmempool
```

```json
[
  "a3f5c9e1b2d4...7890"
]
```

🔎 There it is, waiting. Now here's the reveal. First, look at the *raw* form of
your transaction — this is literally the bytes that travel across the network:

```bash
bitcoin-cli getrawtransaction "$TXID"
```

```
0200000001abcd...  (a long wall of hex gibberish)
```

Looks like nonsense, right? That "nonsense" **is** a Bitcoin transaction. Now ask
Bitcoin Core to unpack it for you:

```bash
bitcoin-cli decoderawtransaction $(bitcoin-cli getrawtransaction "$TXID")
```

**You'll see the transaction's true anatomy:**

```json
{
  "txid": "a3f5c9e1b2d4...7890",
  "vin": [
    {
      "txid": "e1d2c3b4...  (the coinbase you mined earlier)",
      "vout": 0
    }
  ],
  "vout": [
    {
      "value": 10.00000000,
      "n": 0,
      "scriptPubKey": {
        "address": "bcrt1q…(your recipient)",
        "type": "witness_v0_keyhash"
      }
    },
    {
      "value": 39.99998200,
      "n": 1,
      "scriptPubKey": {
        "address": "bcrt1q…(a brand-new change address)",
        "type": "witness_v0_keyhash"
      }
    }
  ]
}
```

🔎 **This is the big one. Read it slowly:**

- **`vin` (inputs):** your transaction doesn't have a "from balance." It points
  at a *specific previous coin* — the block reward you mined — and spends it.
- **`vout` (outputs):** two chunks. `10 BTC` locked to your recipient's address,
  and `~40 BTC` sent **back to yourself** as *change*. Your wallet created that
  change address automatically, without telling you.
- There is **no "balance" field anywhere.** Bitcoin has no accounts and no
  balances. It only has these locked chunks of value, called **UTXOs**
  (Unspent Transaction Outputs).

> 🤯 Every time you've ever tapped "send" in a wallet app, *this* is what it was
> silently building for you.

### Confirm your transaction

Right now your transaction is still just *pending*. Mine one more block to
confirm it — you're the miner, after all:

```bash
bitcoin-cli generatetoaddress 1 "$ADDR"
```

Now look at your coins the way Bitcoin actually stores them:

```bash
bitcoin-cli listunspent
```

```json
[
  {
    "txid": "a3f5c9e1...",
    "vout": 0,
    "address": "bcrt1q…(recipient)",
    "amount": 10.00000000,
    "confirmations": 1
  },
  {
    "txid": "a3f5c9e1...",
    "vout": 1,
    "address": "bcrt1q…(your change)",
    "amount": 39.99998200,
    "confirmations": 1
  }
]
```

🔎 **This is your "wallet."** Not a number — a *set of chunks*, each one locked to
an address and spendable independently. Your balance is simply the **sum of these
chunks.** That's the secret the app never showed you.

> 🧠 One subtlety: you sent 10 BTC to an address *you also control*, so your total
> barely moved — only the tiny miner fee actually left. On the real network,
> sending to someone else's address moves those coins out of your control for good.

---

## 🏁 What you just did

In about an hour, with zero prior setup, you:

- ✅ Ran a **real Bitcoin full node** and talked to it directly
- ✅ Created a wallet and generated addresses by hand
- ✅ **Mined blocks** and minted brand-new coins
- ✅ Built, broadcast, and **confirmed a transaction**
- ✅ Saw the **UTXO model** that every wallet hides — inputs, outputs, and change

That was a taste of **Week 1** of Bitshala's *Learning Bitcoin from the Command
Line* (LBTCL) cohort.

## 🚀 Want to go deeper? Join the cohort.

The full **8-week LBTCL cohort** takes you from exactly this point all the way
through Bitcoin scripts, multisig, PSBTs, and building transactions from scratch —
with a community of learners, weekly discussions, and teaching assistants to
unstick you.

- 💸 **Completely free.** Always.
- 🏅 Earn a completion certificate + a shot at a Bitshala fellowship.
- 🧑‍🤝‍🧑 Learn alongside a batch of people just as curious as you.

👉 **Apply / learn more:** [bitshala.org](https://bitshala.org)

*See you in the terminal.* 🟠

---

<details>
<summary>🛟 Troubleshooting</summary>

- **`error: couldn't connect to server`** → your node isn't running. Type
  `start-node` and try again.
- **Banner says `not running`** → same fix: `start-node`.
- **`Fee estimation failed` on send** → your node is missing its config. Ask a
  TA (this shouldn't happen in the Codespace — the fee setting is pre-configured).
- **Lost your address variable** (e.g. you opened a new terminal) → just set it
  again: `ADDR=$(bitcoin-cli getnewaddress)`.
- **Want a totally fresh start?** Run `bitcoin-cli stop`, wait a few seconds,
  then `start-node`. (Your chain is preserved. To wipe it entirely, ask a TA.)

</details>
