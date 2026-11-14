Educational project for the course Introduction to Finance. Not a real product, service or investment offer. Do not use with real funds.

# CredentialLoop — local prototype

CredentialLoop demonstrates a minimal status registry for short-course credentials. The contract stores only a salted, opaque credential reference, the issuing institution's address, status and timestamps. Credential content and personal data remain off-chain. The reference in the demo is synthetic.

This source folder is prepared as the team's repository. It has not been published to GitHub. After the team uploads it, add the repository URL to the final report title page, presentation title slide and this README. The required demo video link is also to be added to those three places after the team records and uploads the video.

## Run locally

Requirements: Node.js 22.13 or later and npm.

```bash
npm install
npm run build
npm test
npm run demo
```

`npm test` runs the contract interaction tests on Hardhat's local simulated network. `npm run demo` deploys the contract to that local simulation, registers a synthetic issuer, records a synthetic credential status, checks it, revokes it and checks again. The demo does not connect to a public network, and the repository contains no wallet keys or `.env` file.

## Contract scope

- An administrator can register or remove issuer accounts and pause or resume status changes.
- A registered issuer can record a credential reference once.
- The issuing institution or administrator can revoke its status.
- A verifier can query whether the reference is active and which issuer recorded it.
- The contract does not store names, IINs, course titles, certificate files, or the credential itself. It does not handle payments or tokens.

Use a cryptographically random 32-byte salt when creating a real credential reference. Hash the credential's random identifier together with that salt off-chain; keep the underlying identifier and salt under the learner's control. The deterministic string in the tests/demo is synthetic and must never be reused for real personal data.

## Prototype boundaries and security

Hardhat is only the local EVM development environment used to test contract behavior. It does not simulate Besu consensus. The proposed production direction remains a permissioned Hyperledger Besu consortium using QBFT; the team still needs to validate the governance and cost assumptions. Do not deploy this prototype to a public or production network. It is not audited and must not be used for actual credentials.

The code uses OpenZeppelin `AccessControl` for role checks and `Pausable` for an emergency stop. It makes no external calls and holds no funds, so payment reentrancy is outside its current attack surface. A real deployment would still need independent key management, multi-party administration, privacy/legal review, monitoring, backup procedures and an external audit.

## Project files

- `contracts/CredentialLoopRegistry.sol` — status registry contract.
- `test/CredentialLoopRegistry.ts` — role, issuance, revocation, pause and validation tests.
- `scripts/demo.ts` — repeatable synthetic demonstration.
- `docs/technical-design.md` — role model, consensus comparison and security notes.
- `docs/main-use-case.mmd` — sequence diagram source.
- `docs/three-minute-demo.md` — recording plan and spoken script.
- `docs/test-results.md` — build, type-check, test and local-demo result record.

## AI disclosure

ChatGPT (GPT-6) assisted with the initial project scaffold, contract draft, tests and documentation. The team must review, run and be able to explain every function and test before submission.

The lockfile pins the tested dependency set. `package.json` overrides the transitive Zod dependency to 4.6.7; build, type-check, tests, demo and `npm audit` were re-run successfully after that override. Recheck the override when updating Hardhat or its plugins.

## References

- Hardhat. (n.d.). *Getting started with Hardhat 3*. Retrieved November 14, 2026, from https://hardhat.org/docs/getting-started
- OpenZeppelin. (n.d.). *Access control*. Retrieved November 14, 2026, from https://docs.openzeppelin.com/contracts/5.x/access-control
- Besu. (n.d.). *Proof of authority consensus protocols*. Retrieved November 14, 2026, from https://docs.besu-eth.org/private-networks/concepts/poa
- Besu. (n.d.). *QBFT consensus*. Retrieved November 14, 2026, from https://docs.besu-eth.org/private-networks/how-to/configure/consensus/qbft
