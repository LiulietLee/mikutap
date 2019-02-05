//
//  AbstractMetalView.swift
//  mikutap
//
//  Created by Liuliet.Lee on 3/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class AbstractMetalView: MTKView {

    internal var commandQueue: MTLCommandQueue?
    internal var rps: MTLRenderPipelineState?
    internal var semaphore: DispatchSemaphore!
    
    private func commonInit() {
        semaphore = DispatchSemaphore(value: 1)
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device!.makeCommandQueue()
    }
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    internal func registerShaders(vertexName: String = "", fragName: String = "") {
        let library = device!.makeDefaultLibrary()!
        let vertex_func = library.makeFunction(name: vertexName)
        let frag_func = library.makeFunction(name: fragName)
        let rpld = MTLRenderPipelineDescriptor()
        rpld.vertexFunction = vertex_func
        rpld.fragmentFunction = frag_func
        rpld.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            try rps = device!.makeRenderPipelineState(descriptor: rpld)
        } catch let error {
            self.printView("\(error)")
        }
    }
}
