//
//  RoundView.swift
//  shawn-showcase
//
//  Created by Shawn on 1/27/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit

@IBDesignable
class RoundView: UIImageView {

    var width: CGFloat!
    
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
           self.layer.cornerRadius = self.width
        }
        
    }
    
    override func awakeFromNib() {
       self.width = frame.size.width / 2
       self.layer.cornerRadius = self.width
       clipsToBounds = true
    }

}
