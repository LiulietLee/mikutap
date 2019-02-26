//
//  ExplosionShader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 8/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Point {
    float4 position [[position]];
    float point_size [[point_size]];
};

vertex Point explosion_vertex_func(constant Point *point_array [[buffer(0)]],
                                   constant float &d [[buffer(1)]],
                                   uint pid [[vertex_id]])
{
    Point in = point_array[pid];
    Point out = in;
    out.position.xy *= d;
    return out;
}

fragment float4 explosion_square_fragment_func(constant float4 &color [[buffer(0)]])
{
    return color;
}

fragment float4 explosion_circle_fragment_func(constant float4 &color [[buffer(0)]],
                                               float2 point_coord [[point_coord]])
{
    if (length(point_coord - float2(0.5)) > 0.5 || length(point_coord - float2(0.5)) < 0.4) {
        discard_fragment();
    }
    return color;
}
