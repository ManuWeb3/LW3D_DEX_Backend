const {run} = require("hardhat")

const verify = async (contractAddress, args) => {               // verify() takes 2 args: 1. Contract address, 2. args - constructor args
    console.log("Verifying the contract, please wait...")
    try {
    await run("verify:verify", {    //  seems like this "verify" keyword here does the "under the hood" verification work using ETHERSCAN_API_KEY
                                      
      address: contractAddress,
      constructorArguments: args,   //  what this constructorArguments: args is doing here??
                                    //  I believe - it's taking in those args that's required to be passed into the Constructor of Raffle.sol while deploying
  })}
  
  catch (e) {

    if(e.message.toLowerCase().includes("already verified")) {
        console.log("Already Verified")
      }
      else {
        console.log(e)
      }
    }
} // body of verify
      
module.exports = {verify}