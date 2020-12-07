const RealMath = artifacts.require("RealMath");
const ComethGame = artifacts.require("ComethGame");

module.exports = function (deployer) {
  deployer.deploy(RealMath);
  deployer.link(RealMath, ComethGame);
  deployer.deploy(ComethGame);
};
