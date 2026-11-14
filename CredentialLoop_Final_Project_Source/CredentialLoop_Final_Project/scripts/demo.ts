import { network } from "hardhat";
import { keccak256, toBytes } from "viem";

const { viem } = await network.create();
const [admin, issuer, verifier] = await viem.getWalletClients();

// Synthetic demo-only reference. No learner or certificate data is used.
const credentialRef = keccak256(
  toBytes("CredentialLoop|DEMO_ONLY|synthetic-course-credential-001|salt-001"),
);

console.log("CredentialLoop local demonstration — Hardhat simulated chain only.");
const registry = await viem.deployContract("CredentialLoopRegistry", [admin.account.address]);
console.log(`1. Contract deployed at ${registry.address}`);

await registry.write.registerIssuer([issuer.account.address], { account: admin.account });
console.log(`2. Administrator registered synthetic issuer ${issuer.account.address}`);

await registry.write.issueCredential([credentialRef], { account: issuer.account });
console.log(`3. Issuer recorded status for synthetic reference ${credentialRef}`);

let [active, recordedIssuer] = await registry.read.checkCredential([credentialRef]);
console.log(`4. Verifier result: active=${active}; issuer=${recordedIssuer}`);

await registry.write.revokeCredential([credentialRef], { account: issuer.account });
console.log("5. Issuer revoked the test credential status.");

[active, recordedIssuer] = await registry.read.checkCredential([credentialRef]);
console.log(`6. Verifier re-check: active=${active}; issuer=${recordedIssuer}`);
console.log(`Demo verifier account (tool-generated): ${verifier.account.address}`);
console.log("No personal data, wallet secrets, external network, or real funds were used.");
