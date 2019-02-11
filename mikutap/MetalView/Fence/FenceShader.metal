//
//  FenceShader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 10/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 square_fence_vertex_func(constant float4 *vertex_array [[buffer(0)]],
                                       constant float4x4 &uniforms [[buffer(1)]],
                                       uint vid [[vertex_id]])
{
    float4 in = vertex_array[vid];
    float4 out = uniforms * in;
    return out;
}

vertex float4 round_fence_vertex_func(constant float4 *vertex_array [[buffer(0)]],
                                      constant float4x4 &uniforms [[buffer(1)]],
                                      constant float4x4 &rotates [[buffer(2)]],
                                      constant float4x4 &scale [[buffer(3)]],
                                      uint vid [[vertex_id]])
{
    float4 in = vertex_array[vid];
    float4 out = uniforms * rotates * scale * in;
    return out;
}

bool inBound(float x, float y) {
    return -0.8 < x && x < 0.8 && -0.8 < y && y < 0.8;
}

fragment float4 square_fence_fragment_func(float2 point_coord [[point_coord]]) {
    if (!inBound(point_coord.x, point_coord.y)) {
        discard_fragment();
    }
    return float(1.0);
}

fragment float4 round_fence_fragment_func(constant float &scale [[buffer(0)]],
                                          float2 point_coord [[point_coord]])
{
    if (!inBound(point_coord.x, point_coord.y) || length(point_coord) > 0.8 * scale) {
        discard_fragment();
    }
    return float(1.0);
}
