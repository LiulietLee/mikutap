import UIKit

class SampleAnimation: AnimationDelegate {
    var triangle: [Triangle]
    var duration: Int
    var shaderColor: UIColor
    required init() {
        triangle = [
            Triangle(
                Position(x: 0.0, y: 0.5),
                Position(x: 0.5, y: -0.5),
                Position(x: -0.5, y: -0.5)
            )
        ]
        
        duration = 50
        shaderColor = .white
    }
    func update(_ schedule: Float) {
        triangle[0].rotate(0.1)
    }
}

var animations: [AnimationDelegate.Type] = [SampleAnimation.self]

start(withAnimations: animations, withoutAudio: true)
