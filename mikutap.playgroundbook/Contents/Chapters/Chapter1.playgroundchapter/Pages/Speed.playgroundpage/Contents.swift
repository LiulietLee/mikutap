/*:
 [Previous: Custom Animation](@previous)
 
 On the previous page we learned how to create an animation. But animations with constant speed from start to finish can be boring.
 
 Here we can use mathematical formulas to gently change the speed of animation.
 */

import UIKit

let centerTriangle = Triangle(
    Position(x: 0.0, y: 0.5),
    Position(x: 0.5, y: -0.5),
    Position(x: -0.5, y: -0.5)
)

//: - Note: This is an example. If you run the code now, you will get the effect of a triangle popping up from the screen.
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
/*:
 - Example:
 The `triangle` array first read origin data from `originTriangles`. Then use the formula `1 - exp(-6𝑥) * cos(7𝜋𝑥)` to calculate current zoom ratio.
 */
        triangle = originTriangles
        triangle[0].scale(1 - exp(-6.0 * schedule) * cos(schedule * Float.pi * 7.0))
    }
}

var animations: [AnimationDelegate.Type] = [SampleAnimation.self]

/*:
 Time-axis-based animations are inseparable from interpolation functions, essentially using various polynomial functions to construct a variety of curve segments. The definition fields are generally [0, 1].
 ```
 1. Yellow : f(x) = 𝑥^2
 2. Blue   : f(x) = √(𝑥)
 3. Red    : f(x) = sin(𝜋𝑥 / 2)
 4. Green  : f(x) = 1 - exp(-6𝑥) * cos(7𝜋𝑥)
 ```
 ![](functions.png)
 */

//: - Experiment: Try to use different formula to control your animation.

//#-editable-code Code
class YourAnimation: AnimationDelegate {
    
    var triangle: [Triangle]
    var duration: Int
    var shaderColor: UIColor
    
    required init() {
        triangle = [centerTriangle]
        duration = 50
        shaderColor = .white
    }
    
    func update(_ schedule: Float) {
        // Write your code here.
        
    }
}

// Uncomment this line when you are done.
// animations = [YourAnimation.self]

//#-end-editable-code

start(withAnimations: animations, withoutAudio: true)

//: [Next: Custom Audio](@next)
