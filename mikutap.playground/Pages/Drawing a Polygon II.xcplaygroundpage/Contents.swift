/*:
 [Previous: Drawing a Polygon I](@previous)
 
 OK, now we have triangles, but how to draw polygons? They are much more complicated than triangles.
 
 Actually, the way to draw a polygon is to split it into triangle pieces. For example, if we wanna draw a rectangle, we need to cut the rectangle to two triangles and draw them separately.
 
 Check out the code below.
 */

let rectangle = [
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

draw(rectangle)

//: - Note: If you tap the "Run My Code" button now, you will get a white rectangle on the center of view.
 
//: - Experiment: There is a challenge for you now. Can you draw a *pentagon* on the screen? When you finish, call `draw(pentagon)` to draw.

var pentagon: [Triangle] = [ /* Your triangles */ ]

// draw(pentagon)

/*:
 - Note: You can use the member functions of `struct Position` and `struct Triangle` introduced in the [previous page](@previous).

 [Next: Custom Animation Class](@next)
 */
