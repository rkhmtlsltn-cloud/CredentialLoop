# Three-minute prototype video plan

## Before recording

1. Open this repository in a terminal and run `npm install`, `npm run build`, `npm test` and `npm run demo` once to confirm they work.
2. Close any terminal or editor tab that contains keys, `.env` files, personal information or unrelated private material.
3. Record only the terminal and the relevant source files. The script uses synthetic references and tool-generated local accounts. Do not use a public network or real funds.
4. Keep the recording under three minutes. Speak in English for the course defense; captions can be added if needed.

## Suggested recording and narration

**0:00–0:20 — Scope**  
“This is CredentialLoop, a course prototype for checking the current status of short-course credentials. It is not a real product. The prototype uses Hardhat's local simulated EVM network only. No personal data or real credentials are used.”

**0:20–1:30 — Deploy and use case**  
Run:

```bash
npm run demo
```

“The script deploys `CredentialLoopRegistry`, registers a synthetic issuer account, and records a status using an opaque test reference. A verifier checks that the credential is active. The issuer then revokes it, and the verifier sees the updated status. The credential file and learner identity are not stored in the contract.”

**1:30–2:15 — Show the contract boundary**  
Open `contracts/CredentialLoopRegistry.sol` and point to `registerIssuer`, `issueCredential`, `revokeCredential` and `checkCredential`.  
“The administrator manages issuer accounts. An approved issuer can issue a new status reference and revoke its own record. The contract only stores a salted reference, issuer address, status and timestamps. Production use would require independent key governance, privacy review and an external audit.”

**2:15–2:50 — Run tests**  
Run:

```bash
npm test
```

“The tests cover the administrator and issuer roles, rejection of unauthorized calls, duplicate and zero references, issuance, revocation and emergency pause. Passing tests show the tested behavior only; they are not a security audit.”

**2:50–3:00 — Limitation**  
“The local prototype does not run Besu QBFT or prove that a consortium is needed. We would proceed to a Besu prototype only if interviews confirm that independent institutions need shared governance and it compares favorably with a signed central registry on total cost.”

## After recording

Upload the video to the team's chosen storage with access for anyone with the link. Add that link to the report title page, presentation title slide and README. The team must verify playback and access in a private browser window before submission.
