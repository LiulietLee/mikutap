//
//  ColorPool.swift
//  mikutap
//
//  Created by Liuliet.Lee on 12/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import MetalKit

class ColorPool {
    
    typealias Color = float4
    
    static let shared = ColorPool()
    
    private var colorPool = [
        Color(0.545098, 0.8, 0.8, 1),
        Color(0.129412, 0.666667, 0.627451, 1),
        Color(1, 1, 1, 1),
        Color(0.560784, 0.854902, 0.92549, 1),
        Color(0.964706, 0.831373, 0.8, 1),
        Color(0.831373, 0.619608, 0.627451, 1),
        Color(0.196078, 0.168627, 0.180392, 1),
        Color(0.356863, 0.309804, 0.345098, 1),
        Color(0.976471, 0.254902, 0.47451, 1),
        Color(0.811765, 0.937255, 0.941176, 1),
        Color(0.133333, 0.627451, 0.701961, 1),
        Color(0.0823529, 0.533333, 0.611765, 1),
        Color(0.270588, 0.266667, 0.270588, 1),
        Color(0.92549, 0.341176, 0.52549, 1)
    ]
    
    private func build(_ r: Double, _ g: Double, _ b: Double) -> MTLClearColor {
        return MTLClearColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
