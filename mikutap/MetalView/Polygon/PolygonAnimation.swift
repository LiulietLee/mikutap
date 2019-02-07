//
//  PolygonAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 6/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class PolygonAnimation: AbstractAnimation {
    
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var offsetBuffer: MTLBuffer!
    private var rateBuffer: MTLBuffer!
    
    private var offset_data: [float2]!
    private var vertex_count: UInt16!
    
    private let step = 35
    private var timer = 0

    override init(device: MTLDevice) {
        super.init(device: device)
        createBuffer()
        renderPipelineState = getRenderPipelineState(
            vertexFunctionName: "polygon_vertex_func",
            fragmentFunctionName: "polygon_fragment_func"
        )
    }
    
    private func createBuffer() {
        var vertex_data = [Vertex](), index_data = [UInt16]()
        vertex_count = UInt16(arc4random_uniform(3) + 3)
        
        (vertex_data, index_data) = PolygonFactory.getRandomPolygon(withVertexCount: vertex_count)
        
        vertexBuffer = device!.makeBuffer(
            bytes: vertex_data,
            length: MemoryLayout<Vertex>.stride * vertex_data.count,
            options: []
        )
        
        indexBuffer = device!.makeBuffer(
            bytes: index_data,
            length: MemoryLayout<UInt16>.stride * index_data.count,
            options: []
        )
        
        offset_data = [float2]()
        for i in 0..<Int(vertex_count) {
            let destination = float2(
                Float.random(in: -1.1...1.1) - vertex_data[i].position.x,
                Float.random(in: -1.1...1.1) - vertex_data[i].position.y
            )
            offset_data.append(destination)
        }
        offsetBuffer = device!.makeBuffer(
            bytes: offset_data!,
            length: MemoryLayout<float2>.stride * offset_data!.count,
            options: []
        )
        
        rateBuffer = device!.makeBuffer(length: MemoryLayout<Float>.stride, options: [])
    }
    
    private func rate() -> Float {
        let t = timer > step ? Float(step) : Float(timer)
        return t / Float(step)
    }
    
    private func update() -> Bool {
        timer += 1
        if timer > step { return false }
        var d = rate()
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
