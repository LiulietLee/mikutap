//
//  Shader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 2/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 polygon_fill_vertex_func(constant float4 *vertices [[buffer(0)]],
                           constant float2 *offset [[buffer(1)]],
                           constant float &d [[buffer(2)]],
                           uint vid [[vertex_id]])
{
    float4 in = vertices[vid];
    float4 out = in;
    out.xy += d * offset[vid].xy;
    return out;
}

fragment float4 polygon_fill_fragment_func(constant float4 &color [[buffer(0)]])
{
    return color;
}

