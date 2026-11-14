import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { keccak256, toBytes, zeroAddress, zeroHash } from "viem";
import { network } from "hardhat";

const credentialRef = keccak256(
  toBytes("synthetic-course-credential-001|test-only-random-salt"),
);

describe("CredentialLoopRegistry", async function () {
  const { viem } = await network.create();
  const [admin, issuer, verifier, otherIssuer] = await viem.getWalletClients();

  async function freshRegistry() {
    return viem.deployContract("CredentialLoopRegistry", [admin.account.address]);
  }

  it("gives only the deployer the initial administrator role", async function () {
    const registry = await freshRegistry();
    const adminRole = await registry.read.DEFAULT_ADMIN_ROLE();
    assert.equal(await registry.read.hasRole([adminRole, admin.account.address]), true);
    assert.equal(await registry.read.hasRole([adminRole, issuer.account.address]), false);
  });

  it("lets an administrator register an issuer", async function () {
    const registry = await freshRegistry();
    await registry.write.registerIssuer([issuer.account.address], { account: admin.account });
    const issuerRole = await registry.read.ISSUER_ROLE();
    assert.equal(await registry.read.hasRole([issuerRole, issuer.account.address]), true);
  });

  it("rejects issuer registration by a non-administrator", async function () {
    const registry = await freshRegistry();
    await viem.assertions.revertWithCustomError(
      registry.write.registerIssuer([otherIssuer.account.address], { account: issuer.account }),
      registry,
      "AccessControlUnauthorizedAccount",
    );
  });

  it("rejects the zero address as an issuer", async function () {
    const registry = await freshRegistry();
    await viem.assertions.revertWithCustomError(
      registry.write.registerIssuer([zeroAddress], { account: admin.account }),
      registry,
      "ZeroAddress",
    );
  });

  it("allows a registered issuer to issue a synthetic status record", async function () {
    const registry = await freshRegistry();
    await registry.write.registerIssuer([issuer.account.address], { account: admin.account });
    await viem.assertions.emit(
      registry.write.issueCredential([credentialRef], { account: issuer.account }),
      registry,
      "CredentialIssued",
    );
    const [active, recordedIssuer] = await registry.read.checkCredential([credentialRef]);
    assert.equal(active, true);
    assert.equal(recordedIssuer.toLowerCase(), issuer.account.address.toLowerCase());
  });

  it("rejects issuance from an unregistered account", async function () {
    const registry = await freshRegistry();
    await viem.assertions.revertWithCustomError(
      registry.write.issueCredential([credentialRef], { account: issuer.account }),
      registry,
      "AccessControlUnauthorizedAccount",
    );
  });

  it("rejects a zero credential reference", async function () {
    const registry = await freshRegistry();
    await registry.write.registerIssuer([issuer.account.address], { account: admin.account });
    await viem.assertions.revertWithCustomError(
      registry.write.issueCredential([zeroHash], { account: issuer.account }),
      registry,
      "ZeroCredentialReference",
    );
  });

  it("rejects issuing the same credential reference twice", async function () {
    const registry = await freshRegistry();
    await registry.write.registerIssuer([issuer.account.address], { account: admin.account });
    await registry.write.issueCredential([credentialRef], { account: issuer.account });
    await viem.assertions.revertWithCustomError(
      registry.write.issueCredential([credentialRef], { account: issuer.account }),
      registry,
      "CredentialAlreadyExists",
    );
  });

  it("allows only the issuing institution or administrator to revoke", async function () {
    const registry = await freshRegistry();
    await registry.write.registerIssuer([issuer.account.address], { account: admin.account });
    await registry.write.issueCredential([credentialRef], { account: issuer.account });
    await viem.assertions.revertWithCustomError(
      registry.write.revokeCredential([credentialRef], { account: verifier.account }),
      registry,
      "UnauthorizedRevoker",
    );
  });

  it("shows a revoked credential as inactive and preserves the issuer", async function () {
    const registry = await freshRegistry();
    await registry.write.registerIssuer([issuer.account.address], { account: admin.account });
    await registry.write.issueCredential([credentialRef], { account: issuer.account });
    await viem.assertions.emit(
      registry.write.revokeCredential([credentialRef], { account: issuer.account }),
      registry,
      "CredentialRevoked",
    );
    const [active, recordedIssuer] = await registry.read.checkCredential([credentialRef]);
    assert.equal(active, false);
    assert.equal(recordedIssuer.toLowerCase(), issuer.account.address.toLowerCase());
  });

  it("lets an administrator pause issuance and resume it", async function () {
    const registry = await freshRegistry();
    await registry.write.registerIssuer([issuer.account.address], { account: admin.account });
    await registry.write.pause({ account: admin.account });
    await viem.assertions.revertWithCustomError(
      registry.write.issueCredential([credentialRef], { account: issuer.account }),
      registry,
      "EnforcedPause",
    );
    await registry.write.unpause({ account: admin.account });
    await registry.write.issueCredential([credentialRef], { account: issuer.account });
    const [active] = await registry.read.checkCredential([credentialRef]);
    assert.equal(active, true);
  });
});
