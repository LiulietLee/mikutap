//
//  TransitionShader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 12/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 transition_vertex_func(constant float4 *vertex_array [[buffer(0)]],
                                     uint vid [[vertex_id]])
{
    return vertex_array[vid];
}

fragment float4 transition_fragment_func() {
    return float4(1.0);
}
