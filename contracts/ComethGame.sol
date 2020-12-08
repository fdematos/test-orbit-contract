pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./RealMath.sol";

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
    uint256 tokenId;
    address owner;
    uint8 miningArea;
    Orbit orbit;
}
    
struct Comet { 
    string name;
    Orbit orbit;
}

    
contract ComethGame {
    
    using RealMath for *;
        
    event ShipMove(uint256 indexed _tokenId,  uint _block, uint32  _distance, uint16 _angle);
    
    mapping (uint256 => Ship) private shipsMapping;
    Ship[] private _ships;
    
    mapping (string => Comet) private cometsMapping;
    Comet[] private _comets;
     
    function shipsInGame() public view returns (Ship[] memory ships)  {
        return  _ships;
    }
    
    function cometsInGame() public view returns (Comet[] memory comets)  {
        return  _comets;
    }

     function shipPosition(uint256 tokenId, uint time) public view returns (Cartesian memory position){
        return cartesianCoordinate(shipsMapping[tokenId].orbit, time);
     }

     function cometPosition(string memory name, uint time) public view returns (Cartesian memory position){
         return cartesianCoordinate(cometsMapping[name].orbit, time);
     }
     
     
    function canMine(uint256 tokenId, string memory cometName, uint time) public view returns (bool result){
        Ship memory ship = shipsMapping[tokenId];
        Cartesian memory shipCartesian = shipPosition(tokenId, time);
        Cartesian memory cometCartesian = cometPosition(cometName, time);
     
        int minX = shipCartesian.x - ship.miningArea;
        int maxX = shipCartesian.x + ship.miningArea;
        
        int minY = shipCartesian.y - ship.miningArea;
        int maxY = shipCartesian.y + ship.miningArea;
        
        return cometCartesian.x <= maxX && cometCartesian.x  >= minX && cometCartesian.y <= maxY && cometCartesian.y >= minY;
    }
     
     
    function cartesianCoordinate(Orbit memory orbit, uint time) public pure returns (Cartesian memory position) {
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
    
    function addShip (uint256 tokenId) public {
         uint256 addressToUint = uint256(msg.sender);
         
         uint16 angle = uint16((addressToUint + tokenId) % 360);
         uint32 distance = uint32((addressToUint + tokenId) % 500);
        
         
         Orbit memory orbit = Orbit({center: Cartesian({x:0, y:0}), 
                                     last: Polar({angle:angle, distance:distance}), 
                                     lastUpdate: block.timestamp, rotationSpeed:1});
         
         Ship memory ship = Ship({tokenId: tokenId, orbit: orbit, miningArea: 15, owner: msg.sender});
         shipsMapping[tokenId] = ship;
         _ships.push(ship);
         
         emit ShipMove(tokenId, block.number, distance, angle);
    }
    
    
      function addComet (string memory cometName, int x, int y, uint32 distance) public {
         Orbit memory orbit = Orbit({center:  Cartesian({x:x, y:y}), 
                                     last: Polar({angle:0, distance:distance}), 
                                     lastUpdate: block.timestamp, rotationSpeed:2});
         
         Comet memory comet = Comet({name: cometName, orbit: orbit});
         cometsMapping[cometName] = comet;
         _comets.push(comet);
    }
    
}

// SPDX-License-Identifier: MIT