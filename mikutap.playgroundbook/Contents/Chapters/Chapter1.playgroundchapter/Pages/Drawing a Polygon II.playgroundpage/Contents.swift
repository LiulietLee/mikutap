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

/*:
 - Experiment: There is a challenge for you now. Can you draw a *pentagon* on the screen? When you finish, call `draw(pentagon)` to draw.
 */

//#-editable-code Code for preparation

//#-end-editable-code

var pentagon: [Triangle] = [ /*#-editable-code Your triangles*//*#-end-editable-code*/ ]

// Uncomment this line below to draw your pentagon.
/*#-editable-code*/// draw(pentagon)/*#-end-editable-code*/

/*:
 - Note: You can use the member functions of `struct Position` and `struct Triangle` introduced in the [previous page](@previous). The following is a segmentation way for reference.
 
 ![](pentagon.png)
 
 [Next: Custom Animation](@next)
 */
