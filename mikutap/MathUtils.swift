//
//  MathUtils.swift
//  mikutap
//
//  Created by Liuliet.Lee on 2/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import simd

struct Vertex {
    var position: float4
    var color: float4
}

struct Matrix {
    var m: [Float]
    
    init() {
        m = [1, 0, 0, 0,
             0, 1, 0, 0,
             0, 0, 1, 0,
             0, 0, 0, 1]
    }
    
    mutating func translationMatrix(_ position: float3) {
        m[12] = position.x
        m[13] = position.y
        m[14] = position.z
    }
    
    mutating func scalingMatrix(_ scale: Float) {
        m[0] = scale
        m[5] = scale
        m[10] = scale
        m[15] = 1.0
    }
    
    mutating func rotationMatrix(_ rot: float3) {
        m[0] = cos(rot.y) * cos(rot.z)
        m[4] = cos(rot.z) * sin(rot.x) * sin(rot.y) - cos(rot.x) * sin(rot.z)
        m[8] = cos(rot.x) * cos(rot.z) * sin(rot.y) + sin(rot.x) * sin(rot.z)
        m[1] = cos(rot.y) * sin(rot.z)
        m[5] = cos(rot.x) * cos(rot.z) + sin(rot.x) * sin(rot.y) * sin(rot.z)
        m[9] = -cos(rot.z) * sin(rot.x) + cos(rot.x) * sin(rot.y) * sin(rot.z)
        m[2] = -sin(rot.y)
        m[6] = cos(rot.y) * sin(rot.x)
        m[10] = cos(rot.x) * cos(rot.y)
        m[15] = 1.0
    }
}
