//
//  ScaleAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 9/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class ScaleAnimation: AbstractAnimation {
    
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var rotateBuffer: MTLBuffer!
    private var scaleBuffer: MTLBuffer!
    private var widthBuffer: MTLBuffer!
    private var vertexData = [float4]()
    private var matrix = Matrix()
    
    private var width = Float()
    private var step = 40
    private var timer = 0
    
    override init(device: MTLDevice) {
        super.init(device: device)
        createBuffer()
        registerShaders(
            vertexFunctionName: "scale_vertex_func",
            fragmentFunctionName: "scale_fragment_func"
        )
    }
    
    private func createBuffer() {
        let count = UInt16(arc4random_uniform(5)) + 3
        var angle = Float.pi / 2
        let theta = 2 * Float.pi / Float(count)
        width = Float.random(in: 0.03...0.05) / cos(theta / 2)
        
        widthBuffer = device.makeBuffer(
            bytes: &width,
            length: MemoryLayout<Float>.stride,
            options: []
        )
        
        let len: Float = 2.0
        for _ in 0..<count {
            var pos = float4(len * cos(angle), len * sin(angle), 0.0, 1.0)
            vertexData.append(pos)
            pos.x *= (len - width) / len
            pos.y *= (len - width) / len
            vertexData.append(pos)
            angle += theta
        }
        
        vertexBuffer = device.makeBuffer(
            bytes: vertexData,
            length: MemoryLayout<float4>.stride * vertexData.count,
            options: []
        )
        
        var indexData = [UInt16]()
        for index in 0..<UInt16(count - 1) {
            let i = index * 2
            indexData.append(contentsOf: [i, i + 1, i + 3, i + 3, i + 2, i])
        }
        indexData.append(contentsOf: [0, 1, 2 * count - 1, 2 * count - 1, 2 * count - 2, 0])
        
        indexBuffer = device.makeBuffer(
            bytes: indexData,
            length: MemoryLayout<UInt16>.stride * indexData.count,
            options: []
        )
        
        var rotateMatrix = Matrix()
        rotateMatrix.rotationMatrix(float3(0.0, 0.0, Float.random(in: 0.0...Float.pi)))
        
        rotateBuffer = device.makeBuffer(
            bytes: rotateMatrix.m,
            length: MemoryLayout<Float>.stride * 16,
            options: []
        )
        
        scaleBuffer = device.makeBuffer(
            length: MemoryLayout<Float>.stride * 16,
            options: []
        )
    }
    
    private func update() -> Bool {
        timer += 1
        if timer > step { return false }
        var scale = Float(timer) / Float(step)
        scale = 1.0204 - 1.0204 * exp(-3.92 * scale)
        matrix.scalingMatrix(scale)
        let bufferPoint = scaleBuffer.contents()
        memcpy(bufferPoint, matrix.m, MemoryLayout<Float>.stride * 16)
        return true
    }
    
    override func setCommandEncoder(cb: MTLCommandBuffer, rpd: MTLRenderPassDescriptor) -> Bool {
        super.setCommandEncoder(cb: cb, rpd: rpd)
        let flag = update()
        if flag {
            commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            commandEncoder.setVertexBuffer(rotateBuffer, offset: 0, index: 1)
            commandEncoder.setVertexBuffer(scaleBuffer, offset: 0, index: 2)
            commandEncoder.setVertexBuffer(widthBuffer, offset: 0, index: 3)
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
