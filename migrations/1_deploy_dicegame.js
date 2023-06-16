const fs = require("fs");

const DiceGame = artifacts.require("DiceGame");

module.exports = async function (deployer) {
  await deployer.deploy(DiceGame);

  const instance = await DiceGame.deployed();

  let diceGameAdress = await instance.address;

  console.log("diceGameAdress = ", diceGameAdress);

  let config = "export const diceGameAdress = ${diceGameAdress} ";

  let data = JSON.stringify(config);

  fs.writeFileSync("config.js", JSON.parse(data));
};
