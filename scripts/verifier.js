const { ethers } = require("hardhat");

async function main() {
    // We get the contract to deploy
    const Tier        = await ethers.getContractFactory("LighthouseTier");
    const Wrapper     = await ethers.getContractFactory("LighthouseTierWrapper");
    let tier;
    let wrapper;

    let deployer      = await ethers.getSigner();
    let chainID       = await deployer.getChainId();

    console.log(deployer.address);

    // Constructor arguments
    let fees;

    if (chainID == 1287) {
    } else if (chainID == 1285) {
        tier = await Tier.attach('0x59d1AF5D6CDC26c2F98c78fED5E55f11157Db8cF')
        wrapper = await Wrapper.attach('0x95031b2b24B350CB30D30df7B1Cd688255BE839a')

        let verifier = await tier.claimVerifier();
        console.log(`Tier Verifier address ${verifier}`);

        let setTx = await wrapper.setClaimVerifier(verifier);
        console.log(`Tier wrapper verifier was set to ${verifier} on ${setTx.hash}`);
    }
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });