const { expect } = require("chai");

describe("MicaUSD Contract", function () {
  let MicaUSD;
  let micaUSD;
  let owner;
  let addr1;
  let addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    MicaUSD = await ethers.getContractFactory("MicaUSD");
    micaUSD = await MicaUSD.deploy();
    await micaUSD.deployed();
  });

  it("El contrato se despliega con el propietario correcto", async function () {
    expect(await micaUSD.owner()).to.equal(owner.address);
  });

  it("Debería transferir tokens entre cuentas", async function () {
    await micaUSD.transfer(addr1.address, 50);
    const balanceAddr1 = await micaUSD.balanceOf(addr1.address);
    expect(balanceAddr1).to.equal(50);
  });

  it("Debería fallar si no hay suficientes tokens para transferir", async function () {
    const initialOwnerBalance = await micaUSD.balanceOf(owner.address);

    await expect(micaUSD.connect(addr1).transfer(owner.address, 1)).to.be.revertedWith("Not enough tokens");

    expect(await micaUSD.balanceOf(owner.address)).to.equal(initialOwnerBalance);
  });
});
