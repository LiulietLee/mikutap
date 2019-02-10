//
//  PolygonStrokeAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 10/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class PolygonStrokeAnimation: AbstractAnimation {

    private var vertexBuffer: MTLBuffer!
    private var offsetBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var rateBuffer: MTLBuffer!
    private var vertexData = [Vertex]()
    private var indexData = [UInt16]()
    private var path = [float2]()
    private var offset = [float2]()
    private var width = Float()
    
    private var timer = 0
    private var step = 35
    
    override init(device: MTLDevice) {
        super.init(device: device)
        createBuffer()
        registerShaders(
            vertexFunctionName: "polygon_stroke_vertex_func",
            fragmentFunctionName: "polygon_stroke_fragment_func"
        )
    }
    
    private func createBuffer() {
        width = Float.random(in: 0.01...0.02)
        let vertexCount = UInt16(arc4random_uniform(3) + 3)
        var vertices = [Vertex]()
        (vertices, _) = PolygonFactory.getRandomPolygon(withVertexCount: UInt16(vertexCount))
        
        let k = (vertices[vertices.count - 1].position.y - vertices[0].position.y) /
                (vertices[vertices.count - 1].position.x - vertices[0].position.x)
        let b = vertices[0].position.y - k * vertices[0].position.x
        
        for i in 0..<vertices.count {
            if i == 0 || i == vertices.count - 1 ||
                vertices[i].position.y >= k * vertices[i].position.x + b {
                path.append(float2(vertices[i].position.x, vertices[i].position.y))
            }
        }
        for i in (0..<vertices.count - 1).reversed() {
            if i == 0 || vertices[i].position.y < k * vertices[i].position.x + b {
                path.append(float2(vertices[i].position.x, vertices[i].position.y))
            }
        }

        for _ in 0..<Int(vertexCount) {
            let destination = float2(
                Float.random(in: -0.6...0.6),
                Float.random(in: -0.6...0.6)
            )
            offset.append(destination)
        }
        offset.append(offset[0])
    }
    
    private func update() -> Bool {
        timer += 1
        if timer > step { return false }
        var d = Float(timer) / Float(step)
        d = 1.0204 - 1.0204 * exp(-3.92 * d)

        var currentPath = path
        for i in 0..<path.count {
            currentPath[i] += d * offset[i]
        }
        
        (vertexData, indexData) = PolygonFactory.getSegments(path: currentPath, width: width)
        
        vertexBuffer = device.makeBuffer(
            bytes: vertexData,
            length: MemoryLayout<Vertex>.stride * vertexData.count,
            options: []
        )
        indexBuffer = device.makeBuffer(
            bytes: indexData,
            length: MemoryLayout<UInt16>.stride * indexData.count,
            options: []
        )
        
        return true
    }
    
    override func setCommandEncoder(cb: MTLCommandBuffer, rpd: MTLRenderPassDescriptor) -> Bool {
        super.setCommandEncoder(cb: cb, rpd: rpd)
        let flag = update()
        if flag {
            commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            commandEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: indexBuffer.length / MemoryLayout<UInt16>.stride,
                indexType: .uint16,
                indexBuffer: indexBuffer,
                indexBufferOffset: 0
            )
        }
        commandEncoder.endEncoding()
        return flag
    }
}
