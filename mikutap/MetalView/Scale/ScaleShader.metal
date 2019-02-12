//
//  ScaleShader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 9/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 scale_vertex_func(constant float4 *vertex_array [[buffer(0)]],
                                constant float4x4 &rotates [[buffer(1)]],
                                constant float4x4 &scale [[buffer(2)]],
                                constant float &w [[buffer(3)]],
                                constant float &aspect [[buffer(4)]],
                                uint vid [[vertex_id]])
{
    float4 in = vertex_array[vid];
    float4 out = scale * rotates * in;
    out.x *= aspect;
    return out;
}

fragment float4 scale_fragment_func() {
    return float(1.0);
}

