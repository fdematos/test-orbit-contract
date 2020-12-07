var ComethGame = artifacts.require("ComethGame")

contract('ComethGame', function(accounts) {
    it("should return correct cartesian coordinates", async function() {

        let instance = await ComethGame.deployed()

        let center = ["100", "50"]; //X, Y
        let last = ["65", "0"]; // Distance, angle
        let lastUpdate = "1607160213";
        let rotationSpeed =  "2";

        let orbit = [center, last, lastUpdate, rotationSpeed];
        let requestTime = "1607160413"

        let coordinate = await instance.cartesianCoordinate(orbit, requestTime)
        assert.equal(coordinate[0], 55);
        assert.equal(coordinate[1], 95);
    })

})