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
                                       constant float &aspect [[buffer(4)]],
                                       uint vid [[vertex_id]])
{
    float4 in = vertex_array[vid];
    float4 out = uniforms * in;
    out.x *= aspect;
    return out;
}

vertex float4 round_fence_vertex_func(constant float4 *vertex_array [[buffer(0)]],
                                      constant float4x4 &uniforms [[buffer(1)]],
                                      constant float4x4 &rotates [[buffer(2)]],
                                      constant float4x4 &scale [[buffer(3)]],
                                      constant float &aspect [[buffer(4)]],
                                      uint vid [[vertex_id]])
{
    float4 in = vertex_array[vid];
    float4 out = uniforms * rotates * scale * in;
    out.x *= aspect;
    return out;
}

bool inBound(float x, float y, float aspect) {
    return -0.8 * aspect < x && x < 0.8 * aspect && -0.8 < y && y < 0.8;
}

fragment float4 square_fence_fragment_func(float2 point_coord [[point_coord]],
                                           constant float &aspect [[buffer(1)]],
                                           constant float4 &color [[buffer(2)]])
{
    if (!inBound(point_coord.x, point_coord.y, aspect)) {
        discard_fragment();
    }
    return color;
}

fragment float4 round_fence_fragment_func(constant float &scale [[buffer(0)]],
                                          constant float &aspect [[buffer(1)]],
                                          constant float4 &color [[buffer(2)]],
                                          float2 point_coord [[point_coord]])
{
    float2 coor = point_coord;
    coor.x /= aspect;
    if (length(coor) > 0.8 * scale) {
        discard_fragment();
    }
    return color;
}
