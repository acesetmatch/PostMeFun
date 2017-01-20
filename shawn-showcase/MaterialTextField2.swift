//
//  MaterialTextField2.swift
//  shawn-showcase
//
//  Created by Shawn on 2/2/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit

class MaterialTextField2: UITextField {
    
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    override func awakeFromNib() {
        layer.cornerRadius = 0
        layer.borderColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.1).cgColor
        layer.borderWidth = 1.0
    }
    
    //Placeholder
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }
    
    //Editable Text
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: 10, dy: 0)
    }


}
