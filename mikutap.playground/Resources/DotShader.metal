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
    float4 color;
    float point_size [[point_size]];
    float radius;
    int valid;
    int begin;
    int timer;
};

vertex Point spiral_dot_vertex_func(device Point *point_array [[buffer(0)]],
                                    constant float4x4 &uniforms [[buffer(1)]],
                                    constant float &aspect [[buffer(2)]],
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
    out.position = uniforms * out.position;
    out.position.x *= aspect;
    return out;
}

vertex Point shake_dot_vertex_func(device Point *point_array [[buffer(0)]],
                                   uint vid [[vertex_id]])
{
    int t = point_array[vid].timer++;
    float radius = point_array[vid].radius;
    if (t >= 0 && point_array[vid].valid) {
        if (t < 20) {
            point_array[vid].point_size = radius * (1 - exp(-0.3 * t) * cos(t / 20.0 * M_PI_2_F * 7));
        } else if (t > 40) {
            point_array[vid].point_size = radius / 0.7 * sin(2.42 * (t - 40.0) / 30.0 + 0.62);
            if (point_array[vid].point_size <= 0) {
                point_array[vid].point_size = 0;
                point_array[vid].valid = 0;
            }
        }
    }
    return point_array[vid];
}

fragment float4 rounded_dot_fragment_func(Point p [[stage_in]],
                                          float2 point_coord [[point_coord]]) {
    if (length(point_coord - float2(0.5)) > 0.5) {
        discard_fragment();
    }
    return p.color;
}
