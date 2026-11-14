// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

/// @notice Local course prototype for recording credential status, never credential content.
/// @dev Production deployment would require consortium governance, privacy review and an audit.
contract CredentialLoopRegistry is AccessControl, Pausable {
    bytes32 public constant ISSUER_ROLE = keccak256("ISSUER_ROLE");

    enum Status {
        None,
        Active,
        Revoked
    }

    struct CredentialRecord {
        Status status;
        address issuer;
        uint64 issuedAt;
        uint64 revokedAt;
    }

    mapping(bytes32 credentialRef => CredentialRecord) private records;

    error ZeroAddress();
    error ZeroCredentialReference();
    error CredentialAlreadyExists(bytes32 credentialRef);
    error CredentialAlreadyRevoked(bytes32 credentialRef);
    error CredentialNotFound(bytes32 credentialRef);
    error UnauthorizedRevoker(address caller);

    event IssuerRegistered(address indexed issuer);
    event IssuerRemoved(address indexed issuer);
    event CredentialIssued(
        bytes32 indexed credentialRef,
        address indexed issuer,
        uint64 issuedAt
    );
    event CredentialRevoked(
        bytes32 indexed credentialRef,
        address indexed issuer,
        address indexed revokedBy,
        uint64 revokedAt
    );

    constructor(address initialAdmin) {
        if (initialAdmin == address(0)) revert ZeroAddress();
        _grantRole(DEFAULT_ADMIN_ROLE, initialAdmin);
    }

    function registerIssuer(address issuer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (issuer == address(0)) revert ZeroAddress();
        _grantRole(ISSUER_ROLE, issuer);
        emit IssuerRegistered(issuer);
    }

    function removeIssuer(address issuer) external onlyRole(DEFAULT_ADMIN_ROLE) {
        if (issuer == address(0)) revert ZeroAddress();
        _revokeRole(ISSUER_ROLE, issuer);
        emit IssuerRemoved(issuer);
    }

    function issueCredential(bytes32 credentialRef) external onlyRole(ISSUER_ROLE) whenNotPaused {
        if (credentialRef == bytes32(0)) revert ZeroCredentialReference();
        if (records[credentialRef].status != Status.None) {
            revert CredentialAlreadyExists(credentialRef);
        }

        uint64 issuedAt = uint64(block.timestamp);
        records[credentialRef] = CredentialRecord({
            status: Status.Active,
            issuer: msg.sender,
            issuedAt: issuedAt,
            revokedAt: 0
        });

        emit CredentialIssued(credentialRef, msg.sender, issuedAt);
    }

    function revokeCredential(bytes32 credentialRef) external whenNotPaused {
        CredentialRecord storage record = records[credentialRef];
        if (record.status == Status.None) revert CredentialNotFound(credentialRef);
        if (msg.sender != record.issuer && !hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) {
            revert UnauthorizedRevoker(msg.sender);
        }
        if (record.status == Status.Revoked) revert CredentialAlreadyRevoked(credentialRef);

        uint64 revokedAt = uint64(block.timestamp);
        record.status = Status.Revoked;
        record.revokedAt = revokedAt;
        emit CredentialRevoked(credentialRef, record.issuer, msg.sender, revokedAt);
    }

    function checkCredential(bytes32 credentialRef)
        external
        view
        returns (bool active, address issuer)
    {
        CredentialRecord storage record = records[credentialRef];
        return (record.status == Status.Active, record.issuer);
    }

    function credentialInfo(bytes32 credentialRef)
        external
        view
        returns (Status status, address issuer, uint64 issuedAt, uint64 revokedAt)
    {
        CredentialRecord storage record = records[credentialRef];
        return (record.status, record.issuer, record.issuedAt, record.revokedAt);
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }
}
