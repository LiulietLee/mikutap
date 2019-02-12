//
//  ExplosionSquareAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 8/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import Cocoa

class ExplosionSquareAnimation: ExplosionAnimation {
    init(device: MTLDevice, aspect: CGFloat) {
        super.init(device: device, type: .square, aspect: aspect)
    }
}
