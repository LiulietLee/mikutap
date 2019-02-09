//
//  PolygonFactory.swift
//  mikutap
//
//  Created by Liuliet.Lee on 3/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import simd

class PolygonFactory {
    
    struct Line {
        var a: Float, b: Float, c: Float
    }
    
    static func getSegments(path: [float2], width: Float) -> ([Vertex], [UInt16]) {
        var line = [Line]()
        for i in 0..<path.count - 1 {
            let x1 = path[i].x, y1 = path[i].y
            let x2 = path[i + 1].x, y2 = path[i + 1].y
            line.append(Line(a: y2 - y1, b: x1 - x2, c: y1 * (x2 - x1) - x1 * (y2 - y1)))
        }
        
        var vertexData = [Vertex]()
        
        var k = -line[0].a / line[0].b
        var X = width * k / sqrt(1 + 4 * k * k)
        var Y = -X / (2 * k)
        vertexData.append(contentsOf: [
            Vertex(
                position: float4(path[0].x + X, path[0].y + Y, 0.0, 1.0),
                color: float4(1.0)
            ),
            Vertex(
                position: float4(path[0].x - X, path[0].y - Y, 0.0, 1.0),
                color: float4(1.0)
            ),
        ])
        
        for i in 0..<line.count - 1 {
            var l1 = line[i], l2 = line[i], l3 = line[i + 1], l4 = line[i + 1]
            var d = sqrt(line[i].a * line[i].a + line[i].b * line[i].b) * width / 2
            l1.c = line[i].c + d
            l2.c = line[i].c - d
            d = sqrt(line[i + 1].a * line[i + 1].a + line[i + 1].b * line[i + 1].b) * width / 2
            l3.c = line[i + 1].c + d
            l4.c = line[i + 1].c - d

            var y = (l1.a * l3.c - l3.a * l1.c) / (l3.a * l1.b - l1.a * l3.b)
            var x = (-l1.b * y - l1.c) / l1.a
            vertexData.append(Vertex(position: float4(x, y, 0.0, 1.0), color: float4(1.0)))
            y = (l2.a * l4.c - l4.a * l2.c) / (l4.a * l2.b - l2.a * l4.b)
            x = (-l2.b * y - l2.c) / l2.a
            vertexData.append(Vertex(position: float4(x, y, 0.0, 1.0), color: float4(1.0)))
        }
        
        k = -line[line.count - 1].a / line[line.count - 1].b
        X = width * k / sqrt(1 + 4 * k * k)
        Y = -X / (2 * k)
        let index = path.count - 1
        vertexData.append(contentsOf: [
            Vertex(
                position: float4(path[index].x + X, path[index].y + Y, 0.0, 1.0),
                color: float4(1.0)
            ),
            Vertex(
                position: float4(path[index].x - X, path[index].y - Y, 0.0, 1.0),
                color: float4(1.0)
            ),
        ])
        
        var indexData = [UInt16]()
        for i in 0..<vertexData.count / 2 - 1 {
            let id = UInt16(i * 2)
            indexData.append(contentsOf:
                [id, id + 1, id + 2, id, id + 1, id + 3, id, id + 2, id + 3]
            )
        }
        
        return (vertexData, indexData)
    }
    
    static func getRectangle(withWidth width: Float, andHeight height: Float) -> ([Vertex], [UInt16]) {
        var vertexData = [Vertex]()
        let index: [[Float]] = [[0.5, 0.5], [-0.5, 0.5], [-0.5, -0.5], [0.5, -0.5]]
        for i in index {
            vertexData.append(Vertex(
                position: float4(i[0] * width, i[1] * height, 0.0, 1.0),
                color: float4(1.0)
            ))
        }
        let indexData: [UInt16] = [0, 1, 2, 2, 3, 0]
        return (vertexData, indexData)
    }
    
    static func getRandomPolygon(withVertexCount vcount: UInt16) -> ([Vertex], [UInt16]) {
        var vertexData = [Vertex]()
        for _ in 0..<vcount {
            vertexData.append(Vertex(
                position: float4(
                    Float.random(in: -0.8...0.8),
                    Float.random(in: -0.8...0.8),
                    0.0, 1.0
                ),
                color: float4(1.0)
            ))
        }
        vertexData.sort { $0.position.x < $1.position.x }

        var indexData = [UInt16]()
        for i in 0..<vcount - 2 {
            for j in UInt16(0)..<3 {
                indexData.append(i + j)
            }
        }
        
        return (vertexData, indexData)
    }
    
}
