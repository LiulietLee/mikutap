//
//  AnimationDelegate.swift
//  mikutap
//
//  Created by Liuliet.Lee on 20/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit

protocol AnimationDelegate: class {
    var trangle: [Triangle] { get set }
    var duration: Int { get set }
    var shaderColor: UIColor { get set }
    init()
    func update(_ schedule: Float)
}
