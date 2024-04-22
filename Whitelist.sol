pragma solidity ^0.4.12;

import "./Ownable.sol";

// SPDX-License-Identifier: GPL-3.0


contract Whitelist is Ownable{


    // Whitelisted address
    mapping(address => bool) public whitelist;
    event AddedBeneficiary(address indexed _beneficiary);


    function isWhitelisted(address _beneficiary) internal view returns (bool) {
      return (whitelist[_beneficiary]);
    }


    /**
    * @dev Adds an address to the whitelist.
    * @param _beneficiary The address to be added to the whitelist.
    */
    function addToWhitelist(address _beneficiary) public onlyOwner {
        whitelist[_beneficiary] = true;
    }



    /**
     * @dev Removes single address from whitelist.
     * @param _beneficiary Address to be removed to the whitelist
     */
    function removeFromWhitelist(address _beneficiary) public onlyOwner {
      whitelist[_beneficiary] = false;
    }
  }
