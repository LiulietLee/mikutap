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
    
    private var backgroundColorIndex = 1
    
    private var colorPool = [
        Color(1.000, 1.000, 1.000, 1.000),
        Color(0.545, 0.800, 0.800, 1.000),
        Color(0.129, 0.667, 0.627, 1.000),
        Color(0.561, 0.855, 0.925, 1.000),
        Color(0.965, 0.831, 0.800, 1.000),
        Color(0.831, 0.620, 0.627, 1.000),
        Color(0.196, 0.169, 0.180, 1.000),
        Color(0.357, 0.310, 0.345, 1.000),
        Color(0.976, 0.255, 0.475, 1.000),
        Color(0.812, 0.937, 0.941, 1.000),
        Color(0.133, 0.627, 0.702, 1.000),
        Color(0.082, 0.533, 0.612, 1.000),
        Color(0.271, 0.267, 0.271, 1.000),
        Color(0.925, 0.341, 0.525, 1.000)
    ]
    
    private var colorCount: Int {
        return colorPool.count
    }
    
    private func nextIndex() -> Int {
        var index = backgroundColorIndex
        while index == backgroundColorIndex {
            index = Int.random(in: 0..<colorCount)
        }
        return index
    }
    
    func getCurrentBackgroundColor() -> MTLClearColor {
        return build(colorPool[backgroundColorIndex])
    }
    
    func getShaderColor() -> Color {
        return colorPool[nextIndex()]
    }
    
    func resetBackgroundColor() -> Color {
        var idx = nextIndex()
        while idx == 0 { idx = nextIndex() }
        backgroundColorIndex = idx
        return colorPool[backgroundColorIndex]
    }
    
    private func build(_ color: Color) -> MTLClearColor {
        return MTLClearColor(
            red: Double(color.x), green: Double(color.y),
            blue: Double(color.z), alpha: Double(color.w)
        )
    }
}
