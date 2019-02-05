//
//  PolygonFactory.swift
//  mikutap
//
//  Created by Liuliet.Lee on 3/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import simd

class PolygonFactory {
    
    static func getRectangle(withWidth width: Float, andHeight height: Float) -> ([Vertex], [UInt16]) {
        var vertex_data = [Vertex]()
        let index: [[Float]] = [[0.5, 0.5], [-0.5, 0.5], [-0.5, -0.5], [0.5, -0.5]]
        for i in index {
            vertex_data.append(Vertex(
                position: float4(i[0] * width, i[1] * height, 0.0, 1.0),
                color: float4(1.0)
            ))
        }
        let index_data: [UInt16] = [0, 1, 2, 2, 3, 0]
        return (vertex_data, index_data)
    }
    
    static func getRandomPolygon(withVertexCount vcount: UInt16) -> ([Vertex], [UInt16]) {
        var vertex_data = [Vertex]()
        for _ in 0..<vcount {
            vertex_data.append(Vertex(
                position: float4(
                    Float.random(in: -0.8...0.8),
                    Float.random(in: -0.8...0.8),
                    0.0, 1.0
                ),
                color: float4(1.0)
            ))
        }
        vertex_data.sort { $0.position.x < $1.position.x }

        var index_data = [UInt16]()
        for i in 0..<vcount - 2 {
            for j in UInt16(0)..<3 {
                index_data.append(i + j)
            }
        }
        
        return (vertex_data, index_data)
    }
    
}
