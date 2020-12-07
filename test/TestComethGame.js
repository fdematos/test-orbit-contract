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

})