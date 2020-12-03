pragma solidity >=0.6.0 <0.7.0;
pragma experimental ABIEncoderV2;

struct Position { 
        uint32 distance;
        uint16 angle;
        uint lastUpdateBlock;
    }
    
struct Ship { 
       string modelId;
       Position position;
    }
    
struct Comet { 
       address cometAddr;
       uint32 rotationCenterX;
       uint32 rotationCenterY;
       Position position;
    }
    

contract ComethGame {
    event ShipMove(string indexed _modelId,  uint _block, uint32  _distance, uint16 _angle);
    
    // Degree by block
    uint16 public rotationSpeed = 20;
    uint16 public cometRotationSpeed = 30;
    
    
    mapping (string => Position) public shipPositions;
    Ship[] private _ships;
    
    mapping (address => Position) public comethPosition;
    Comet[] private _comets;
     
    
   
    function addShip (string memory modelId) public {
         uint256 addressToUint = uint256(msg.sender);
         
         uint32 distance = uint32(addressToUint % 100);
         uint16 angle = uint16(addressToUint % 360);
         
         Position memory position = Position({distance: distance, angle: angle, lastUpdateBlock: block.number});
         
         shipPositions[modelId] = position;
         _ships.push(Ship({modelId: modelId, position: position}));
         
         emit ShipMove(modelId, block.number, distance, angle);
    }
    
    
      function addComet (address cometAddr) public {
         uint256 addressToUint = uint256(cometAddr);
         
         uint32 distance = uint32(addressToUint % 50);
         uint16 angle = uint16(addressToUint % 360);
         
          uint32 x = uint32(addressToUint % 50);
          uint32 y = uint32(addressToUint % 50);
         
         Position memory position = Position({distance: distance, angle: angle, lastUpdateBlock: block.number});
         
         comethPosition[cometAddr] = position;
         _comets.push(Comet({cometAddr: cometAddr, rotationCenterX: x, rotationCenterY: y, position: position}));
    }
    
    function shipsInGame() public view returns (Ship[] memory ships)  {
        return  _ships;
    }
    
    function cometsInGame() public view returns (Comet[] memory comets)  {
        return  _comets;
    }
    
     
    
    
    
}