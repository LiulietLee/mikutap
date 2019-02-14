//
//  AbstractAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 6/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class AbstractAnimation {
    
    internal var renderPipelineState: MTLRenderPipelineState!
    internal var device: MTLDevice!
    internal var commandEncoder: MTLRenderCommandEncoder!

    internal var aspect = Float()
    internal var color = float4()
    
    init(device: MTLDevice, aspect: CGFloat) {
        self.aspect = Float(aspect)
        self.device = device
        color = ColorPool.shared.getShaderColor()
    }
    
    internal func registerShaders(vertexFunctionName: String,fragmentFunctionName: String) {
        let library = device.makeDefaultLibrary()!
        let vertexFunc = library.makeFunction(name: vertexFunctionName)
        let fragmentFunc = library.makeFunction(name: fragmentFunctionName)
        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vertexFunc
        rpld.fragmentFunction = fragmentFunc
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            renderPipelineState = try device.makeRenderPipelineState(descriptor: rpld)
        } catch let error {
            fatalError("\(error)")
        }
    }
        
    @discardableResult
    func setCommandEncoder(cb: MTLCommandBuffer, rpd: MTLRenderPassDescriptor) -> Bool {
        commandEncoder = cb.makeRenderCommandEncoder(descriptor: rpd)!
        commandEncoder.setRenderPipelineState(renderPipelineState!)
        return true
    }
    
}
