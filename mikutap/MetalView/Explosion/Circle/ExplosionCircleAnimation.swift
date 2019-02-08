//
//  ExplosionCircleAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 8/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Cocoa

class ExplosionCircleAnimation: ExplosionAnimation {
    init(device: MTLDevice) {
        super.init(device: device, type: .circle)
    }
}
