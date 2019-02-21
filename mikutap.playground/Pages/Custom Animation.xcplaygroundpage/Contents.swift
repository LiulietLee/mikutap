/*:
 [Previous: Introduction](@previous)
 
 This playground provides highly customized features. Both animation and sound can be customized. So you can use this playground to customize your own Mikutap.
 
 Here we start with a simple place: just one animation with one sound. The following is an example.
 */

import UIKit

/*:
 - Note: This is a sample animation.
 If you don't understand these codes, don't worry. I will explain them soon.
 */
class SampleAnimation: AnimationDelegate {
    
    var orignTriangle = [Triangle]()
    
    var triangle: [Triangle]
    var duration: Int
    var shaderColor: UIColor
    
    required init() {
        triangle = [
            Triangle(
                Position(x: 0.5, y: 0.5),
                Position(x: -0.5, y: 0.5),
                Position(x: -0.5, y: -0.5)
            ),
            Triangle(
                Position(x: -0.5, y: -0.5),
                Position(x: 0.5, y: -0.5),
                Position(x: 0.5, y: 0.5)
            )
        ]
        orignTriangle = triangle
        
        duration = 35
        shaderColor = .white
    }
    
    func update(_ schedule: Float) {
        triangle = orignTriangle
        triangle[0].scale(schedule)
        triangle[1].scale(schedule)
    }
}

// Then let's put the written animations together.
let animations = [SampleAnimation.self]

// Finally we pass the animation array to `start` function
start(withAnimations: animations)

/*:
 - Experiment: Tap "Run My Code" to see this animation, which is just a white scaling rectangle on the center of the view.
 
 [Next: Drawing a Polygon I](@next)
 */
