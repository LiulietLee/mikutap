//
//  PlaceholderAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 12/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class PlaceholderAnimation: AbstractAnimation {
    
    private var buffer: MTLBuffer!
    
    init(device: MTLDevice) {
        super.init(device: device, aspect: 1.0)
        let position = [
            float4(1.1, 1.1, 0.0, 1.0),
            float4(2.1, 2.1, 0.0, 1.0),
            float4(3.3, 3.3, 0.0, 1.0)
        ]
        buffer = device.makeBuffer(
            bytes: position,
            length: MemoryLayout<float4>.stride * 3,
            options: []
        )
        registerShaders(
            vertexFunctionName: "placeholder_vertex_func",
            fragmentFunctionName: "placeholder_fragment_func"
        )
    }
    
    required init(device: MTLDevice, aspect: CGFloat) {
        fatalError("init(device:aspect:) has not been implemented")
    }
    
    override func setCommandEncoder(cb: MTLCommandBuffer, rpd: MTLRenderPassDescriptor) -> Bool {
        super.setCommandEncoder(cb: cb, rpd: rpd)
        commandEncoder.setVertexBuffer(buffer, offset: 0, index: 0)
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        commandEncoder.endEncoding()
        return true
    }
}
