//
//  DotAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 10/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class DotAnimation: AbstractAnimation {
    struct PointInfo {
        var position: float4
        var pointSize: Float
        var radius: Float
        var valid: Int
        var timer: Int
        
        init(position: float4, timer: Int, radius: Float) {
            self.radius = radius
            self.position = position
            self.pointSize = 0.0
            self.timer = timer
            valid = 1
        }
    }
    
    internal var pointBuffer: MTLBuffer!
    
    internal var timer = 0
    internal var step = 150
    internal var pointCount = 40
    
    override init(device: MTLDevice) {
        super.init(device: device)
    }
        
    internal func checkValid() -> Bool {
        timer += 1
        return timer < step
    }

}
