//
//  Geometric.swift
//  mikutap
//
//  Created by Liuliet.Lee on 20/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import simd

public struct Position {
    public var location: float4
    
    public var x: Float {
        get { return location.x }
        set { location.x = newValue }
    }

    public var y: Float {
        get { return location.y }
        set { location.y = newValue }
    }
    
    public init() { location = float4() }
    public init(x: Float, y: Float) { location = float4(x, y, 0.0, 1.0) }
    
    public mutating func transform(_ matrix: float4x4) {
        location = matrix_multiply(matrix, location)
    }
    
    public mutating func translate(x: Float, y: Float) {
        var matrix = Matrix()
        matrix.translationMatrix(float3(x, y, 0.0))
        transform(matrix.tofloat4x4())
    }
    
    public mutating func rotate(_ angle: Float) {
        var matrix = Matrix()
        matrix.rotationMatrix(float3(0.0, 0.0, angle))
        transform(matrix.tofloat4x4())
    }
}

public struct Triangle {
    public var vertex = Array(repeating: Position(), count: 3)
    
    public init() {}
    public init(_ pos: [Position]) {
        for i in 0..<min(3, pos.count) {
            vertex[i] = pos[i]
        }
    }
    public init(_ pos0: Position, _ pos1: Position, _ pos2: Position) {
        vertex[0] = pos0
        vertex[1] = pos1
        vertex[2] = pos2
    }
    
    public mutating func translate(x: Float, y: Float) {
        var matrix = Matrix()
        matrix.translationMatrix(float3(x, y, 0.0))
        let mat = matrix.tofloat4x4()
        for i in 0..<3 { vertex[i].transform(mat) }
    }
    
    public mutating func scale(_ s: Float) {
        var matrix = Matrix()
        matrix.scalingMatrix(s)
        let mat = matrix.tofloat4x4()
        for i in 0..<3 { vertex[i].transform(mat) }
    }
    
    public mutating func rotate(_ angle: Float) {
        var matrix = Matrix()
        matrix.rotationMatrix(float3(0.0, 0.0, angle))
        let mat = matrix.tofloat4x4()
        for i in 0..<3 { vertex[i].transform(mat) }
    }
}

import UIKit

extension Position: CustomPlaygroundDisplayConvertible {
    public var playgroundDescription: Any {
        return CGPoint(x: CGFloat(location.x), y: CGFloat(location.y))
    }
}

extension Triangle: CustomPlaygroundDisplayConvertible {
    func getPoint(index: Int) -> CGPoint {
        return CGPoint(
            x: CGFloat(vertex[index].location.x * 100),
            y: CGFloat(-vertex[index].location.y * 100)
        )
    }
    
    public var playgroundDescription: Any {
        let trianglePath = UIBezierPath()
        trianglePath.move(to: getPoint(index: 0))
        trianglePath.addLine(to: getPoint(index: 1))
        trianglePath.addLine(to: getPoint(index: 2))
        trianglePath.close()
        return trianglePath
    }
}
