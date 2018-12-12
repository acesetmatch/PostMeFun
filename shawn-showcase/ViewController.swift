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
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var emailField: MaterialTextField!
    @IBOutlet weak var passwordField: MaterialTextField!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var signUpBtn: UIButton!
    
    var usernameVC: UsernameVCViewController!
    let borderAlpha: CGFloat = 1.0
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationController?.isNavigationBarHidden = true;
        signUpBtn.layer.borderWidth = 1.0
        signUpBtn.layer.borderColor = UIColor(red: 70.0/255.0, green: 90.0/255.0, blue: 255.0, alpha: borderAlpha).cgColor
        if !UserDefaults.standard.bool(forKey: "TermsAccepted") {
            self.performSegue(withIdentifier: "returnToTerms", sender: nil)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.isNavigationBarHidden = true;
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        self.errorLbl.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        emailField.text = ""
        passwordField.text = ""

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillHide(_ sender: Notification) {
        let userInfo: [AnyHashable: Any] = sender.userInfo!
        let animationDuration: Double = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.view.frame.origin.y = 0
        })

    }
    
    @objc func keyboardWillShow(_ sender: Notification) {
        
        let userInfo: [AnyHashable: Any] = sender.userInfo!
        let endSize: CGSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
        let animationDuration: Double = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.view.frame.origin.y = -endSize.height/2
        })
    }
    

    @IBAction func attemptLogin(_ sender:UIButton!) {
        if let email = emailField.text, email != "", let pwd = passwordField.text, pwd != "" {
            Auth.auth().signIn(withEmail: email, password: pwd, completion: { (user,error) in
                    if (error != nil) {
                        print(error)
                        
                          if error!._code == STATUS_ACCOUNT_NONEXIST {
                            self.errorLbl.isHidden = false
                            self.errorLbl.text = "User does not exist"
                          }

                          if error!._code == INVALID_EMAIL {
                             self.errorLbl.isHidden = false
                            self.errorLbl.text = "Invalid Email"
                          }
                          if error!._code == INCORRECT_PASSWORD {
                            self.errorLbl.isHidden = false
                            self.errorLbl.text = "Incorrect Password"
                          }
                        
                    } else {
                        UserDefaults.standard.setValue(user?.user.uid, forKey: KEY_UID)
                        let storedEmail = self.emailField.text
                        let storedPassword = self.passwordField.text
                        UserDefaults.standard.setValue(storedEmail, forKey: "storedEmail")
                        UserDefaults.standard.setValue(storedPassword, forKey: "storedPassword")
                        self.pushToProfile()

                    }
                })
        } else {
            let alert = Helper.showErrorAlert("Email and Password Required", msg: "You must enter an email and a password")
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func signUpOnPressed(_ sender:UIButton!) {
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = convertToOptionalNSAttributedStringKeyDictionary([NSAttributedString.Key.foregroundColor.rawValue:UIColor.white])
        self.performSegue(withIdentifier: "signUp", sender: nil)
        self.navigationController?.isNavigationBarHidden = false;

    }
    
    // Unwind Segues
    @IBAction func returnToLogin(_ segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func loggingOutofUsername(_ segue: UIStoryboardSegue) {
       
    }
    
    @IBAction func returnToRootView(_ segue: UIStoryboardSegue) {
        
    }
    
    func pushToProfile() {
        let usernameVCViewController = self.storyboard?.instantiateViewController(withIdentifier: "UsernameVCViewController") as? UsernameVCViewController
        self.navigationController?.pushViewController(usernameVCViewController!, animated: true)
    }
    
    
}




// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}
