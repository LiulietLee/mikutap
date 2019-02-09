//
//  LogDotShader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 9/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct Point {;
    float4 position [[position]];
    float point_size [[point_size]];
    float radius;
    int valid;
    int begin;
    int timer;
};

struct Uniforms {
    float4x4 modelMatrix;
};

vertex Point Spiral_dot_vertex_func(device Point *point_array [[buffer(0)]],
                                 constant Uniforms &uniforms [[buffer(1)]],
                                 uint vid [[vertex_id]])
{
    int timer = point_array[vid].timer++;
    float radius = point_array[vid].radius;
    if (timer >= 0 && point_array[vid].valid) {
        if (timer < 20) {
            point_array[vid].point_size = radius * sin(timer / 20.0 * M_PI_2_F * 1.5);
        } else if (timer > 40) {
            point_array[vid].point_size = radius * cos((timer - 40.0) / 20.0 * M_PI_2_F);
            if (point_array[vid].point_size <= 0) {
                point_array[vid].point_size = 0;
                point_array[vid].valid = 0;
            }
        }
    }
    Point in = point_array[vid];
    Point out = in;
    out.position = uniforms.modelMatrix * out.position;
    return out;
}

fragment float4 Spiral_dot_fragment_func(Point p [[stage_in]],
                                      float2 point_coord [[point_coord]])
{
    if (length(point_coord - float2(0.5)) > 0.5) {
        discard_fragment();
    }
    return float4(1.0);
}
