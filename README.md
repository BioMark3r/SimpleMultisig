# MultiSig Wallet

A simple n-of-m Ethereum multisignature wallet.

## 🔧 Setup

```bash
git clone [REPO_URL]
cd multisig
npm install
npx hardhat test



🛠 Features
Propose transactions to transfer ETH

Approve transactions by multiple signers

Execute transaction once quorum (n) is met

Event logging for proposals, approvals, and execution

✅ Tests
Happy path: full transaction lifecycle

Permission edge cases: non-signer rejection, double approval

Execution fails if not enough approvals

🧠 Assumptions
Signers are fixed at deployment

ETH transfers only (no tokens or advanced call data)

No on-chain cancellation of proposals

🚫 Limitations
Approvals are not revocable

No signer management (adding/removing)

No gas optimization beyond basic best practices
