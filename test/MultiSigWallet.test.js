const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MultiSigWallet", () => {
    let wallet, signers, nonSigner;

    beforeEach(async () => {
        const accounts = await ethers.getSigners();
        signers = accounts.slice(0, 3);
        nonSigner = accounts[3];

        const MultiSigWallet = await ethers.getContractFactory("MultiSigWallet");
        wallet = await MultiSigWallet.deploy(
            [signers[0].address, signers[1].address, signers[2].address],
            2
        );
        await wallet.deployed();

        // Fund contract with ETH
        await signers[0].sendTransaction({
            to: wallet.address,
            value: ethers.utils.parseEther("10"),
        });
    });

    it("should allow a signer to propose and approve a transaction", async () => {
        const to = signers[2].address;
        const value = ethers.utils.parseEther("1");

        const tx = await wallet.connect(signers[0]).proposeTransaction(to, value);
        const receipt = await tx.wait();
        const txId = receipt.events[0].args.txId;

        await expect(wallet.connect(signers[1]).approveTransaction(txId))
            .to.emit(wallet, "TransactionExecuted")
            .withArgs(txId);
    });

    it("should reject approval from non-signer", async () => {
        const txId = await wallet.connect(signers[0]).proposeTransaction(signers[2].address, 1);
        await expect(wallet.connect(nonSigner).approveTransaction(0)).to.be.revertedWith("Not authorized signer");
    });

    it("should not allow duplicate approvals", async () => {
        const txId = await wallet.connect(signers[0]).proposeTransaction(signers[1].address, 1);
        await wallet.connect(signers[1]).approveTransaction(0);
        await expect(wallet.connect(signers[1]).approveTransaction(0)).to.be.revertedWith("Already approved");
    });

    it("should not execute without enough approvals", async () => {
        const txId = await wallet.connect(signers[0]).proposeTransaction(signers[1].address, 1);
        await wallet.connect(signers[0]).approveTransaction(0);
        const txn = await wallet.transactions(0);
        expect(txn.executed).to.be.false;
    });
});

