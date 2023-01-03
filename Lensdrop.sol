// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/IERC1155Upgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Lensdrop {
    struct EscrowDetails {
        address user;
        address token;
        bool paid;
        string publicationId;
        uint256 amount;
        uint256 noOfRecipients;
    }
    mapping(uint256 => EscrowDetails) public Escrows;
    mapping(address => uint256[]) public Users;
    uint256 public totalEscrows;

    receive() external payable {}

    function batchSendERC20(address[] memory recipients, uint256 amount, address tokenAddress) 
        external {
            IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);

            for (uint256 i=0; i<recipients.length; i++) {
               token.transferFrom(msg.sender, recipients[i], amount);
            }
    }

    function batchSendERC721(address tokenAddress, address[] memory recipients, uint256[] memory tokenIds)
        external {
            require(recipients.length == tokenIds.length, "number of recipients and token ids do not match");
            IERC721Upgradeable token = IERC721Upgradeable(tokenAddress);

            for (uint256 i=0; i<recipients.length; i++) {
                token.transferFrom(msg.sender, recipients[i], tokenIds[i]);
            }
    }

    function batchSendERC1155(address tokenAddress, address[] memory recipients, uint256[] memory tokenIds)
        external {
            require(recipients.length == tokenIds.length, "number of recipients and token ids do not match");
            IERC1155Upgradeable token = IERC1155Upgradeable(tokenAddress);

            for (uint256 i=0; i<recipients.length; i++) {
                token.safeTransferFrom(msg.sender, recipients[i], tokenIds[i], 1, "");
            }
    }

    modifier nativeHelper (address[] memory recipients, uint256 amount) {     
        uint256 totalAmount = recipients.length * amount;
        require(msg.value >= totalAmount, "Insufficient token");

        if (msg.value > totalAmount) {
            payable(msg.sender).transfer(msg.value - totalAmount);
        }
        _;
    }

    function batchSendNativeToken(address[] memory recipients, uint256 amount) payable
        nativeHelper(recipients, amount) external {
            for (uint256 i=0; i<recipients.length; i++) {
                payable(recipients[i]).transfer(amount);
            }       
    }

    function escrowTokens(string memory publicationId, uint256 amount, uint256 noOfRecipients) public payable {
        require(msg.value >= (amount * noOfRecipients));

        Escrows[totalEscrows].user = msg.sender;
        Escrows[totalEscrows].publicationId = publicationId;
        Escrows[totalEscrows].amount = amount;
        Escrows[totalEscrows].noOfRecipients = noOfRecipients;

        Users[msg.sender].push(totalEscrows);
        totalEscrows++;
    }

    function escrowErc20Tokens(string memory publicationId, address tokenAddress, uint256 amount, uint256 noOfRecipients) public payable {
        IERC20Upgradeable token = IERC20Upgradeable(tokenAddress);
        token.transferFrom(msg.sender, address(this), amount * noOfRecipients);

        Escrows[totalEscrows].user = msg.sender;
        Escrows[totalEscrows].publicationId = publicationId;
        Escrows[totalEscrows].token = tokenAddress;
        Escrows[totalEscrows].amount = amount;
        Escrows[totalEscrows].noOfRecipients = noOfRecipients;

        Users[msg.sender].push(totalEscrows);
        totalEscrows++;
    }

    function reward(uint256 id, address[] memory recipients) public {
        require(recipients.length == Escrows[id].noOfRecipients);
        require(msg.sender == Escrows[id].user);
        for (uint256 i=0; i<recipients.length; i++) {
            payable(recipients[i]).transfer(Escrows[id].amount);
        }
    }

    function rewardTokens(uint256 id, address[] memory recipients) public {
        require(recipients.length == Escrows[id].noOfRecipients);
        require(msg.sender == Escrows[id].user);
        IERC20Upgradeable token = IERC20Upgradeable(Escrows[id].token);
        for (uint256 i=0; i<recipients.length; i++) {
            token.transfer(recipients[i], Escrows[id].amount);
        }
    }
}