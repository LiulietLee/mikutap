//
//  PolygonFactory.swift
//  mikutap
//
//  Created by Liuliet.Lee on 3/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import simd

class PolygonFactory {
    
    static func getStarVertices(withPointNumber point: UInt16, andLength length: Float) -> [float2] {
        let interval = Float.pi * 2 / Float(point)
        var angle = Float()
        var vertexData = [float2]()
        for i in 0..<point {
            angle = interval * Float(i) + Float.pi / 2
            vertexData.append(float2(length * cos(angle), length * sin(angle)))
        }
        return vertexData
    }
    
    static private func cross(_ a: float2, _ b: float2) -> Float { return a.x * b.y - b.x * a.y }
    static private func normal(_ a: float2) -> float2 {
        let l = length(a)
        return float2(-a.y / l, a.x / l)
    }

    static private let eps: Float = 1e-1

    static private func lineCoincide(_ p: float2, _ v: float2, _ q: float2, _ w: float2) -> Bool {
        return abs(cross(v, w)) < eps && abs(cross(v, p - q)) < eps
    }
    
    static private func lineIntersecion(_ p: float2, _ v: float2, _ q: float2, _ w: float2) -> float2 {
        let u = p - q
        let t = cross(w, u) / cross(v, w)
        return p + v * t
    }
    
    static func getSegments(path: [float2], width: Float) -> ([Vertex], [UInt16]) {
        var point = [float2](), vector = [float2]()
        
        for i in 0..<path.count - 1 {
            point.append(path[i])
            vector.append(path[i + 1] - path[i])
        }
        
        var vertexData = [Vertex]()
        
        var norm = normal(vector[0])
        vertexData.append(contentsOf: [
            Vertex(point[0] + width * 0.5 * norm),
            Vertex(point[0] - width * 0.5 * norm)
        ])
        
        for i in 0..<point.count - 1 {
            var p = point[i], q = point[i + 1]
            let v = vector[i], w = vector[i + 1]
            
            if lineCoincide(p, v, q, w) {
                vertexData.append(contentsOf: [
                    Vertex(q + width * 0.5 * normal(w)),
                    Vertex(q - width * 0.5 * normal(w))
                ])
                continue
            }
            
            p += width * 0.5 * normal(v)
            q += width * 0.5 * normal(w)
            var intersecion = lineIntersecion(p, v, q, w)
            vertexData.append(Vertex(intersecion))
            
            p -= width * normal(v)
            q -= width * normal(w)
            intersecion = lineIntersecion(p, v, q, w)
            vertexData.append(Vertex(intersecion))
        }
        
        norm = normal(vector[vector.count - 1])
        vertexData.append(contentsOf: [
            Vertex(path[path.count - 1] + width * 0.5 * norm),
            Vertex(path[path.count - 1] - width * 0.5 * norm)
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
                position: float4(i[0] * width, i[1] * height, 0.0, 1.0)
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
                )
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
