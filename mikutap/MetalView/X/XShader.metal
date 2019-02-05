//
//  XShader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 4/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Uniforms {
    float4x4 modelMatrix;
};

vertex Vertex x_vertex_func(constant Vertex *vertices [[buffer(0)]],
                            constant Uniforms &uniforms [[buffer(1)]],
                            constant float &d [[buffer(2)]],
                            uint vid [[vertex_id]])
{
    float4x4 matrix = uniforms.modelMatrix;
    Vertex in = vertices[vid];
    Vertex out;
    out.position = matrix * float4(in.position);
    out.color = in.color;
    return out;
}

fragment float4 x_fragment_func(Vertex v [[stage_in]]) {
    return v.color;
}
