//
//  XMetalView.swift
//  mikutap
//
//  Created by Liuliet.Lee on 3/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class XMetalView: AbstractMetalView {
    
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var uniformBuffer: MTLBuffer!
    private var rateBuffer: MTLBuffer!
    private var matrix: Matrix!
    private var vertexData: [Vertex]!
    
    private var timer = 0
    private var step = 40

    private func commonInit() {
        createBuffer()
        registerShaders(vertexName: "x_vertex_func", fragName: "x_fragment_func")
    }
    
    override init(frame frameRect: CGRect, device: MTLDevice?) {
        super.init(frame: frameRect, device: device)
        commonInit()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func createBuffer() {
        var vertex_data1 = [Vertex](), index_data1 = [UInt16](),
            vertex_data2 = [Vertex](), index_data2 = [UInt16]()
        
        let randw = 0.1 + Float.random(in: 0.0...0.1),
            randh = 0.8 + Float.random(in: 0.0...0.5)
        
        (vertex_data1, index_data1) = PolygonFactory.getRectangle(
            withWidth: randw, andHeight: randh
        )
        (vertex_data2, index_data2) = PolygonFactory.getRectangle(
            withWidth: randh, andHeight: randw
        )

        for i in 0..<index_data2.count {
            index_data2[i] += 4
        }
        
        vertex_data1.append(contentsOf: vertex_data2)
        index_data1.append(contentsOf: index_data2)
        vertexData = vertex_data1
        
        vertexBuffer = device!.makeBuffer(
            bytes: vertex_data1,
            length: MemoryLayout<Vertex>.size * vertex_data1.count,
            options: []
        )
        
        indexBuffer = device!.makeBuffer(
            bytes: index_data1,
            length: MemoryLayout<UInt16>.size * index_data1.count,
            options: []
        )
        
        matrix = Matrix()
        matrix.translationMatrix(float3(
            Float.random(in: -0.2...0.2), Float.random(in: -0.2...0.2), 0.0
        ))

        uniformBuffer = device!.makeBuffer(
            bytes: matrix.m,
            length: MemoryLayout<Float>.size * 16,
            options: []
        )
        
        rateBuffer = device!.makeBuffer(
            length: MemoryLayout<Float>.size,
            options: []
        )
    }
    
    private func update() {
        timer += 1
        if timer > step * 2 { timer = 0 }
        let d = Float(timer) / Float(step)
        var dp = d / 0.48
        if d > 1.0 {
            dp = 5.0 - 4.0 * d
            if dp < 0.0 { dp = 0.0 }
        } else if dp > 1.0 { dp = 1.0 }
        
        var v = vertexData!
        [[0, 3], [1, 2], [4, 5], [7, 6]].forEach { index in
            v[index[0]].position =
                v[index[1]].position + (v[index[0]].position - v[index[1]].position) * dp
        }
        var bufferPoint = vertexBuffer.contents()
        memcpy(bufferPoint, v, MemoryLayout<Vertex>.size * v.count)
        
        let angle = (d * 5.4 * exp(-1.6 * d) + 0.1667) * Float.pi
        matrix.rotationMatrix(float3(0.0, 0.0, angle))
        bufferPoint = uniformBuffer.contents()
        memcpy(bufferPoint, matrix.m, MemoryLayout<Float>.size * 16)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        autoreleasepool {
            semaphore.wait()
            
            if let drawable = currentDrawable, let rpd = currentRenderPassDescriptor {
                rpd.colorAttachments[0].texture = drawable.texture
                rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.7, 0.5, 0.7, 0.0)
                let commandBuffer = commandQueue!.makeCommandBuffer()
                let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: rpd)
                commandEncoder?.setRenderPipelineState(rps!)
//                if timer <= step {
                    update()
                    commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
                    commandEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
                    commandEncoder?.setVertexBuffer(rateBuffer, offset: 0, index: 2)
                    commandEncoder?.drawIndexedPrimitives(
                        type: .triangle,
                        indexCount: indexBuffer.length / MemoryLayout<UInt16>.size,
                        indexType: .uint16,
                        indexBuffer: indexBuffer,
                        indexBufferOffset: 0
                    )
//                } else {
//                    // removeFromSuperview()
//                }
                commandEncoder?.endEncoding()
                commandBuffer?.present(drawable)
                commandBuffer?.addCompletedHandler({ cb in
                    self.semaphore.signal()
                })
                commandBuffer?.commit()
            }
        }
    }
    
}
