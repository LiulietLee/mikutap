import UIKit

let centerTriangle = Triangle(
    Position(x: 0.0, y: 0.5),
    Position(x: 0.5, y: -0.5),
    Position(x: -0.5, y: -0.5)
)

class SampleAnimation: AnimationDelegate {
    
    var triangle: [Triangle]
    var duration: Int
    var shaderColor: UIColor
    
    var originTriangles: [Triangle]
    
    required init() {
        originTriangles = [centerTriangle]
        triangle = originTriangles
        duration = 50
        shaderColor = .white
    }
    
    func update(_ schedule: Float) {
        triangle = originTriangles
        triangle[0].scale(1 - exp(-6.0 * schedule) * cos(schedule * Float.pi * 7.0))
    }
}

var animations: [AnimationDelegate.Type] = [SampleAnimation.self]

start(withAnimations: animations, withoutAudio: true)
