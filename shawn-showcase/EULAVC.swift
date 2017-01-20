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
    
    
    @IBAction func agreePressed(_ sender: AnyObject?) {
        UserDefaults.standard.set(true, forKey: "TermsAccepted")
        self.performSegue(withIdentifier: "returnToLogin", sender: self)

    }
    
    @IBAction func disagreePressed(_ sender:AnyObject?) {
        let alert = Helper.showErrorAlert("License Agreement", msg: "You must agree to the terms and conditions to continue")
        present(alert, animated: true, completion: nil)

    }

}
