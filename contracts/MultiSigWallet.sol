// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSigWallet {
    struct Transaction {
        address to;
        uint256 value;
        uint256 approvals;
        bool executed;
        mapping(address => bool) approvedBy;
    }

    address[] public signers;
    uint256 public requiredApprovals;
    uint256 public transactionCount;

    mapping(uint256 => Transaction) public transactions;
    mapping(address => bool) public isSigner;

    event TransactionProposed(uint256 txId, address to, uint256 value);
    event TransactionApproved(uint256 txId, address signer);
    event TransactionExecuted(uint256 txId);

    modifier onlySigner() {
        require(isSigner[msg.sender], "Not authorized signer");
        _;
    }

    constructor(address[] memory _signers, uint256 _requiredApprovals) {
        require(_requiredApprovals <= _signers.length, "Invalid threshold");
        for (uint i = 0; i < _signers.length; i++) {
            isSigner[_signers[i]] = true;
        }
        signers = _signers;
        requiredApprovals = _requiredApprovals;
    }

    function proposeTransaction(address _to, uint256 _value) external onlySigner returns (uint256) {
        uint256 txId = transactionCount++;
        Transaction storage txn = transactions[txId];
        txn.to = _to;
        txn.value = _value;
        emit TransactionProposed(txId, _to, _value);
        return txId;
    }

    function approveTransaction(uint256 txId) external onlySigner {
        Transaction storage txn = transactions[txId];
        require(!txn.executed, "Already executed");
        require(!txn.approvedBy[msg.sender], "Already approved");

        txn.approvedBy[msg.sender] = true;
        txn.approvals += 1;

        emit TransactionApproved(txId, msg.sender);

        if (txn.approvals >= requiredApprovals) {
            executeTransaction(txId);
        }
    }

    function executeTransaction(uint256 txId) internal {
        Transaction storage txn = transactions[txId];
        require(!txn.executed, "Already executed");
        require(txn.approvals >= requiredApprovals, "Not enough approvals");

        txn.executed = true;
        (bool success, ) = txn.to.call{value: txn.value}("");
        require(success, "Transfer failed");

        emit TransactionExecuted(txId);
    }

    // Accept ETH
    receive() external payable {}
}

