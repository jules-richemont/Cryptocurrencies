// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract Faucet {
    // Montant maximum de retrait fixé à 0.01 ether
    uint256 public constant MAX_AMOUNT = 0.01 ether;
    
    // Permet de recevoir de l'ETH automatiquement
    receive() external payable {}

    // Fonction de dépôt (optionnelle)
    function deposit() external payable {
        // L'ETH envoyé est automatiquement ajouté au contrat.
    }

    // Fonction de retrait
    function withdraw(uint256 amount) external {
        require(amount <= MAX_AMOUNT, "Amount exceeds max allowed");
        require(address(this).balance >= amount, "Insufficient contract balance");
        payable(msg.sender).transfer(amount);
    }
}