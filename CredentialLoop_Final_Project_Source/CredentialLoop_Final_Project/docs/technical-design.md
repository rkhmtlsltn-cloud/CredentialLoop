# Technical design and security notes

## Production direction and prototype boundary

The proposed production direction is a permissioned Hyperledger Besu consortium, subject to evidence that several independent institutions need a shared status history and cannot accept a central operator at lower total cost. The course prototype is a Solidity contract exercised on Hardhat's in-memory local network. Hardhat validates EVM contract behavior; it does not implement or test Besu consensus, production nodes, or consortium governance.

For a new private Besu network, the current Besu documentation recommends QBFT. Named validators take turns proposing blocks and at least two-thirds of validators sign before a block is inserted. QBFT provides immediate finality. It needs at least four validators for Byzantine fault tolerance, and the chain stalls if more than one-third of validators stop participating. That minimum is a material adoption and operating-cost constraint for CredentialLoop: four genuinely independent validator institutions must be committed before a production consortium is justified.

The alternative considered is Besu IBFT 2.0. It is also proof-of-authority, offers immediate finality and has similar validator-count and liveness constraints. QBFT is selected as the starting production design because Besu recommends it for new private networks; the prototype does not claim a measured speed or cost advantage over IBFT 2.0. A signed central registry remains the lower-complexity comparator if interviews do not confirm the need for independent shared control.

## Roles and access

| Role | Allowed action | Boundary |
|---|---|---|
| Consortium administrator | Register/remove issuer accounts; pause/unpause the registry; revoke a credential as an emergency measure | Production administrator should be controlled by a multi-party approval mechanism, not one personal key |
| Approved issuer | Issue status references and revoke records that it issued | Cannot register other issuers or change another issuer's record |
| Verifier | Read current status for a reference it has received | No account role is required for this prototype; the application should only send a lookup after learner consent |
| Learner | Hold and share the off-chain credential and its random reference | No learner identity or credential content is placed on-chain |

The prototype uses OpenZeppelin `AccessControl` and `Pausable`. Role changes and credential changes emit events. The mapping exposes only status, issuing address and timestamps for an opaque `bytes32` reference. A production reference must be generated from a high-entropy random identifier and salt off-chain; hashing a name, email, IIN, certificate number or other predictable value is not safe anonymization.

## Main contract functions

| Function | Who calls it | Purpose |
|---|---|---|
| `registerIssuer(address)` | Administrator | Approves an issuing institution's contract account |
| `removeIssuer(address)` | Administrator | Stops an institution from issuing new status records |
| `issueCredential(bytes32)` | Approved issuer | Records an active status for a new opaque reference |
| `revokeCredential(bytes32)` | Issuing institution or administrator | Changes the current status to revoked and emits an event |
| `checkCredential(bytes32)` | Verifier application | Returns whether the status is active and the issuer address |
| `credentialInfo(bytes32)` | Verifier or application | Returns minimal status and timestamps for testing |
| `pause()` / `unpause()` | Administrator | Stops or resumes status-changing calls during an incident |

## Security review scope

| Threat | Prototype control | Production work still needed |
|---|---|---|
| Unauthorized issue or role change | `AccessControl`; tests reject non-issuer/non-admin calls | Independent role review, issuer onboarding policy and auditable multi-party admin |
| Compromised issuer key | Admin can remove the issuer; issuer/admin can revoke a record; contract can be paused | Per-institution key rotation, HSM or managed signing, incident process and recovery drills |
| Compromised administrator key | Prototype exposes only local tool-generated accounts; pause is role-gated | 2-of-3 or stronger multisignature governance, hardware-backed keys, separation of duties |
| Credential reference guessed or linked to a person | Contract accepts opaque `bytes32`; no personal fields or files are stored | Generate a random high-entropy salt; control disclosure; assess correlation and metadata leakage |
| Contract implementation defect | Unit tests cover authorization, issuance, duplicate references, revocation and pause | Independent security review and external audit before any production use; the KZT 3.0m Endterm security-review allowance is a planning estimate, not a quote |
| Reentrancy or stolen funds | No payable functions, token transfers or external calls exist in this contract | Reassess if future versions add payments, external calls or token functions |

The local tests are not an audit, and they do not prove privacy, Besu consensus, key safety or production readiness.

## Sources

- Besu. (n.d.). *Configure QBFT consensus*. Retrieved November 14, 2026, from https://github.com/besu-eth/besu-docs/blob/main/docs/private-networks/how-to/configure/consensus/qbft.md
- Besu. (n.d.). *Proof of authority consensus*. Retrieved November 14, 2026, from https://github.com/besu-eth/besu-docs/blob/main/docs/private-networks/concepts/poa.md
- OpenZeppelin. (n.d.). *Access control*. Retrieved November 14, 2026, from https://docs.openzeppelin.com/contracts/5.x/access-control
