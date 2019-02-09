//
//  CircleShader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 6/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
};

struct Frag {
    float4 color;
    float radius;
};

vertex Vertex circle_vertex_func(constant Vertex *vertices [[buffer(0)]],
                                 uint vid [[vertex_id]])
{
    Vertex in = vertices[vid];
    Vertex out;
    out.position = in.position;
    return out;
}

fragment float4 circle_fragment_func(Vertex v [[stage_in]],
                                     constant Frag &info [[buffer(0)]],
                                     constant float3 &indexes [[buffer(1)]],
                                     float2 point_coord [[point_coord]])
{
    if (length(point_coord) > info.radius) {
        discard_fragment();
    }
    
    float angle = atan2(point_coord.y, point_coord.x);
    if (point_coord.y < 0) {
        angle += 2 * M_PI_F;
    }
    angle -= indexes.z;
    if (angle < 0) angle += 2 * M_PI_F;
    if (indexes.y > angle || angle > indexes.x) {
        discard_fragment();
    }
    
    return info.color;
}
