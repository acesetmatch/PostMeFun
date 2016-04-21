//
//  MaterialLabel.swift
//  shawn-showcase
//
//  Created by Shawn on 4/3/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit

class MaterialLabel: UILabel {
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func drawTextInRect(rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 0.0, right: 10.0)
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, insets))
        
    }

}
