// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract AugmentedFaucet {
    // Montant maximum de retrait fixé à 0.01 ether
    uint256 public constant MAX_AMOUNT = 0.01 ether;
    // Nombre maximum d'utilisateurs uniques autorisés
    uint256 public constant MAX_USERS = 4;
    // Adresse du propriétaire (déployeur)
    address public owner;

    // Mapping pour savoir si une adresse a déjà retiré
    mapping(address => bool) public userWithdrawn;
    // Liste des utilisateurs ayant retiré
    address[] public userList;
    
    // Constructeur : définit le propriétaire
    constructor() {
        owner = msg.sender;
    }
    
    // Permet de recevoir de l'ETH
    receive() external payable {}

    // Fonction de dépôt (optionnelle)
    function deposit() external payable {
        // ETH ajouté automatiquement au solde du contrat.
    }
    
    // Fonction de retrait
    function withdraw(uint256 amount) external {
        require(amount <= MAX_AMOUNT, "Amount exceeds max allowed");
        require(address(this).balance >= amount, "Insufficient contract balance");
        
        // Si l'utilisateur n'a pas encore retiré, on l'enregistre
        if (!userWithdrawn[msg.sender]) {
            require(userList.length < MAX_USERS, "Max users reached");
            userWithdrawn[msg.sender] = true;
            userList.push(msg.sender);
        }
        payable(msg.sender).transfer(amount);
    }
    
    // Modifier : accès réservé au propriétaire
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    // Réinitialise la liste des utilisateurs (seulement par le propriétaire)
    function resetUsers() external onlyOwner {
        for (uint i = 0; i < userList.length; i++) {
            userWithdrawn[userList[i]] = false;
        }
        delete userList;
    }
}