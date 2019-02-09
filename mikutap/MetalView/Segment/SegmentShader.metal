//
//  SegmentShader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 8/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

vertex Vertex segment_vertex_func(constant Vertex *vertex_array [[buffer(0)]],
                                  uint vid [[vertex_id]])
{
    return vertex_array[vid];
}

fragment float4 segment_fragment_func(Vertex vert [[stage_in]]) {
    return float4(1.0);
}
