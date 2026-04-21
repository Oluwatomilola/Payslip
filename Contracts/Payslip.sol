// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Fundslip {

    struct Slip {
        address user;
        uint256 totalValue; // in USD (scaled, e.g. 1e6)
        uint256 timestamp;
        bytes32 dataHash; // hash of full portfolio breakdown
    }

    mapping(bytes32 => bool) public verifiedSlips;

    event SlipVerified(
        address indexed user,
        uint256 totalValue,
        uint256 timestamp,
        bytes32 indexed slipId
    );

    function verifySlip(
        address user,
        uint256 totalValue,
        uint256 timestamp,
        bytes32 dataHash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 messageHash = keccak256(
            abi.encodePacked(user, totalValue, timestamp, dataHash)
        );

        bytes32 ethSignedMessage = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        address signer = ecrecover(ethSignedMessage, v, r, s);

        require(signer == user, "Invalid signature");

        bytes32 slipId = keccak256(
            abi.encodePacked(user, timestamp, dataHash)
        );

        require(!verifiedSlips[slipId], "Slip already exists");

        verifiedSlips[slipId] = true;

        emit SlipVerified(user, totalValue, timestamp, slipId);
    }

    function isVerified(bytes32 slipId) external view returns (bool) {
        return verifiedSlips[slipId];
    }
}