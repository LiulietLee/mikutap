//
//  SegmentAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 8/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class SegmentAnimation: AbstractAnimation {
    
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var path = [float2]()
    private var vertexData = [Vertex]()
    private var indexData = [UInt16]()
    private var lengthSum: Float = 0.0
    private var width: Float = 0.0
    
    private var step = 26
    private var timer = 0
    
    override init(device: MTLDevice, aspect: CGFloat) {
        super.init(device: device, aspect: aspect)
        initInfo()
        registerShaders(
            vertexFunctionName: "segment_vertex_func",
            fragmentFunctionName: "segment_fragment_func"
        )
    }
    
    private func initInfo() {
        let count = arc4random_uniform(2) + 2
        for _ in 0..<count {
            path.append(float2(Float.random(in: -0.9...0.9), Float.random(in: -0.9...0.9)))
        }
        if arc4random_uniform(2) == 0 {
            if arc4random_uniform(2) == 0 {
                path.sort { $0.x > $1.x }
                path.insert(float2(1.1, Float.random(in: -0.9...0.9)), at: 0)
                path.append(float2(-2.0, Float.random(in: -0.9...0.9)))
            } else {
                path.sort { $0.x < $1.x }
                path.insert(float2(-1.1, Float.random(in: -0.9...0.9)), at: 0)
                path.append(float2(2.0, Float.random(in: -0.9...0.9)))
            }
        } else {
            if arc4random_uniform(2) == 0 {
                path.sort { $0.y > $1.y }
                path.insert(float2(Float.random(in: -0.9...0.9), 1.1), at: 0)
                path.append(float2(Float.random(in: -0.9...0.9), -2.0))
            } else {
                path.sort { $0.y < $1.y }
                path.insert(float2(Float.random(in: -0.9...0.9), -1.1), at: 0)
                path.append(float2(Float.random(in: -0.9...0.9), 2.0))
            }
        }
        for i in 0..<path.count - 1 {
            lengthSum += length_squared(path[i + 1] - path[i])
        }
        width = Float.random(in: 0.02...0.04)
    }
    
    private func update() -> Bool {
        timer += 1
        var d = Float(timer) / Float(step)
        if timer > step {
            if timer > step * 2 {
                return false
            } else {
                d = 2.0 - d
            }
        }
        var len: Float = 0.0
        let aim = lengthSum * d
        var tempPath = [float2]()
        let range = timer > step ? Array((1...path.count - 1).reversed()) : Array(0..<path.count - 1)
        for i in range {
            let behind = timer > step ? i - 1 : i + 1
            let seg = length_squared(path[behind] - path[i])
            len += seg
            tempPath.append(path[i])
            if len > aim {
                tempPath.append(
                    path[i] + (seg - len + aim) / seg * (path[behind] - path[i])
                )
                break
            }
        }
        
        (vertexData, indexData) = PolygonFactory.getSegments(path: tempPath, width: width)

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
            commandEncoder.setVertexBytes(
                vertexData,
                length: MemoryLayout<Vertex>.stride * vertexData.count,
                index: 0
            )
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
