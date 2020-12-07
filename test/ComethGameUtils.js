
var ComethGamesUtils = module.exports

function degrees_to_radians(degrees)
{
  var pi = Math.PI;
  return degrees * (pi/180);
}

ComethGamesUtils.calculateCoordonates = function(orbit, time) {
    var timeDiff = time - orbit.lastUpdate
    var currentAngle = degrees_to_radians((orbit.last.angle + (timeDiff * orbit.rotationSpeed) ) % 360)

    var x = orbit.last.distance * Math.cos(currentAngle) + parseInt(orbit.center.x)
    var y=  orbit.last.distance * Math.sin(currentAngle) + parseInt(orbit.center.y)
    return [Math.trunc(x), Math.trunc(y)]
}