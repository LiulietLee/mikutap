//
//  SampleAnimationClass.swift
//  mikutap
//
//  Created by Liuliet.Lee on 20/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit

class SampleAnimationClass: AnimationDelegate {
    var orignTrangle = [Triangle]()
    
    var trangle: [Triangle]
    
    var duration: Int
    
    var shaderColor: UIColor
    
    required init() {
        let pos = [
            Position(x: 0.0, y: 0.5),
            Position(x: 0.5, y: -0.5),
            Position(x: -0.5, y: -0.5)
        ]
        trangle = [Triangle(pos)]
        orignTrangle = trangle
        
        duration = 50
        shaderColor = .white
    }
    
    func update(_ schedule: Float) {
        trangle = orignTrangle
        trangle[0].scale(schedule)
    }

}
