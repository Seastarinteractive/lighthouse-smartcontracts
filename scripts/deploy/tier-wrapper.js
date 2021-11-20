const { ethers } = require("hardhat");

async function main() {
    // We get the contract to deploy
    const Tier        = await ethers.getContractFactory("LighthouseTierWrapper");

    let deployer      = await ethers.getSigner();
    let chainID       = await deployer.getChainId();

    console.log(`Sign with ${deployer.address}`);

    // Constructor arguments
    let crowns;
    let claimVerifier;
    let fees;
    let tierAddress;

    if (chainID == 1287) {
      crowns          = "0xFde9cad69E98b3Cc8C998a8F2094293cb0bD6911";
      claimVerifier   = process.env.MOONBEAM_DEPLOYER_ADDRESS;
      tierAddress     = "0x1BB55D99aAF303A1586114662ef74638Ed9dB2Ee";
      fees            = [                       // Tier claiming fees
        ethers.utils.parseEther("0.1", 18),     // Tier 0
        ethers.utils.parseEther("0.25", 18),    // Tier 1
        ethers.utils.parseEther("0.5", 18),     // Tier 2
        ethers.utils.parseEther("1", 18),       // Tier 3
      ];
    } else if (chainID == 1285) {
      crowns          = "0x6fc9651f45B262AE6338a701D563Ab118B1eC0Ce";
      claimVerifier   = "0xb7fA673753c321f14733Eff576bC0d8E644e455e";
      tierAddress     = "0x95031b2b24B350CB30D30df7B1Cd688255BE839a";
      fees            = [                     // Tier claiming fees
        ethers.utils.parseEther("1", 18),      // Tier 0
        ethers.utils.parseEther("5", 18),      // Tier 1
        ethers.utils.parseEther("10", 18),     // Tier 2
        ethers.utils.parseEther("20", 18),     // Tier 3
      ];
    }

    let gasPrice    = 200000000000;                                    // 20 gwei

    const tier       = await Tier.deploy(crowns, tierAddress, claimVerifier, fees, chainID, {gasPrice: gasPrice});

    console.log(`Lighthouse Tier Wrapper deployed to: ${tier.deployTransaction.hash}`, tier.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });