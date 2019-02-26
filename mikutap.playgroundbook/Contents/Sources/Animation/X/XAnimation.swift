//
//  XAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 6/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class XAnimation: AbstractAnimation {
    
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var uniformBuffer: MTLBuffer!
    private var matrix: Matrix!
    private var vertexData: [Vertex]!
    
    private var timer = 0
    private var step = 40
    
    required init(device: MTLDevice, width: CGFloat, height: CGFloat) {
        super.init(device: device, width: width, height: height)
        self.aspect = Float(aspect)
        createBuffer()
        shaderFileName = "XShader"
        registerShaders(
            vertexFunctionName: "x_vertex_func",
            fragmentFunctionName: "x_fragment_func"
        )
    }
    
    private func createBuffer() {
        var vertexData1 = [Vertex](), indexData1 = [UInt16](),
        vertexData2 = [Vertex](), indexData2 = [UInt16]()
        
        let randw = 0.1 + Float.random(in: 0.0...0.1),
        randh = 0.8 + Float.random(in: 0.0...0.5)
        
        (vertexData1, indexData1) = PolygonFactory.getRectangle(
            withWidth: randw, andHeight: randh
        )
        (vertexData2, indexData2) = PolygonFactory.getRectangle(
            withWidth: randh, andHeight: randw
        )
        
        for i in 0..<indexData2.count {
            indexData2[i] += 4
        }
        
        vertexData1.append(contentsOf: vertexData2)
        indexData1.append(contentsOf: indexData2)
        vertexData = vertexData1
        
        vertexBuffer = device.makeBuffer(
            bytes: vertexData1,
            length: MemoryLayout<Vertex>.stride * vertexData1.count,
            options: []
        )
        
        indexBuffer = device.makeBuffer(
            bytes: indexData1,
            length: MemoryLayout<UInt16>.stride * indexData1.count,
            options: []
        )
        
        matrix = Matrix()
        matrix.translationMatrix(float3(
            (Float.random(in: -0.5...0.5)) / aspect, Float.random(in: -0.5...0.5), 0.0
        ))
        
        uniformBuffer = device.makeBuffer(
            bytes: matrix.m,
            length: MemoryLayout<Float>.stride * 16,
            options: []
        )        
    }
    
    private func update() -> Bool {
        timer += 1
        if timer > step * 2 { timer = 0 }
        let d = Float(timer) / Float(step)
        var dp = d / 0.48
        if d > 1.0 {
            dp = 5.0 - 4.0 * d
            if dp < 0.0 { return false }
        } else if dp > 1.0 { dp = 1.0 }
        
        var v = vertexData!
        [[0, 3], [1, 2], [4, 5], [7, 6]].forEach { index in
            v[index[0]].position =
                v[index[1]].position + (v[index[0]].position - v[index[1]].position) * dp
        }
        var bufferPoint = vertexBuffer.contents()
        memcpy(bufferPoint, v, MemoryLayout<Vertex>.stride * v.count)
        
        let angle = (d * 5.4 * exp(-1.6 * d) + 0.1667) * Float.pi
        matrix.rotationMatrix(float3(0.0, 0.0, angle))
        bufferPoint = uniformBuffer.contents()
        memcpy(bufferPoint, matrix.m, MemoryLayout<Float>.stride * 16)
        
        return true
    }

    @discardableResult
    override func setCommandEncoder(cb: MTLCommandBuffer, rpd: MTLRenderPassDescriptor) -> Bool {
        super.setCommandEncoder(cb: cb, rpd: rpd)
        let flag = update()
        if flag {
            commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
            commandEncoder.setVertexBytes(&aspect, length: MemoryLayout<Float>.stride, index: 3)
            commandEncoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 0)
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
