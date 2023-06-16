const { beforeEach } = require("mocha");

const DiceGame = artifacts.require("DiceGame");

contract("DiceGame", (accounts) => {
  let diceGame;
  let owner = accounts[0];
  let user1 = accounts[1];
  let user2 = accounts[2];

  beforeEach(async () => {
    diceGame = await DiceGame.new();
  });

  it("should allow players to play the game", async () => {
    const player = accounts[1];

    await diceGame.play({
      from: player,
      value: web3.utils.toWei("0.001", "ether"),
    });

    //console.log(`******** play pressed******* `);

    const contractBalance = await web3.eth.getBalance(diceGame.address);

    //console.log(`********contract balance****** ${contractBalance} `);

    assert.equal(
      contractBalance,
      web3.utils.toWei("0.001", "ether"),
      "Process not successfull"
    );
  });

  it("should allow players to withdraw", async () => {
    const player = accounts[1];

    let playerBalance = await diceGame.playerBalances(player);
    console.log(`Initial player balance: ${playerBalance}`);

    //continues until the player win
    while (playerBalance == 0) {
      await diceGame.play({
        from: player,
        value: web3.utils.toWei("0.001", "ether"),
      });
      playerBalance = await diceGame.playerBalances(player);
      console.log(`Player balance: ${playerBalance}`);
    }

    await diceGame.withdraw({ from: player });

    const finalBalance = await diceGame.playerBalances(player);

    assert.equal(finalBalance.toString(), "0");
  });
});
