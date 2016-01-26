//
//  RegisterVC.swift
//  shawn-showcase
//
//  Created by Shawn on 1/19/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {
    
    
    @IBOutlet weak var emailTextField: MaterialTextField!
    @IBOutlet weak var passwordTextField: MaterialTextField!
    @IBOutlet weak var firstNameTextField: MaterialTextField!
    @IBOutlet weak var lastNameTextField: MaterialTextField!
    @IBOutlet weak var errorMessageLbl: UILabel!
    @IBOutlet weak var usernameLbl: MaterialTextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        self.navigationController?.navigationBarHidden = true;

        //        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }

    
    
    
    @IBAction func registerOnPressed(segue: UIStoryboardSegue) {
        if let username = usernameLbl.text where username != "", let email = emailTextField.text where email != "", let password = passwordTextField.text where password != "", let firstName = firstNameTextField.text where firstName != "", let lastName = lastNameTextField.text where lastName != ""{
            let existingEmail = DataService.ds.REF_USERS.childByAppendingPath("email")
            existingEmail.observeEventType(.Value, withBlock: { snapshot in
                let theEmail = (snapshot.value)
                    if email != theEmail as? String{
                    DataService.ds.REF_BASE.authUser(email, password: password, withCompletionBlock: { error, authData in
                    
                    if error != nil {
                        print(error)
                        
                        if error.code == INVALID_EMAIL {
                            self.errorMessageLbl.hidden = false
                            self.errorMessageLbl.text = "Invalid Email"
                        }
                        
                        
                        if error.code == STATUS_ACCOUNT_NONEXIST {
                            DataService.ds.REF_BASE.createUser(email, password: password, withValueCompletionBlock: { error, result in
                                if error != nil {
                                    self.showErrorAlert("Could not create account", msg: "Problem relating account. Try something else")
                                } else {
                                    NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                    
                                    DataService.ds.REF_BASE.authUser(email, password:password, withCompletionBlock: {err, authData in
                                        
                                        
                                        let user = ["provider": authData.provider!, "First Name":firstName, "Last Name": lastName, "email": email, "username": username] //swift dictionary
                                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                                    })
                                    
                                    self.performSegueWithIdentifier("returnToLogin", sender: nil)
                                    self.navigationController?.navigationBarHidden = true;
                                }
                                })
                        }
                    }
                })
                    } else {
                        self.errorMessageLbl.hidden = false
                        self.errorMessageLbl.text = "Email already exists"
                        
                }
    })
        }
    }
    
    
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title:title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func backButton(segue: UIStoryboardSegue) {
        self.performSegueWithIdentifier("returnToLogin", sender: nil)
        self.navigationController?.navigationBarHidden = true;
    }
    
    

    
    
    
    
}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


