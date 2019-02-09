//
//  Shader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 2/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
};

struct Uniforms {
    float4x4 modelMatrix;
};

vertex Vertex polygon_vertex_func(constant Vertex *vertices [[buffer(0)]],
                           constant float2 *offset [[buffer(1)]],
                           constant float &d [[buffer(2)]],
                           uint vid [[vertex_id]]) {
    Vertex in = vertices[vid];
    Vertex out = in;
    out.position.xy += d * offset[vid].xy;
    return out;
}

fragment float4 polygon_fragment_func(Vertex vert [[stage_in]]) {
    return float4(1.0);
}

