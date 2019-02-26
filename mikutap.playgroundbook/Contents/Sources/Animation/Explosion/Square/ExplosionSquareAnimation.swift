//
//  ExplosionSquareAnimation.swift
//  mikutap
//
//  Created by Liuliet.Lee on 8/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class ExplosionSquareAnimation: ExplosionAnimation {

    required init(device: MTLDevice, width: CGFloat, height: CGFloat) {
        super.init(device: device, type: .square, width: width, height: height)
    }
}
