//
//  FlashView.swift
//  mikutap
//
//  Created by Liuliet.Lee on 17/2/2019.
//  Copyright © 2019 Liuliet.Lee. All rights reserved.
//

import UIKit

class FlashView: UIView {

    private func commonInit() {
        backgroundColor = .clear
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func flash() {
        backgroundColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0.5)
        UIView.animate(withDuration: 0.1) {
            self.backgroundColor = .clear
        }
    }
}
