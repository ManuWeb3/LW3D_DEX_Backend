const { ethers } = require("hardhat")

const networkConfig = {
    
    31337: {
        name: "hardhat",
        // vrfCoordinatorV2: NOT needed here because we're deploying mocks on "hardhat" and "localhost"...
        // before the control reaches to the point of deploying BasicNft.sol and RandomIpfsNft.sol
        // entranceFee: ethers.utils.parseEther("0.01"),
        // gasLane: "0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc",  // anything here will work, value does not matter, bcz our mock will anyway mock the gasLane value
        // callbackGasLimit: "500000",                                                      // set high: 500,000 gas units, though it hardly matters here again
        // interval: "30",                                                                  // 30 seconds, it DOES matter here
        // subscriptionId: NOT needed here because we're deploying mocks on "hardhat" and "localhost"
        // mintFee: "10000000000000000",           // 0.01 ETH    
        // ethUsdPriceFeed: "we're gonna use Mock, hence, nothing required here"
    },
    5: {
        name: "goerli",
        // vrfCoordinatorV2: "0x2Ca8E0C643bDe4C2E08ab1fA0da3401AdAD7734D",
        // gasLane: "0x79d3d8832d904592c0bf9818b621522c988bb8b0c05cdc3b15aea1b6e8db0c15",
        // subscriptionId: "2034",         // new Id for Goerli needed                                               
        // callbackGasLimit: "500000",                                                     
        // interval: "30",                                                                  
        // mintFee: "10000000000000000",   // 0.01 Goerli ETH
        // ethUsdPriceFeed: "0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e",
    },

}
const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig, 
    developmentChains,
}