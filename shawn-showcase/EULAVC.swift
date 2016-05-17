//
//  EULAVC.swift
//  shawn-showcase
//
//  Created by Shawn on 4/26/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit

class EULAVC: UIViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func agreePressed(sender: AnyObject?) {
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "TermsAccepted")
        self.performSegueWithIdentifier("returnToLogin", sender: self)

    }
    
    @IBAction func disagreePressed(sender:AnyObject?) {
        showErrorAlert("License Agreement", msg: "You agree to the terms and conditions to continue")
    }
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title:title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    


}
