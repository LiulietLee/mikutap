//
//  PresentationShader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 20/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 presentation_vertex_func(constant float4 *vertex_array [[buffer(0)]],
                                       constant float &aspect [[buffer(1)]],
                                       uint vid [[vertex_id]])
{
    float4 out = vertex_array[vid];
    out.x *= aspect;
    return out;
}

fragment float4 presentation_fragment_func(constant float4 &color [[buffer(0)]]) {
    return color;
}
