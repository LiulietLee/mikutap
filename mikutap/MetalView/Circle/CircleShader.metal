//
//  CircleShader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 6/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 circle_vertex_func(constant float4 *vertices [[buffer(0)]],
                                 uint vid [[vertex_id]])
{
    float4 out = vertices[vid];
    return out;
}

fragment float4 circle_fragment_func(constant float &radius [[buffer(0)]],
                                     constant float3 &indexes [[buffer(1)]],
                                     constant float &aspect [[buffer(2)]],
                                     constant float4 &color [[buffer(3)]],
                                     float2 point_coord [[point_coord]])
{
    float2 coor = point_coord;
    coor.x /= aspect;
    
    if (length(coor) > radius) {
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
    
    return color;
}
