//
//  TransitionAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 12/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class TransitionAnimation: AbstractAnimation {
    
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    
    private var vertexData = [Vertex]()
    private var direction = float2()
    private var timer = 0

    override init(device: MTLDevice, aspect: CGFloat) {
        super.init(device: device, aspect: aspect)
        createBuffer()
        registerShaders(
            vertexFunctionName: "transition_vertex_func",
            fragmentFunctionName: "transition_fragment_func"
        )
    }
    
    private func createBuffer() {
        let count = [0, 1, 3][Int(arc4random_uniform(3))]
        if arc4random_uniform(2) == 0 {
            direction = float2(1.0, 0.0)
            vertexData = [Vertex(float2(-2.0, 1.0)), Vertex(float2(-1.0, 1.0))]
            
            if count == 0 {
                vertexData.append(contentsOf: [
                    Vertex(float2(-1.3, -1.0)), Vertex(float2(-1.0, -1.0))
                ])
            } else {
                for i in 0..<count {
                    vertexData.append(Vertex(float2(
                        -1.0 - (i % 2 == 0 ? 0.3 : 0.0),
                        -(2.0 / Float(count + 1) * (Float(i) + 1) - 1.0)
                    )))
                }
                vertexData.append(contentsOf: [
                    Vertex(float2(-1.0, -1.0)), Vertex(float2(-2.0, -1.0))
                ])
            }
        } else {
            direction = float2(0.0, 1.0)
            vertexData = [Vertex(float2(-1.0, -2.0)), Vertex(float2(-1.0, -1.0))]
            
            if count == 0 {
                vertexData.append(contentsOf: [
                    Vertex(float2(1.0, -1.3)), Vertex(float2(1.0, -1.0))
                ])
            } else {
                for i in 0..<count {
                    vertexData.append(Vertex(float2(
                        2.0 / Float(count + 1) * (Float(i) + 1) - 1.0,
                        -1.0 - (i % 2 == 0 ? 0.3 : 0.0)
                    )))
                }
                vertexData.append(contentsOf: [
                    Vertex(float2(1.0, -1.0)), Vertex(float2(1.0, -2.0))
                ])
            }
        }
        
        vertexBuffer = device.makeBuffer(
            length: MemoryLayout<Vertex>.stride * vertexData.count,
            options: []
        )
        
        var indexData = [UInt16]()
        for i in 1..<vertexData.count - 1 {
            let id = UInt16(i)
            indexData.append(contentsOf: [0, id, id + 1])
        }
        
        indexBuffer = device.makeBuffer(
            bytes: indexData,
            length: MemoryLayout<UInt16>.stride * indexData.count,
            options: []
        )
    }
    
    private func update() -> Bool {
        let d = Float(0.1), rate = Float(exp(-Double(timer) * 0.038))
        timer += 1
        var flag = false
        for i in 1..<vertexData.count - 1 {
            vertexData[i].position.x += direction.x * d * rate
            vertexData[i].position.y += direction.y * d * rate
            
            if direction.x == 0 {
                if vertexData[i].position.y > 1.0 {
                    vertexData[i].position.y = 1.0
                } else {
                    flag = true
                }
            } else {
                if vertexData[i].position.x > 1.0 {
                    vertexData[i].position.x = 1.0
                } else {
                    flag = true
                }
            }
        }
        
        if !flag { return false }
        
        let bufferPoint = vertexBuffer.contents()
        memcpy(bufferPoint, vertexData, MemoryLayout<Vertex>.stride * vertexData.count)
        
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
