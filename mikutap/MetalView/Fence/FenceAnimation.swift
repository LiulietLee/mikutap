//
//  FenceAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 10/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class FenceAnimation: AbstractAnimation {
    
    enum FenceType {
        case square
        case round
    }
    
    private var vertexBuffer: MTLBuffer!
    private var indexBuffer: MTLBuffer!
    private var translationBuffer: MTLBuffer!
    
    private var direction = float2()
    private var step = 48
    private var timer = 0
    private var scale = Float()
    private var rotateAngle = Float()
    private var scaleMatrix = Matrix()
    private var rotateMatrix = Matrix()
    
    private var type = FenceType.square
    
    init(device: MTLDevice, type: FenceType) {
        super.init(device: device)
        self.type = type
        createBuffer()
        if type == .square {
            registerShaders(
                vertexFunctionName: "square_fence_vertex_func",
                fragmentFunctionName: "square_fence_fragment_func"
            )
        } else {
            registerShaders(
                vertexFunctionName: "round_fence_vertex_func",
                fragmentFunctionName: "round_fence_fragment_func"
            )
        }
    }
    
    private func createBuffer() {
        let rectangleCount = Int(arc4random_uniform(8) + 2)
        let widthCount = 2 * rectangleCount + 1
        let width = 1.6 / Float(widthCount)
        var vertexData = [Vertex](), indexData = [UInt16]()
        var matrix = Matrix()
        
        if arc4random_uniform(2) == 0 {
            if arc4random_uniform(2) == 0 {
                direction.x = 1.0
            } else {
                direction.x = -1.0
            }
        } else {
            if arc4random_uniform(2) == 0 {
                direction.y = 1.0
            } else {
                direction.y = -1.0
            }
        }
        
        for i in 0..<rectangleCount {
            var vertices = [Vertex](), indexes = [UInt16]()
            
            if direction.y == 0.0 {
                (vertices, indexes) = PolygonFactory.getRectangle(withWidth: 2.5, andHeight: width)
                matrix.translationMatrix(float3(
                    -direction.x * (2.0 + Float.random(in: 0.0...0.8)),
                    0.8 - (2 * Float(i + 1) - 1) * width - vertices[0].position.y,
                    0.0
                ))
            } else {
                (vertices, indexes) = PolygonFactory.getRectangle(withWidth: width, andHeight: 2.5)
                matrix.translationMatrix(float3(
                    0.8 - (2 * Float(i + 1) - 1) * width - vertices[0].position.x,
                    -direction.y * (2.0 + Float.random(in: 0.0...0.8)),
                    0.0
                ))
            }
            
            var m = float4x4()
            memcpy(&m, matrix.m, MemoryLayout<Float>.stride * 16)
            for j in 0..<vertices.count {
                vertices[j].position = matrix_multiply(m, vertices[j].position)
            }
            
            for j in 0..<indexes.count {
                indexes[j] += 4 * UInt16(i)
            }
            
            vertexData.append(contentsOf: vertices)
            indexData.append(contentsOf: indexes)
            
            if type == .round { rotateAngle = Float.random(in: -Float.pi / 2...Float.pi / 2) }
        }
        
        vertexBuffer = device.makeBuffer(
            bytes: vertexData,
            length: MemoryLayout<Vertex>.stride * vertexData.count,
            options: []
        )
        
        indexBuffer = device.makeBuffer(
            bytes: indexData,
            length: MemoryLayout<UInt16>.stride * indexData.count,
            options: []
        )
        
        translationBuffer = device.makeBuffer(
            length: MemoryLayout<Float>.stride * 16,
            options: []
        )
    }
    
    private func update() -> Bool {
        timer += 1
        if timer > step { return false }
        let d = Float(timer) / Float(step)
        var matrix = Matrix()
        
        if type == .round {
            let td = 1.0204 - 1.0204 * exp(-3.92 * d)
            scale = 2.0 - 1.2 * sin(1.16 * d + 1.0)
            scaleMatrix.scalingMatrix(scale)
            rotateMatrix.rotationMatrix(float3(0.0, 0.0, td * rotateAngle))
            let dir = float2(
                direction.x * cos(td * rotateAngle) - direction.y * sin(td * rotateAngle),
                direction.y * cos(td * rotateAngle) + direction.x * sin(td * rotateAngle)
            )
            matrix.translationMatrix(float3(5.5 * d * dir.x, 5.5 * d * dir.y, 0.0))
        } else {
            matrix.translationMatrix(float3(5.5 * d * direction.x, 5.5 * d * direction.y, 0.0))
        }

        let bufferPoint = translationBuffer.contents()
        memcpy(bufferPoint, matrix.m, MemoryLayout<Float>.stride * 16)

        return true
    }
    
    override func setCommandEncoder(cb: MTLCommandBuffer, rpd: MTLRenderPassDescriptor) -> Bool {
        super.setCommandEncoder(cb: cb, rpd: rpd)
        let flag = update()
        if flag {
            commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
            commandEncoder.setVertexBuffer(translationBuffer, offset: 0, index: 1)
            if type == .round {
                commandEncoder.setFragmentBytes(
                    &scale,
                    length: MemoryLayout<Float>.stride,
                    index: 0
                )
                commandEncoder.setVertexBytes(
                    rotateMatrix.m,
                    length: MemoryLayout<Float>.stride * 16,
                    index: 2
                )
                commandEncoder.setVertexBytes(
                    scaleMatrix.m,
                    length: MemoryLayout<Float>.stride * 16,
                    index: 3
                )
            }
            commandEncoder.drawIndexedPrimitives(
                type: .triangle,
                indexCount: indexBuffer.length / MemoryLayout<UInt16>.stride,
                indexType: .uint16,
                indexBuffer: indexBuffer,
                indexBufferOffset: 0
            )
        }
        commandEncoder.endEncoding()
        return flag
    }

}
