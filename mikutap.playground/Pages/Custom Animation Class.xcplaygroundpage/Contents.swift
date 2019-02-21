/*:
 [Previous: Drawing a Polygon II](@previous)
 
 Now we have known how to draw polygons on the screen. It's time to talk about custom animation class.
 
 This is a sample class. Let's take a closer look at it.
 */

//: - Note: Because we need to use `UIColor` to set the color of polygon, we have to import UIKit here.
import UIKit

//: - Important: Every custom animation needs to implement the `AnimationDelegate` protocol.
class SampleAnimation: AnimationDelegate {
/*:
 - Note: Every class needs to include these three variables.
     1. `triangle`: a triangle array. It will be passed to GPU to draw on the screen.
     2. `duration`: count of frame of this animation. In most cases there are 60 frames per second.
     3. `shaderColor`: color of triangles.
 */
    var triangle: [Triangle]
    var duration: Int
    var shaderColor: UIColor
//: - Important: Remember to add the `required` keyword before `init()`.
    required init() {
//: - Note: Here you can initialize the above three variables or variables that you define yourself.
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
//: - Note: `update` function is called once per frame. The `schedule` argument tells you the progress of this animtion. `0.0 < schedule < 1.0`.
    func update(_ schedule: Float) {
        triangle[0].rotate(0.1)
    }
}

/*:
 - Experiment: It's your show time now. Complete the following class to create your own animation.
 */

class YourAnimation: AnimationDelegate {
    
    var triangle: [Triangle]
    var duration: Int
    var shaderColor: UIColor

    required init() {
        triangle = [ /* Your triangles */ ]
        duration = 50           // Please reset this value
        shaderColor = .white    // Please reset this value
    }
    
    func update(_ schedule: Float) {
        // Type your code here
        
    }
}

let animations: [AnimationDelegate.Type] = [SampleAnimation.self, YourAnimation.self]
start(withAnimations: animations)

//: [Next: Custom Audio](@next)
