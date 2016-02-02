//
//  RoundView.swift
//  shawn-showcase
//
//  Created by Shawn on 1/27/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit

class RoundView: UIImageView {

    override func awakeFromNib() {
        layer.cornerRadius = frame.size.width / 2
        clipsToBounds = true
    }

}
