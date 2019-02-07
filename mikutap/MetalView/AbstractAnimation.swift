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

    init(device: MTLDevice) {
        self.device = device
    }
    
    internal func getRenderPipelineState(vertexFunctionName: String = "",fragmentFunctionName: String = "") -> MTLRenderPipelineState? {
        let library = device!.makeDefaultLibrary()!
        let vertex_func = library.makeFunction(name: vertexFunctionName)
        let frag_func = library.makeFunction(name: fragmentFunctionName)
        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vertex_func
        rpld.fragmentFunction = frag_func
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            let state = try device!.makeRenderPipelineState(descriptor: rpld)
            return state
        } catch let error {
            fatalError("\(error)")
        }
        return nil
    }
    
    @discardableResult
    func setCommandEncoder(cb: MTLCommandBuffer, rpd: MTLRenderPassDescriptor) -> Bool {
        commandEncoder = cb.makeRenderCommandEncoder(descriptor: rpd)!
        commandEncoder.setRenderPipelineState(renderPipelineState!)
        return true
    }
    
}
