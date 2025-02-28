/*
This file is part of the NFT Protect project <https://nftprotect.app/>

The UserRegistry Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The UserRegistry Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the UserRegistry Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <is.svirin@gmail.com>
*/
// SPDX-License-Identifier: GNU lesser General Public License


pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./iuserregistry.sol";
import "./arbitratorregistry.sol";
import "./iarbitrableproxy.sol";
import "./idiscounter.sol";

contract UserRegistry is Ownable, IUserRegistry
{
    using Address for address payable;

    event Deployed();
    event ArbitratorRegistryChanged(address areg);
    event AffiliatePercentChanged(uint8 percent);
    event AffiliatePayment(address indexed from, address indexed to, uint256 amountWei);
    event FeeChanged(FeeType indexed feeType, uint256 feeWei);
    event ReferrerSet(address indexed user, address indexed referrer);
    event PartnerSet(address indexed partner, uint8 discount, uint8 affiliatePercent);
    event PartnerDeleted(address indexed partner);

    modifier onlyNFTProtect()
    {
        require(_msgSender() == nftprotect);
        _;
    }

    address            public   nftprotect;
    ArbitratorRegistry public   arbitratorRegistry;
    uint8              public   affiliatePercent;

    mapping(address => address payable) public referrers;
    mapping(address => Partner) public partners;
    mapping(address => bool) public hasProtections;
    uint256[3] public fees; // [FeeType]

    struct Partner
    {
        bool            isRegistered;
        uint8           discount;
        uint8           affiliatePercent;
    }

    constructor(address areg, address nftprotectaddr)
    {
        emit Deployed();
        nftprotect = nftprotectaddr;
        setFee(FeeType.Entry, 0);
        setFee(FeeType.OpenCase, 0);
        setFee(FeeType.FetchRuling, 0);
        setAffiliatePercent(0);
        setArbitratorRegistry(areg);
    }

    function setFee(FeeType feeType, uint256 fw) public onlyOwner
    {
        fees[uint256(feeType)] = fw;
        emit FeeChanged(feeType, fw);
    }

    function setArbitratorRegistry(address areg) public onlyOwner
    {
        arbitratorRegistry = ArbitratorRegistry(areg);
        emit ArbitratorRegistryChanged(areg);
    }

    function setAffiliatePercent(uint8 percent) public onlyOwner
    {
        affiliatePercent = percent;
        emit AffiliatePercentChanged(percent);
    }

    function setPartner(address partner, uint8 discount, uint8 affPercent) public onlyOwner {
        require(discount <= 100, "UserRegistry: Invalid discount");
        partners[partner] = Partner(
            true,
            discount,
            affPercent
        );
        emit PartnerSet(partner, discount, affPercent);
    }

    function deletePartner(address partner) public onlyOwner {
        delete partners[partner];
        emit PartnerDeleted(partner);
    }

    function feeForUser(address user, FeeType feeType) public view returns(uint256) {
        uint256 fee = fees[uint256(feeType)];
        if (fee == 0) {
            return 0;
        }
        // Discount only on entry
        if (feeType == FeeType.Entry) {
            uint8 discount = partners[user].discount;
            return fee * (100 - discount) / 100;
        } else {
            return fee;
        }
    }

    // Internal function to process affiliate payment
    function _processAffiliatePayment(address user, address payable referrer, uint256 finalFee) internal returns (uint256) {
        require(referrer != user, "UserRegistry: invalid referrer");
        if (referrer == address(0)) {
            return finalFee;
        }
        uint8 ap = partners[referrer].affiliatePercent > 0 ? partners[referrer].affiliatePercent : affiliatePercent;
        uint256 affiliatePayment = finalFee * ap / 100;
        if (affiliatePayment > 0) {
            referrer.sendValue(affiliatePayment);
            emit AffiliatePayment(user, referrer, affiliatePayment);
        }
        return finalFee - affiliatePayment;
    }

    function _handlePayment(address sender, address user, FeeType feeType, uint256 value) internal {
        address referrer = referrers[user];
        // Get fee with partner's discount applied
        uint256 finalFee = feeForUser(sender, feeType);

        // Set hasProtections
        if (feeType == FeeType.Entry && !hasProtections[user]) {
            hasProtections[user] = true;
        }

        require(value == finalFee, "UserRegistry: Incorrect payment amount");
        // If there's no fee, then just exit
        if (finalFee == 0) {
            return;
        }

        // Process affiliate payment if there's a referrer
        // And FeeType is entry
        uint256 restFinalFee = ( referrer != address(0) && feeType == FeeType.Entry ) ?
            _processAffiliatePayment(user, payable(referrer), finalFee) :
            finalFee;

        // Transfer the remaining fee to the contract owner
        if (restFinalFee > 0) {
            payable(owner()).sendValue(finalFee);
        }
    }

    function processPayment(address sender, address user, address payable referrer, FeeType feeType) public override payable onlyNFTProtect
    {
        // Set referrer only if not set yet and not null and user has no protections
        if (referrers[user] == address(0) && referrer != address(0) && !hasProtections[user])
        {
            referrers[user] = referrer;
            emit ReferrerSet(user, referrer);
        }

        _handlePayment(sender, user, feeType, msg.value);
    }

}
