//
//  Helper.swift
//  shawn-showcase
//
//  Created by Shawn on 7/31/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import Foundation
import UIKit

open class Helper {
    public static func showErrorAlert(_ title: String, msg: String) -> UIAlertController {
        let alert = UIAlertController(title:title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        return alert
    }
    
    
}
