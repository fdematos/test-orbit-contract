pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

import "./realmath.sol";

struct Orbit  { 
      Cartesian center;
      Polar last;
      uint lastUpdateBlock;
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
    
    // Degree by block
    uint16 public rotationSpeed = 20;
    uint16 public cometRotationSpeed = 30;
    
    
    mapping (string => Orbit) private shipOrbits;
    Ship[] private _ships;
    
    mapping (address => Orbit) private comethOrbits;
    Comet[] private _comets;
     
     
     function shipPosition(string memory modelId) public view returns (Cartesian memory position){
         return cartesianCoordinate(shipOrbits[modelId]);
     }
     
     function cometPosition(address cometAddr) public view returns (Cartesian memory position){
         return cartesianCoordinate(comethOrbits[cometAddr]);
     }
     
    function cartesianCoordinate(Orbit memory orbit) internal view returns (Cartesian memory position) {
        uint blockDiff = block.number - orbit.lastUpdateBlock;
        int88 currentAngleDegree = int88((orbit.last.angle + blockDiff * rotationSpeed) % 360);
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
                                     lastUpdateBlock: block.number});
         
         shipOrbits[modelId] = orbit;
         _ships.push(Ship({modelId: modelId, orbit: orbit}));
         
         emit ShipMove(modelId, block.number, distance, angle);
    }
    
    
      function addComet (address cometAddr, int x, int y, uint32 distance) public {
         Orbit memory orbit = Orbit({center:  Cartesian({x:x, y:y}), 
                                     last: Polar({angle:0, distance:distance}), 
                                     lastUpdateBlock: block.number});
         
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