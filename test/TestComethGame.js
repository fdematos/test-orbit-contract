var ComethGame = artifacts.require("ComethGame")


let comethGameUtils = require('./ComethGameUtils')

contract('ComethGame', function(accounts) {
    it("should return correct cartesian coordinates", async function() {

        let instance = await ComethGame.deployed()

        let center = {x:"100", y:"50"}; 
        let last = {distance:"65", angle:"0"}; 
        let lastUpdate = "1607160213";
        let rotationSpeed =  "2";

        let orbit = {center: center, last: last, lastUpdate: lastUpdate, rotationSpeed:rotationSpeed};
        let requestTime = "1607160413"

        let coordinate = await instance.cartesianCoordinate(orbit, requestTime)
        let expectedCoordinate = comethGameUtils.calculateCoordonates(orbit, requestTime)
        assert.equal(coordinate[0], expectedCoordinate[0]);
        assert.equal(coordinate[1], expectedCoordinate[1]);
    })

    it("should add ship", async function() {  
        let instance = await ComethGame.deployed()

        let tokenId = 6000099
        let accountNumber = BigInt(accounts[0]);
       
        let sourceNumber = accountNumber + BigInt(tokenId)
        let expectedDistance = sourceNumber % BigInt(500)
        let expectedAngle = sourceNumber % BigInt(360)

        await instance.addShip(tokenId)

        let ships = await instance.shipsInGame()
        assert.equal(ships[0].orbit.last.angle, expectedAngle);
        assert.equal(ships[0].orbit.last.distance, expectedDistance);
    })

})