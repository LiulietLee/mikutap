//
//  CircleAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 6/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class CircleAnimation: AbstractAnimation {
    
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var fragInfoBuffer: MTLBuffer!
    private var fragIndexesBuffer: MTLBuffer!
    
    private var timer = 0
    private var index = 0
    private var step = 35
    private var start = Float()

    required init(device: MTLDevice, aspect: CGFloat) {
        super.init(device: device, aspect: aspect)
        start = Float.random(in: 0.0...2 * Float.pi)
        createBuffer()
        registerShaders(
            vertexFunctionName: "circle_vertex_func",
            fragmentFunctionName: "circle_fragment_func"
        )
    }
    
    private func createBuffer() {
        var vertexData = [Vertex](), indexData = [UInt16]()
        let radius2: Float = Float.random(in: 0.8...1.5)
        (vertexData, indexData) = PolygonFactory.getRectangle(
            withWidth: radius2, andHeight: radius2
        )
        
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
        
        var info = radius2 * 0.5
        fragInfoBuffer = device.makeBuffer(
            bytes: &info,
            length: MemoryLayout<Float>.stride,
            options: []
        )
        
        fragIndexesBuffer = device.makeBuffer(
            length: MemoryLayout<float3>.stride,
            options: []
        )
    }

    private func update() -> Bool {
        timer += 1
        if timer > step {
            timer = 0
            index ^= 1
            if index == 0 { return false }
        }
        var indexes = float3(index == 0 ? 0.0 : 2 * Float.pi)
        indexes[index] = Float(timer) / Float(step) * 2 * Float.pi
        indexes[2] = start
        let bufferPoint = fragIndexesBuffer.contents()
        memcpy(bufferPoint, &indexes, MemoryLayout<float3>.stride)
        
        return true
    }
    
    @discardableResult
    override func setCommandEncoder(cb: MTLCommandBuffer, rpd: MTLRenderPassDescriptor) -> Bool {
        super.setCommandEncoder(cb: cb, rpd: rpd)
        let flag = update()
        if flag {
            commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            commandEncoder.setFragmentBuffer(fragInfoBuffer, offset: 0, index: 0)
            commandEncoder.setFragmentBuffer(fragIndexesBuffer, offset: 0, index: 1)
            commandEncoder.setFragmentBytes(&aspect, length: MemoryLayout<Float>.stride, index: 2)
            commandEncoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 3)
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
