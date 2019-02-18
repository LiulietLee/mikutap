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
    internal var vheight = Float()
    internal var vwidth = Float()
    internal var color = float4()
    
    internal var shaderFileName: String!
    
    required init(device: MTLDevice, width: CGFloat, height: CGFloat) {
        vheight = Float(height)
        vwidth = Float(width)
        self.aspect = Float(height / width)
        self.device = device
        color = ColorPool.shared.getShaderColor()
    }
    
    internal func registerShaders(vertexFunctionName: String,fragmentFunctionName: String) {
        let path = Bundle.main.path(forResource: shaderFileName, ofType: "metal")
        let input = try! String(contentsOfFile: path!, encoding: .utf8)
        let library = try! device.makeLibrary(source: input, options: nil)
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
