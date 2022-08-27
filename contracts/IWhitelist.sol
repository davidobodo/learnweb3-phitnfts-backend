// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Creating an interface because we only need the mapping function. This way we save gas by not inheriting the entire whitelist contract but only the mapping portion we need 

interface IWhitelist {
    function whitelistedAddresses(address) external view returns (bool);
}