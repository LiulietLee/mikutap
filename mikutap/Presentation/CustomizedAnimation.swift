//
//  PresentationAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 20/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class CustomizedAnimation: AbstractAnimation {
    
    private var delegate: AnimationDelegate? = nil
    private var vertexData = [Vertex]()
    
    private var timer = 0
    private var step = 1
    
    init(device: MTLDevice, width: CGFloat, height: CGFloat, delegate: AnimationDelegate.Type) {
        super.init(device: device, width: width, height: height)
        self.delegate = delegate.init()
        step = self.delegate!.duration
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.delegate!.shaderColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        color = float4(Float(r), Float(g), Float(b), Float(a))
        registerShaders(
            vertexFunctionName: "presentation_vertex_func",
            fragmentFunctionName: "presentation_fragment_func"
        )
    }
    
    required init(device: MTLDevice, width: CGFloat, height: CGFloat) {
        fatalError("init(device:width:height:) has not been implemented")
    }
    
    private func update() -> Bool {
        timer += 1
        if timer > step { return false }
        let rate = Float(timer) / Float(step)
        delegate?.update(rate)
        vertexData = []
        for shape in delegate!.trangle {
            vertexData.append(contentsOf: shape.vertex.lazy.map({
                return Vertex(position: $0.location)
            }))
        }
        return true
    }
    
    override func setCommandEncoder(cb: MTLCommandBuffer, rpd: MTLRenderPassDescriptor) -> Bool {
        super.setCommandEncoder(cb: cb, rpd: rpd)
        let flag = update()
        if flag {
            commandEncoder.setVertexBytes(
                vertexData,
                length: MemoryLayout<Vertex>.stride * vertexData.count,
                index: 0
            )
            commandEncoder.setVertexBytes(&aspect, length: MemoryLayout<Float>.stride, index: 1)
            commandEncoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 0)
            commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexData.count)
        }
        commandEncoder.endEncoding()
        return flag
    }
}
