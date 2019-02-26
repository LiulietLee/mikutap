//
//  AnimationDelegate.swift
//  mikutap
//
//  Created by Liuliet.Lee on 20/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit

public protocol AnimationDelegate: class {
    var triangle: [Triangle] { get set }
    var duration: Int { get set }
    var shaderColor: UIColor { get set }
    init()
    func update(_ schedule: Float)
}
