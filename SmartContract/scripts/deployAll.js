const { ethers } = require("hardhat");
const fs = require("fs");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // 1. Deploy Token
  const Token = await ethers.getContractFactory("Token");
  const token = await Token.deploy(deployer.address);
  await token.waitForDeployment();
  console.log("Token deployed to:", token.target);

  // 2. Deploy Notifications
  const Notifications = await ethers.getContractFactory("Notifications");
  const notifications = await Notifications.deploy();
  await notifications.waitForDeployment();
  console.log("Notifications deployed to:", notifications.target);

  // 3. Deploy Payments
  const Payments = await ethers.getContractFactory("Payments");
  const payments = await Payments.deploy(
    token.target,
    notifications.target,
    deployer.address
  );
  await payments.waitForDeployment();
  console.log("Payments deployed to:", payments.target);

  // 4. Deploy UserContract
  const UserContract = await ethers.getContractFactory("UserContract");
  const userContract = await UserContract.deploy(
    payments.target,
    notifications.target
  );
  await userContract.waitForDeployment();
  console.log("UserContract deployed to:", userContract.target);

  // 5. Deploy GameContract
  const GameContract = await ethers.getContractFactory("GameContract");
  const gameContract = await GameContract.deploy(
    deployer.address,
    notifications.target
  );
  await gameContract.waitForDeployment();
  console.log("GameContract deployed to:", gameContract.target);

  // 6. Deploy Leaderboard
  const Leaderboard = await ethers.getContractFactory("Leaderboard");
  const leaderboard = await Leaderboard.deploy(
    deployer.address,
    gameContract.target
  );
  await leaderboard.waitForDeployment();
  console.log("Leaderboard deployed to:", leaderboard.target);

  // 7. Deploy Election
  const Election = await ethers.getContractFactory("Election");
  const election = await Election.deploy(
    notifications.target,
    payments.target,
    userContract.target,
    token.target
  );
  await election.waitForDeployment();
  console.log("Election deployed to:", election.target);

  fs.writeFileSync(
    "contract-addresses.json",
    JSON.stringify({
      Election: election.target,
      Token: token.target,
      Notifications: notifications.target,
      Payments: payments.target,
      UserContract: userContract.target,
      GameContract: gameContract.target,
      Leaderboard: leaderboard.target
    }, null, 2)
  )
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });