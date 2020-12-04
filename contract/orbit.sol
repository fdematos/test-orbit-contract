pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./realmath.sol";

struct Orbit  { 
      Cartesian center;
      Polar last;
      uint lastUpdate;
}

struct Polar { 
        uint32 distance;
        uint16 angle;
    }
    
    struct Cartesian { 
        int x;
        int y;
    }
    
    
struct Ship { 
    string modelId;
    Orbit orbit;
       
}
    
struct Comet { 
    address cometAddr;
    Orbit orbit;
}
    
contract ComethGame {
    
    using RealMath for *;
        
    event ShipMove(string indexed _modelId,  uint _block, uint32  _distance, uint16 _angle);
    
    // Degree by second
    uint16 public rotationSpeed = 1;
    uint8 public shipMiningArea = 10;
    
    mapping (string => Orbit) private shipOrbits;
    Ship[] private _ships;
    
    mapping (address => Orbit) private comethOrbits;
    Comet[] private _comets;
     
     
     function shipPosition(string memory modelId, uint time) public view returns (Cartesian memory position){
         
         if (time == 0) {
            return cartesianCoordinate(shipOrbits[modelId], block.timestamp);
         }
         
        return cartesianCoordinate(shipOrbits[modelId], time);
     }
     
     function cometPosition(address cometAddr, uint time) public view returns (Cartesian memory position){
         if (time == 0) {
            return cartesianCoordinate(comethOrbits[cometAddr], block.timestamp);
         }
         
         return cartesianCoordinate(comethOrbits[cometAddr], time);
     }
     
     
    function canMine(string memory modelId, address cometAddr, uint time) public view returns (bool result){
        Cartesian memory ship = shipPosition(modelId, time);
        Cartesian memory comet = cometPosition(cometAddr, time);
     
        int minX = ship.x - shipMiningArea;
        int maxX = ship.x + shipMiningArea;
        
        int minY = ship.y - shipMiningArea;
        int maxY = ship.y + shipMiningArea;
        
        return comet.x <= maxX && comet.x  >= minX && comet.y <= maxY && comet.y >= minY;
    }
     
     
    function cartesianCoordinate(Orbit memory orbit, uint time) internal view returns (Cartesian memory position) {
        uint timeDiff = time - orbit.lastUpdate;
        int88 currentAngleDegree = int88((orbit.last.angle + timeDiff * rotationSpeed) % 360);
        int128 currentAngleReal = currentAngleDegree.toReal();
         
        int128 halfCirleReal = int88(180).toReal();
         
        int128 currentAngleRadians = currentAngleReal.mul(RealMath.REAL_PI).div(halfCirleReal);
         
        int128 angleCos = currentAngleRadians.cos();
        int128 angleSin = currentAngleRadians.sin();
         
        int128 distanceReal = orbit.last.distance.toReal();
         
        int x = distanceReal.mul(angleCos).fromReal() + orbit.center.x;
        int y = distanceReal.mul(angleSin).fromReal() + orbit.center.y;
        
         return Cartesian({x: x, y: y});
    }
    
    function addShip (string memory modelId) public {
         uint256 addressToUint = uint256(msg.sender);
         
         uint32 distance = uint32(addressToUint % 500);
         uint16 angle = uint16(addressToUint % 360);
         
         Orbit memory orbit = Orbit({center: Cartesian({x:0, y:0}), 
                                     last: Polar({angle:angle, distance:distance}), 
                                     lastUpdate: block.timestamp});
         
         shipOrbits[modelId] = orbit;
         _ships.push(Ship({modelId: modelId, orbit: orbit}));
         
         emit ShipMove(modelId, block.number, distance, angle);
    }
    
    
      function addComet (address cometAddr, int x, int y, uint32 distance) public {
         Orbit memory orbit = Orbit({center:  Cartesian({x:x, y:y}), 
                                     last: Polar({angle:0, distance:distance}), 
                                     lastUpdate: block.timestamp});
         
         comethOrbits[cometAddr] = orbit;
         _comets.push(Comet({cometAddr: cometAddr, orbit: orbit}));
    }
    
    function shipsInGame() public view returns (Ship[] memory ships)  {
        return  _ships;
    }
    
    function cometsInGame() public view returns (Comet[] memory comets)  {
        return  _comets;
    }
    
}

// SPDX-License-Identifier: MIT