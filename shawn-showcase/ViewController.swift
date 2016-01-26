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

var userGlobal = User()
class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLbl: UILabel!
    
    var usernameVC: UsernameVCViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.navigationBarHidden = true;
        
//        DataService.ds.REF_BASE.observeAuthEventWithBlock({ authData in
//            if authData.uid != nil {
//                let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                let usernameVCViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UsernameVCViewController") as? UsernameVCViewController
//                
//                self.navigationController?.pushViewController(usernameVCViewController!, animated: true) as? UIViewController
//            }
//        })
    
//        })
//        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
//            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                            let usernameVCViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UsernameVCViewController") as? UsernameVCViewController
//            
//                            self.navigationController?.pushViewController(usernameVCViewController!, animated: true) as? UIViewController
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBarHidden = true;
        
//        self.navigationItem.setHidesBackButton(true, animated: false)
//        let value = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID)
        
    }
    
    @IBAction func fbBtnPressed(sender: UIButton!) {
        let facebookLogin = FBSDKLoginManager()
    
        
        facebookLogin.logInWithReadPermissions(["email"]) { (facebookResult: FBSDKLoginManagerLoginResult!, facebookError: NSError!) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                print("Successfully logged in with Facebook. \(accessToken)")
                
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
//                    userGlobal.uid = authData.uid
//                    userGlobal.isFacebook = true
                    if error != nil {
                        print("Login Failed")
                    } else {
                        print("Logged In \(authData)")
                       
                        
                        let user = ["provider": authData.provider!] //swift dictionary
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        if authData.uid != "" {
                            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                            let usernameVCViewController = self.storyboard?.instantiateViewControllerWithIdentifier("UsernameVCViewController") as? UsernameVCViewController
                            
                            self.navigationController?.pushViewController(usernameVCViewController!, animated: true) as? UIViewController
                            self.navigationController?.navigationBarHidden = false;

                        }
                        
                        else {
                            print("Please login")
                        }

                    }
                })
        }
        
    }
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
                        
//                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                        self.navigationController?.navigationBarHidden = false;
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



