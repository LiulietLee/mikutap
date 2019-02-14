//
//  ShakeDotAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 10/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class ShakeDotAnimation: DotAnimation {

    override init(device: MTLDevice, aspect: CGFloat) {
        super.init(device: device, aspect: aspect)
        createBuffer()
        registerShaders(
            vertexFunctionName: "shake_dot_vertex_func",
            fragmentFunctionName: "rounded_dot_fragment_func"
        )
    }
    
    private func createBuffer() {
        var pointData = [PointInfo]()
        pointCount = Int(arc4random_uniform(6) + 7)
        for i in 0..<pointCount {
            pointData.append(PointInfo(
                position: float4(
                    Float.random(in: -1.0...1.0),
                    Float.random(in: -1.0...1.0),
                    0.0, 1.0
                ),
                timer: -i,
                radius: Float.random(in: 100.0...200.0),
                color: ColorPool.shared.getShaderColor()
            ))
        }
        pointBuffer = device.makeBuffer(
            bytes: pointData,
            length: MemoryLayout<PointInfo>.stride * pointData.count,
            options: []
        )
    }
    
    override func setCommandEncoder(cb: MTLCommandBuffer, rpd: MTLRenderPassDescriptor) -> Bool {
        super.setCommandEncoder(cb: cb, rpd: rpd)
        let flag = checkValid()
        if flag {
            commandEncoder.setVertexBuffer(pointBuffer, offset: 0, index: 0)
            commandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: pointCount)
        }
        commandEncoder.endEncoding()
        return flag
    }
}
