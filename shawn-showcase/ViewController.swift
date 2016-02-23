//
//  ViewController.swift
//  shawn-showcase
//
//  Created by Shawn on 1/13/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit


class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: MaterialTextField!
    @IBOutlet weak var passwordField: MaterialTextField!
    @IBOutlet weak var errorLbl: UILabel!

    
    var usernameVC: UsernameVCViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.navigationBarHidden = true;
      
    }

  
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = true;
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let animationDuration: Double = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.view.frame.origin.y = 0
        })

    }
    

    
    func keyboardWillShow(sender: NSNotification) {
        
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let endSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        let animationDuration: Double = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.view.frame.origin.y = -endSize.height/2
        })

    }
    

    

    @IBAction func attemptLogin(sender:UIButton!) {
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error, authData in
                    if (error != nil) {
                        print(error.code)
                        
                          if error.code == STATUS_ACCOUNT_NONEXIST {
                            self.errorLbl.hidden = false
                            self.errorLbl.text = "User does not exist"
                          }

                          if error.code == INVALID_EMAIL {
                             self.errorLbl.hidden = false
                            self.errorLbl.text = "Invalid Email"
                          }
                          if error.code == INCORRECT_PASSWORD {
                            self.errorLbl.hidden = false
                            self.errorLbl.text = "Incorrect Password"
                          }
                        
                    } else {
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let usernameVCViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UsernameVCViewController") as? UsernameVCViewController

                        self.navigationController?.pushViewController(usernameVCViewController!, animated: true) as? UIViewController
                        
                        


                    }
                })
                
        
            
        } else {
            showErrorAlert("Email and Password Required", msg: "You must enter an email and a password")
        }
        

    }
    
    @IBAction func signUpOnPressed(sender:UIButton!) {
        self.performSegueWithIdentifier("signUp", sender: nil)
        self.navigationController?.navigationBarHidden = false;

    }
    
    @IBAction func returnToLogin(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func loggingOutofUsername(segue: UIStoryboardSegue) {
       
    }
    
    
    
    func showErrorAlert(title: String, msg: String) {
            let alert = UIAlertController(title:title, message: msg, preferredStyle: .Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            presentViewController(alert, animated: true, completion: nil)
    }
    
    
}



