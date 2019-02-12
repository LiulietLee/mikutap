//
//  PolygonAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 6/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class PolygonFillAnimation: AbstractAnimation {
    
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var offsetBuffer: MTLBuffer!
    private var rateBuffer: MTLBuffer!
    
    private var offsetData: [float2]!
    private var vertexCount: UInt16!
    
    private let step = 35
    private var timer = 0

    override init(device: MTLDevice, aspect: CGFloat) {
        super.init(device: device, aspect: aspect)
        createBuffer()
        registerShaders(
            vertexFunctionName: "polygon_fill_vertex_func",
            fragmentFunctionName: "polygon_fill_fragment_func"
        )
    }
    
    private func createBuffer() {
        var vertexData = [Vertex](), indexData = [UInt16]()
        vertexCount = UInt16(arc4random_uniform(3) + 3)
        
        (vertexData, indexData) = PolygonFactory.getRandomPolygon(withVertexCount: vertexCount)
        
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
        
        offsetData = [float2]()
        for i in 0..<Int(vertexCount) {
            let destination = float2(
                Float.random(in: -1.1...1.1) - vertexData[i].position.x,
                Float.random(in: -1.1...1.1) - vertexData[i].position.y
            )
            offsetData.append(destination)
        }
        offsetBuffer = device.makeBuffer(
            bytes: offsetData!,
            length: MemoryLayout<float2>.stride * offsetData!.count,
            options: []
        )
        
        rateBuffer = device.makeBuffer(length: MemoryLayout<Float>.stride, options: [])
    }
    
    private func update() -> Bool {
        timer += 1
        if timer > step { return false }
        var d = Float(timer) / Float(step)
        d = 1.0204 - 1.0204 * exp(-3.92 * d)
        let bufferPoint = rateBuffer.contents()
        memcpy(bufferPoint, &d, MemoryLayout<Float>.stride)
        return true
    }

    @discardableResult
    override func setCommandEncoder(cb: MTLCommandBuffer, rpd: MTLRenderPassDescriptor) -> Bool {
        super.setCommandEncoder(cb: cb, rpd: rpd)
        let flag = update()
        if flag {
            commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            commandEncoder.setVertexBuffer(offsetBuffer, offset: 0, index: 1)
            commandEncoder.setVertexBuffer(rateBuffer, offset: 0, index: 2)
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
