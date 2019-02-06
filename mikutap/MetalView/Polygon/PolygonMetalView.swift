//
//  MetalView.swift
//  mikutap
//
//  Created by Liuliet.Lee on 2/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class PolygonMetalView: AbstractMetalView {
    
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var offsetBuffer: MTLBuffer!
    private var rateBuffer: MTLBuffer!
    
    private var offset_data: [float2]!
    private var vertex_count: UInt16!
    
    private let step = 35
    private var timer = 0
    
    private func commonInit() {
        createBuffers()
        registerShaders(vertexName: "polygon_vertex_func", fragName: "polygon_fragment_func")
    }
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func createBuffers() {        
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
    
    private func update() {
        timer += 1
        var d = rate()
        let bufferPoint = rateBuffer.contents()
        memcpy(bufferPoint, &d, MemoryLayout<Float>.stride)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        autoreleasepool {
            semaphore.wait()
            
            if let rpd = currentRenderPassDescriptor, let drawable = currentDrawable {
                rpd.colorAttachments[0].texture = drawable.texture
                rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.7, 0.5, 0.7, 0.0)
                let commandBuffer = commandQueue!.makeCommandBuffer()
                let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
                commandEncoder?.setRenderPipelineState(rps!)
                if timer <= step {
                    update()
                    commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                    commandEncoder?.setVertexBuffer(offsetBuffer, offset: 0, index: 1)
                    commandEncoder?.setVertexBuffer(rateBuffer, offset: 0, index: 2)
                    commandEncoder?.drawIndexedPrimitives(
                        type: .triangle,
                        indexCount: indexBuffer.length / MemoryLayout<UInt16>.stride,
                        indexType: .uint16,
                        indexBuffer: indexBuffer,
                        indexBufferOffset: 0
                    )
                } else {
                    removeFromSuperview()
                }
                commandEncoder?.endEncoding()
                commandBuffer?.addCompletedHandler({ cb in
                    self.semaphore.signal()
                })
                commandBuffer?.present(drawable)
                commandBuffer?.commit()
            }
        }
    }
}
