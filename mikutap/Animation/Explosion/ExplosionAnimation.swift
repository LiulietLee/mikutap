//
//  ExplosionAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 8/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class ExplosionAnimation: AbstractAnimation {

    enum ExplosionType {
        case circle
        case square
    }
    
    private var vertexBuffer: MTLBuffer!
    private var rateBuffer: MTLBuffer!
    private var pointCount = Int()
    
    private var timer = 0
    private var step = 35
    internal var type = ExplosionType.square
    
    init(device: MTLDevice, type: ExplosionType = .square, aspect: CGFloat) {
        super.init(device: device, aspect: aspect)
        self.type = type
        createBuffer()
        if type == .square {
            registerShaders(
                vertexFunctionName: "explosion_vertex_func",
                fragmentFunctionName: "explosion_square_fragment_func"
            )
        } else {
            registerShaders(
                vertexFunctionName: "explosion_vertex_func",
                fragmentFunctionName: "explosion_circle_fragment_func"
            )
        }
    }
    
    required init(device: MTLDevice, aspect: CGFloat) {
        fatalError("init(device:aspect:) has not been implemented")
    }
    
    private func createBuffer() {
        pointCount = Int(arc4random_uniform(5)) + 10
        var vertexData = [Point]()
        let range: ClosedRange<Float> = type == .square ? 20.0...80.0 : 40.0...140.0
        for _ in 0..<pointCount {
            vertexData.append(Point(
                position: float4(
                    Float.random(in: -1.0...1.0),
                    Float.random(in: -1.0...1.0),
                    0.0, 1.0
                ),
                pointSize: Float.random(in: range)
            ))
        }
        
        vertexBuffer = device.makeBuffer(
            bytes: vertexData,
            length: MemoryLayout<Point>.stride * pointCount,
            options: []
        )
        
        rateBuffer = device.makeBuffer(
            length: MemoryLayout<Float>.stride,
            options: []
        )
    }
    
    private func update() -> Bool {
        timer += 1
        if timer > step { return false }
        var d = Float(timer) / Float(step)
        d = 1.0204 - 1.0204 * exp(-3.92 * d)
        let bufferPoint = rateBuffer.contents()
        memcpy(bufferPoint, &d, MemoryLayout<Float>.stride)
        return true
    }
    
    override func setCommandEncoder(cb: MTLCommandBuffer, rpd: MTLRenderPassDescriptor) -> Bool {
        super.setCommandEncoder(cb: cb, rpd: rpd)
        let flag = update()
        if flag {
            commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            commandEncoder.setVertexBuffer(rateBuffer, offset: 0, index: 1)
            commandEncoder.setFragmentBytes(&color, length: MemoryLayout<float4>.stride, index: 0)
            commandEncoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: pointCount)
        }
        commandEncoder.endEncoding()

        return flag
    }
    
}
