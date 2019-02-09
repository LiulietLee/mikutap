//
//  XShader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 4/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 x_vertex_func(constant float4 *vertices [[buffer(0)]],
                            constant float4x4 &uniforms [[buffer(1)]],
                            constant float &d [[buffer(2)]],
                            uint vid [[vertex_id]])
{
    float4 in = vertices[vid];
    float4 out = uniforms * in;
    return out;
}

fragment float4 x_fragment_func() {
    return float4(1.0);
}
