pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./realmath.sol";

struct Orbit  { 
      Cartesian center;
      Polar last;
      uint16 rotationSpeed;
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
    uint8 miningArea;
    Orbit orbit;
}
    
struct Comet { 
    address cometAddr;
    Orbit orbit;
}

    
contract ComethGame {
    
    using RealMath for *;
        
    event ShipMove(string indexed _modelId,  uint _block, uint32  _distance, uint16 _angle);
    
    mapping (string => Ship) private shipsMapping;
    Ship[] private _ships;
    
    mapping (address => Comet) private cometsMapping;
    Comet[] private _comets;
     
    function shipsInGame() public view returns (Ship[] memory ships)  {
        return  _ships;
    }
    
    function cometsInGame() public view returns (Comet[] memory comets)  {
        return  _comets;
    }
     
     function shipPosition(string memory modelId, uint time) public view returns (Cartesian memory position){
        return cartesianCoordinate(shipsMapping[modelId].orbit, time);
     }
     
     function cometPosition(address cometAddr, uint time) public view returns (Cartesian memory position){
         return cartesianCoordinate(cometsMapping[cometAddr].orbit, time);
     }
     
     
    function canMine(string memory modelId, address cometAddr, uint time) public view returns (bool result){
        Ship memory ship = shipsMapping[modelId];
        Cartesian memory shipCartesian = shipPosition(modelId, time);
        Cartesian memory cometCartesian = cometPosition(cometAddr, time);
     
        int minX = shipCartesian.x - ship.miningArea;
        int maxX = shipCartesian.x + ship.miningArea;
        
        int minY = shipCartesian.y - ship.miningArea;
        int maxY = shipCartesian.y + ship.miningArea;
        
        return cometCartesian.x <= maxX && cometCartesian.x  >= minX && cometCartesian.y <= maxY && cometCartesian.y >= minY;
    }
     
     
    function cartesianCoordinate(Orbit memory orbit, uint time) internal pure returns (Cartesian memory position) {
        uint timeDiff = time - orbit.lastUpdate;
        int88 currentAngleDegree = int88((orbit.last.angle + timeDiff * orbit.rotationSpeed) % 360);
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
                                     lastUpdate: block.timestamp, rotationSpeed:1});
         
         Ship memory ship = Ship({modelId: modelId, orbit: orbit, miningArea: 15});
         shipsMapping[modelId] = ship;
         _ships.push(ship);
         
         emit ShipMove(modelId, block.number, distance, angle);
    }
    
    
      function addComet (address cometAddr, int x, int y, uint32 distance) public {
         Orbit memory orbit = Orbit({center:  Cartesian({x:x, y:y}), 
                                     last: Polar({angle:0, distance:distance}), 
                                     lastUpdate: block.timestamp, rotationSpeed:2});
         
         Comet memory comet = Comet({cometAddr: cometAddr, orbit: orbit});
         cometsMapping[cometAddr] = comet;
         _comets.push(comet);
    }
    
}

// SPDX-License-Identifier: MIT