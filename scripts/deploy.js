async function main() {
    const MicaUSD = await ethers.getContractFactory("MicaUSD");
  
    const micaUSD = await MicaUSD.deploy();
  
    await micaUSD.deployed();
  
    console.log("MicaUSD desplegado a:", micaUSD.address);
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  