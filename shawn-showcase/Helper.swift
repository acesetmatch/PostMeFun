//
//  Helper.swift
//  shawn-showcase
//
//  Created by Shawn on 7/31/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import Foundation
import UIKit

public class Helper {
    public static func showErrorAlert(title: String, msg: String) -> UIAlertController {
        let alert = UIAlertController(title:title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        return alert
    }
    
    
}