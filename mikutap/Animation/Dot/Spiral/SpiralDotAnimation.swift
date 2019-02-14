//
//  LogDotAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 9/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class SpiralDotAnimation: DotAnimation {
    
    private var uniformBuffer: MTLBuffer!

    override init(device: MTLDevice, aspect: CGFloat) {
        super.init(device: device, aspect: aspect)
        createBuffer()
        registerShaders(
            vertexFunctionName: "spiral_dot_vertex_func",
            fragmentFunctionName: "rounded_dot_fragment_func"
        )
    }
    
    private func createBuffer() {
        var pointData = [PointInfo]()
        for i in 1...pointCount {
            let theta = Double(i) * Double.pi / 7.0 * exp(-Double(i) * 0.001)
            let r = 0.03 + 0.07 * theta
            let x = Float(r * cos(theta)), y = Float(r * sin(theta))
            pointData.append(PointInfo(
                position: float4(x, y, 0.0, 1.0),
                timer: -i * 3 / 2,
                radius: Float(i) + 7.0,
                color: color
            ))
        }
        pointBuffer = device.makeBuffer(
            bytes: pointData,
            length: MemoryLayout<PointInfo>.stride * pointData.count,
            options: []
        )
        
        var matrix = Matrix()
        matrix.rotationMatrix(float3(0.0, 0.0, Float.random(in: 0.0...Float.pi * 2)))
        uniformBuffer = device.makeBuffer(
            bytes: matrix.m,
            length: MemoryLayout<Float>.stride * 16,
            options: []
        )
    }

    override func setCommandEncoder(cb: MTLCommandBuffer, rpd: MTLRenderPassDescriptor) -> Bool {
        super.setCommandEncoder(cb: cb, rpd: rpd)
        let flag = checkValid()
        if flag {
            commandEncoder.setVertexBuffer(pointBuffer, offset: 0, index: 0)
            commandEncoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
            commandEncoder.setVertexBytes(&aspect, length: MemoryLayout<Float>.stride, index: 2)
            commandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: pointCount)
        }
        commandEncoder.endEncoding()
        return flag
    }
}
