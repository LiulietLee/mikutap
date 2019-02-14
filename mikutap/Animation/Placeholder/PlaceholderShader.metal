//
//  PlaceholderShader.metal
//  mikutap
//
//  Created by Liuliet.Lee on 12/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 placeholder_vertex_func(constant float4 *position [[buffer(0)]],
                                      uint vid [[vertex_id]])
{
    return position[vid];
}

fragment float4 placeholder_fragment_func() {
    return float4(1.0);
}
