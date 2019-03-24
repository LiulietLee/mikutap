var triangle = Triangle(
    Position(x: 0.0, y: 0.5),
    Position(x: 0.5, y: -0.5),
    Position(x: -0.5, y: -0.5)
)

triangle.rotate(0.0)
triangle.scale(1.0)
triangle.translate(x: 0.0, y: 0.0)

draw([triangle])
