// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract VickreyAuction {
    // Nombre maximum d'enchérisseurs
    uint256 public constant MAX_BIDS = 4;
    // Adresse du propriétaire
    address public owner;
    // Indique si l'enchère est terminée
    bool public auctionEnded;
    // Liste des adresses qui ont enchéri
    address[] public bidders;
    // Montants enchéris par adresse
    mapping(address => uint256) public bids;
    // Adresse du gagnant
    address public winner;
    // Montant gagnant (la deuxième enchère la plus élevée)
    uint256 public winningBid;

    // Constructeur : définit le propriétaire et initialise l'enchère
    constructor() {
        owner = msg.sender;
        auctionEnded = false;
    }
    
    // Permet de placer une enchère en envoyant de l'ETH
    function bid() external payable {
        require(!auctionEnded, "Auction has ended");
        require(msg.value > 0, "Bid must be greater than 0");
        require(bids[msg.sender] == 0, "You have already bid");
        
        bidders.push(msg.sender);
        bids[msg.sender] = msg.value;
        
        // Si le nombre maximum d'enchérisseurs est atteint, l'enchère se termine
        if (bidders.length == MAX_BIDS) {
            auctionEnded = true;
        }
    }
    
    // Finalise l'enchère et détermine le gagnant (appelé par le propriétaire)
    function finalizeAuction() external {
        require(msg.sender == owner, "Only owner can finalize");
        require(auctionEnded, "Auction not ended");
        require(bidders.length == MAX_BIDS, "Not enough bidders");
        
        address highestBidder;
        uint256 highest = 0;
        uint256 secondHighest = 0;
        // Recherche de la plus haute et de la deuxième plus haute enchère
        for (uint i = 0; i < bidders.length; i++) {
            uint256 currentBid = bids[bidders[i]];
            if (currentBid > highest) {
                secondHighest = highest;
                highest = currentBid;
                highestBidder = bidders[i];
            } else if (currentBid > secondHighest) {
                secondHighest = currentBid;
            }
        }
        winner = highestBidder;
        winningBid = secondHighest;
        
        // Rembourse la différence au gagnant (s'il a surpayé)
        uint256 refund = bids[winner] - winningBid;
        if (refund > 0) {
            payable(winner).transfer(refund);
            bids[winner] = winningBid;
        }
        
        // Rembourse les autres enchérisseurs
        for (uint i = 0; i < bidders.length; i++) {
            address bidder = bidders[i];
            if (bidder != winner) {
                uint256 amount = bids[bidder];
                if (amount > 0) {
                    payable(bidder).transfer(amount);
                    bids[bidder] = 0;
                }
            }
        }
    }
    
    // Le propriétaire peut retirer les fonds collectés
    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw");
        require(auctionEnded, "Auction not ended");
        uint256 amount = address(this).balance;
        require(amount > 0, "No funds to withdraw");
        payable(owner).transfer(amount);
    }
    
    // Réinitialise l'enchère pour une nouvelle session (seulement par le propriétaire)
    function resetAuction() external {
        require(msg.sender == owner, "Only owner can reset");
        require(auctionEnded, "Auction not ended");
        for (uint i = 0; i < bidders.length; i++) {
            bids[bidders[i]] = 0;
        }
        delete bidders;
        winner = address(0);
        winningBid = 0;
        auctionEnded = false;
    }
}