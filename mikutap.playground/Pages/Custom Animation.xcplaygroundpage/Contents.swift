/*:
 [Previous: Drawing a Polygon II](@previous)
 
 Now we have known how to draw polygons on the screen. It's time to talk about custom animation class.
 
 This is a sample class. Let's take a closer look at it.
 */

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
//: - Note: Here you can initialize the above three variables or variables that you define yourself.
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
//: - Note: `update` function is called once per frame. The `schedule` argument tells you the progress of this animtion. `0.0 < schedule < 1.0`.
    func update(_ schedule: Float) {
        triangle[0].rotate(0.1)
    }
}

var animations: [AnimationDelegate.Type] = [SampleAnimation.self]

/*:
 - Experiment: It's your show time now. Complete the following class to create your own animation.
 */

class YourAnimation: AnimationDelegate {
    
    var triangle: [Triangle]
    var duration: Int
    var shaderColor: UIColor

    //#-editable-code Custom variables
    
    //#-end-editable-code

    required init() {
        //#-editable-code Initialization code
        
        //#-end-editable-code

        triangle = [ /*#-editable-code Your triangles*//*#-end-editable-code*/ ]
        duration = /*#-editable-code*/50/*#-end-editable-code*/
        shaderColor = /*#-editable-code UIColor*/.white/*#-end-editable-code*/
    }
    
    func update(_ schedule: Float) {
        //#-editable-code Code
        
        //#-end-editable-code
    }
}

// Uncomment this line when you are done.
/*#-editable-code*/// animations = [YourAnimation.self]/*#-end-editable-code*/

start(withAnimations: animations)

//: [Next: Speed](@next)
