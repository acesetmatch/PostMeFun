//
//  MaterialTextField2.swift
//  shawn-showcase
//
//  Created by Shawn on 2/2/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit

class MaterialTextField2: UITextField {

    override func awakeFromNib() {
        layer.cornerRadius = 0
        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.1).CGColor
        layer.borderWidth = 1.0
    }
    
    //Placeholder
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }
    
    //Editable Text
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, 10, 0)
    }


}
