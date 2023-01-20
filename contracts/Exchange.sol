// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    // needed for a couple of things
    // 1. CD token is an ERC20 one
    // 2. input this address and check the balanceOf(thisContract)
    address public cryptoDevTokenAddress;

    constructor (address _CryptoDevToken) ERC20 ("CryptoDev LP Token", "CDLP") {
        require(_CryptoDevToken != address(0), "Token address passed is a null address");
        cryptoDevTokenAddress = _CryptoDevToken;
    }
    
    /**
    * @dev Returns the amount of `Crypto Dev Tokens` held by the contract
    */

    function getReserve() public view returns (uint256) {
        return ERC20(cryptoDevTokenAddress).balanceOf(address(this));
    }

    /**
    * @dev Adds liquidity to the exchange.
    */
   // i/p "_amount" refers to the CD Tokens being deplosited by the LP
   function addLiquidity(uint256 _amount) public payable returns (uint) {
        uint256 liquidity;      // if() else() = CD LP tokens to be minted to LP
        uint256 ethBalance = address(this).balance;     
        // later on, addLiquidity(), ethReserve will differ from initial ethBalance
        uint256 cryptoDevTokenReserve = getReserve();   // CD Reserve
        ERC20 cryptoDevToken = ERC20(cryptoDevTokenAddress);    // slightly diff. names/identifiers used elsewhere
        /*
        If the reserve is empty, intake any user supplied value for
        `Ether` and `Crypto Dev` tokens because there is no ratio currently
        */
       if(cryptoDevTokenReserve == 0) {
        // Transfer the `cryptoDevToken` from the user's account to the contract
        // transferFrom() will revert if approval not set
        // this will be set in a JS script as Patrick did in AAVE's DeFi project
        // not done anywhere min Solidity - REMEMBER this
        cryptoDevToken.transferFrom(msg.sender, address(this), _amount);
        // _amount is the CD token itself whose obj is created and initialized above to exec transferFrom()
        // as this is exactly how it's done in Remix's interface

        // `liquidity` provided is equal to `ethBalance` because this is the first time user
        // is adding `Eth` to the contract, so whatever `Eth` contract has is equal to the one supplied
        // by the user in the current `addLiquidity` call
        // `liquidity` tokens that need to be minted to the user on `addLiquidity` call should always be proportional
        // to the Eth specified by the user
        // liquidity = "amount of LP tokens" (not full tokens, it'll be = wei)
        // bcz ETH internally works as wei with address(this).balance
        liquidity = ethBalance;
        // msg.sender = LProvider here
        // _mint() will mint 'liquidity' amount of tokens...which ones... 
        // the ones created by the constructor during deployment
        _mint(msg.sender, liquidity);
       }
       else {
        /*
            If the reserve is not empty, intake any user supplied value for
            `Ether` and determine according to the ratio how many `Crypto Dev` tokens
            need to be supplied to prevent any large price impacts because of the additional
            liquidity
        */
        // EthReserve should be the current ethBalance subtracted by the value of ether sent by the user
        // in the current `addLiquidity` call
        // that's why, we already calculated ethBalance = address(this).bal
        // as it will be needed everytime the addLiq() execs
        // ethBal instantly takes in payable-ether transfered by user to the contract
        // in address(this).bal 
        // ethReserve actually points to the value of eth stored in contract right before this txn ran by the user/LP
            uint256 ethReserve = ethBalance - msg.value;
         // Ratio should always be maintained so that there are no major price impacts when adding liquidity
         // Ratio here is 
         // -> (cryptoDevTokenAmount user can add/cryptoDevTokenReserve in the contract) = (Eth Sent by the user/Eth Reserve in the contract);
         // So doing some maths, (cryptoDevTokenAmount user can add) = (Eth Sent by the user * cryptoDevTokenReserve /Eth Reserve);

         // cryptoDevTokenAmount- what an LP can deposit, IDEALLY, MINIMUM this should be the _amount else revert 
         // cryptoDevTokenReserve - by getReserve();
         uint256 cryptoDevTokenAmount = (msg.value/ethReserve)*cryptoDevTokenReserve;
        require(_amount >= cryptoDevTokenAmount, "Amount of tokens sent is less than the minimum tokens required");
        // transfer only (cryptoDevTokenAmount user can add) amount of `Crypto Dev tokens` from users account
        // to the contract

        // INTERNAL TXN
        cryptoDevToken.transferFrom(msg.sender, address(this), cryptoDevTokenAmount);
        // calc. liquidity = LP tokens to be minted to the LProvider thru _mint()
        liquidity = totalSupply() * (msg.value/ethReserve);
        // the golden ratio * _totalSupply of LP tokens out there in the open market held by LPs will be minted to the current LP
        _mint(msg.sender, liquidity);
        }
        return liquidity;
        // returning uint256
   }

   /**
    * @dev Returns the amount Eth/Crypto Dev tokens that would be returned to the user
    * in the swap of CD LP tokens with user-funds
    */
   function removeLiquidity(uint _amount) public returns (uint , uint) {
    require(_amount > 0, "_amount should be greater than zero");

    uint ethReserve = address(this).balance;        // current
    uint _totalSupply = totalSupply();              // current
    // The amount of Eth that would be sent back to the user is based
    // on a ratio
    // Ratio is -> (Eth sent back to the user) / (current Eth reserve)
    // = (amount of LP tokens that user wants to withdraw) / (total supply of LP tokens)
    // Then by some maths -> (Eth sent back to the user)
    // = (current Eth reserve * amount of LP tokens that user wants to withdraw) / (total supply of LP tokens)
    uint ethAmount = (ethReserve * _amount)/ _totalSupply;                  // formulae # 1, later transfer
    // The amount of Crypto Dev token that would be sent back to the user is based
    // on a ratio
    // Ratio is -> (Crypto Dev sent back to the user) / (current Crypto Dev token reserve)
    // = (amount of LP tokens that user wants to withdraw) / (total supply of LP tokens)
    // Then by some maths -> (Crypto Dev sent back to the user)
    // = (current Crypto Dev token reserve * amount of LP tokens that user wants to withdraw) / (total supply of LP tokens)
    uint cryptoDevTokenAmount = (getReserve() * _amount)/ _totalSupply;     // formulae # 2, later transfer
    // Burn the sent LP tokens from the user's wallet because they are already sent to
    // remove liquidity
    _burn(msg.sender, _amount);         // burn(), as opposed to _mint()
    //---------------------------
    // TRANSFER # 1: (ETH != ERC20 token, hence .call{}() used)
    // Transfer `ethAmount` of Eth from the contract to the user's wallet
    // instead, sue .call{}("")
    
    // that's how we coded the transfer of ethAmount from within a contract to an EOA
    payable(msg.sender).transfer(ethAmount);
    
    // TRANSFER # 2: (ERC20 token != ETG, hence, use a f() of ERC20 token std.)
    // Transfer `cryptoDevTokenAmount` of Crypto Dev tokens from the contract to the user's wallet
    // .transfer's msg.sender is the contract itself (sender/from)
    // "msg.sender" below is the user/to who invoked the f() removeLiq()
    
    // that's how we coded to send ERC20 tokens from inside a contract to an EOA
    ERC20(cryptoDevTokenAddress).transfer(msg.sender, cryptoDevTokenAmount);
    //---------------------------
    return (ethAmount, cryptoDevTokenAmount);
    }

    
}
