pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract XYZ is ERC20, Ownable {
    uint constant numAddress = 10;
    mapping(address => uint) public vestedBalanceLeft;
    uint public creationTime;
    uint tokenToDisperse;

    constructor(address[numAddress] memory _disperseAddresses) ERC20("XYZ Token", "XYZ"){
    creationTime = block.timestamp;
        uint256 amount = 100 * 1000000;
        _mint(address(this), amount);
        tokenToDisperse = amount / numAddress;
        for(uint i = 0; i < numAddress; i++)    {
            vestedBalanceLeft[_disperseAddresses[i]] = tokenToDisperse;
        }
    }

    function contractBalance() view external returns(uint) {
        return balanceOf(address(this));
    }

    function getVestedBalance() external payable{
        require(vestedBalanceLeft[msg.sender] != 0, "Zero Balance left");
        uint timeV = 365 days;
        if(block.timestamp - creationTime >= timeV) {
            _transfer(address(this), msg.sender, vestedBalanceLeft[msg.sender]);
            vestedBalanceLeft[msg.sender] = 0;
        }
        else {
            uint tokens = tokenToDisperse - ((block.timestamp - creationTime) * tokenToDisperse) / timeV;
            if(vestedBalanceLeft[msg.sender] >= tokens) {
                _transfer(address(this), msg.sender, vestedBalanceLeft[msg.sender] - tokens);
                vestedBalanceLeft[msg.sender] = tokens;
            }
        }
    }
}
