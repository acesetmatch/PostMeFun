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
        let alert = Helper.showErrorAlert("License Agreement", msg: "You must agree to the terms and conditions to continue")
        presentViewController(alert, animated: true, completion: nil)

    }

}
