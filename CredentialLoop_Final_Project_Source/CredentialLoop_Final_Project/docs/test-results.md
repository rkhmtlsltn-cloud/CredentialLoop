# Prototype test record

Run date: November 14, 2026  
Network: Hardhat 3 local simulated EVM (`credentialLoopLocal`)  
Compiler: Solidity 0.8.34  
OpenZeppelin Contracts: 5.6.1

`npm run build` completed successfully. `npm run typecheck` completed successfully. `npm test` passed **11 tests**. `npm audit` reported zero known vulnerabilities with the lockfile's tested Zod 4.6.7 override.

1. Initial administrator role is assigned to the deployer only.
2. Administrator can register an issuer.
3. A non-administrator cannot register an issuer.
4. The zero address cannot be registered as an issuer.
5. A registered issuer can issue a synthetic status reference and an event is emitted.
6. An unregistered account cannot issue.
7. A zero credential reference is rejected.
8. Duplicate issue references are rejected.
9. A verifier or unrelated account cannot revoke another issuer's record.
10. Revoked status is returned as inactive and retains the issuer address.
11. The administrator can pause and resume status-changing calls.

`npm run demo` completed locally. It deployed the contract, registered a synthetic issuer, issued and checked a synthetic status, revoked it, and confirmed that the status then returned inactive. No real network, wallet secret, personal data, credential file or funds were used.

These results demonstrate only the listed behavior on a local simulation. They are not an external security audit, privacy assessment, Besu consensus test, or production readiness claim.
