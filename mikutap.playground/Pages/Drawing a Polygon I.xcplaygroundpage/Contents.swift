/*:
 [Previous: Introduction](@previous)
 
 All animations here are implemented by Metal, which is an interface for programming the Graphics Processing Unit(GPU).
 
 As a low-level API, Metal only offers what GPUs are directly capable of. What we can draw on the screen directly are only triangles, fixed width lines and little dots. If we want to implement an animation, we need to calculate the position of each vertex in each frame.
 
 It’s a very tedious thing to implement an animation completely with Metal API in playground. In order to make things as simple as possible, I made some encapsulations. Let's forget Metal shading language and linear algebra, ignore program efficiency, just focus on Swift.
 */

/*:
 ## Geometric structs
 
 There are 2 geometric structs here:
 1. `Position`: Represents a location on the screen.
 */

var p = Position(x: 0.5, y: 0.5)

// You can call `translate` function to move this position.
p.translate(x: -0.1, y: 1.0)

// Or you can also call `rotate` function to rotate this position around the origin.
let angle = Float.pi / 2
p.rotate(angle)

//: 2. `Triangle`: Represents a triangle consisting of three positions.

var triangle = Triangle(
    Position(x: 0.5, y: 0.5),
    Position(x: -0.5, y: 0.5),
    Position(x: -0.5, y: -0.5)
)

// Same as Position, you can translate and rotate triangle.
triangle.translate(x: 0.1, y: -0.1)
triangle.rotate(angle)

// Different from Position, you can alse scale the triangle.
triangle.scale(1.2)

// You can set the value of a single position. (0 <= index <= 2)
triangle.vertex[0].rotate(angle)

// Or get the value of a single position.
p = triangle.vertex[0]

/*:
 - Experiment: Try to change the value of the triangle below to see what happend.
 */

triangle = Triangle(
    Position(x: 0.2, y: 0.5),
    Position(x: 0.5, y: -0.5),
    Position(x: -0.5, y: -0.5)
)

draw([triangle])

//: [Next: Drawing a Polygon II](@next)
