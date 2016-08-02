//
//  RegisterVC.swift
//  shawn-showcase
//
//  Created by Shawn on 1/19/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class RegisterVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var emailTextField: MaterialTextField!
    @IBOutlet weak var passwordTextField: MaterialTextField!
    @IBOutlet weak var confirmPasswordTextField: MaterialTextField!
    @IBOutlet weak var firstNameTextField: MaterialTextField!
    @IBOutlet weak var lastNameTextField: MaterialTextField!
    @IBOutlet weak var errorMessageLbl: UILabel!
    @IBOutlet weak var usernameLbl: MaterialTextField!
    @IBOutlet weak var ProfileImg: UIImageView!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var textFieldToBottomLayoutGuideConstraint: NSLayoutConstraint!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var textStackView: UIStackView!
    
    
    //Constraints
    @IBOutlet weak var registerBtnLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var registerBtnRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var registerBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackHeight: NSLayoutConstraint!
    
    
    
    var imagePickerUser: UIImagePickerController!
    var imageSelected = false
    
    var stackViewHeightConstraint: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.stackViewHeightConstraint = NSLayoutConstraint(item: self.textStackView, attribute: .Height, relatedBy: .Equal, toItem: self.view, attribute: .Height, multiplier: 0.0, constant: stackViewYAdjust())
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!

        let animationDuration: Double = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        self.registerBtnLeftConstraint.constant = 40.0
        self.registerBtnRightConstraint.constant = 40.0
        self.registerBtnBottomConstraint.constant = 40.0
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.registerBtn.layer.cornerRadius = 4.0
            self.stackViewHeightConstraint.active = false
            self.view.layoutIfNeeded()
        })
    }

    func keyboardWillShow(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let endSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        let animationDuration: Double = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        self.registerBtnLeftConstraint.constant = -20
        self.registerBtnRightConstraint.constant = -20
        self.registerBtnBottomConstraint.constant = endSize.height-15.0
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.registerBtn.layer.cornerRadius = 0.0
            self.stackViewHeightConstraint.active = true
            self.view.layoutIfNeeded()
        })
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    @IBAction func registerOnPressed(segue: UIStoryboardSegue) {
        if let username = usernameLbl.text where username != "", let email = emailTextField.text where email != "", let password = passwordTextField.text where password != "", let confirmpassword = confirmPasswordTextField.text where confirmpassword != "", let firstName = firstNameTextField.text where firstName != "", let lastName = lastNameTextField.text where lastName != ""{
            if confirmpassword == password {
                let users = DataService.ds.REF_USERS
                users.queryOrderedByChild("email").queryEqualToValue(email).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if snapshot.exists() {
                        let emailExistsAlertController = UIAlertController(title: "Error", message: "Email is already taken. Please select another one", preferredStyle: .Alert)
                        let okay = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        self.presentViewController(emailExistsAlertController, animated: true, completion: nil)
                        emailExistsAlertController.addAction(okay)
                        
                    } else {
                        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
                            if error != nil {
                                let alert = Helper.showErrorAlert("Could not create account", msg: "Problem relating account. Try something else")
                                self.presentViewController(alert, animated: true, completion: nil)
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(user?.uid, forKey: KEY_UID)
                                let userData = ["provider": "email", "First Name":firstName, "Last Name": lastName, "email": email, "username": username] //swift dictionary
                                
                                let registerAlertController = UIAlertController(title: "Registration", message: "You have successfully registered!", preferredStyle: .Alert)
                                let okay = UIAlertAction(title: "OK", style: .Default, handler: self.okayPressed)
                                self.presentViewController(registerAlertController, animated: true, completion: nil)
                                registerAlertController.addAction(okay)
                                DataService.ds.createFirebaseUser(user!.uid, user: userData)
//                                self.performSegueWithIdentifier("returnToLogin", sender: nil)
                                self.navigationController?.popToRootViewControllerAnimated(true)
                            }
                        })
                        
                    }
                })
            } else {
                self.errorMessageLbl.hidden = false
                self.errorMessageLbl.text = "Passwords do not match"
            }
        } else {
            let fillfieldsAlertController = UIAlertController(title: "Error", message: "Please fill in all fields", preferredStyle: .Alert)
            let okay = UIAlertAction(title: "OK", style: .Default, handler: nil)
            self.presentViewController(fillfieldsAlertController, animated: true, completion: nil)
            fillfieldsAlertController.addAction(okay)
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePickerUser.dismissViewControllerAnimated(true, completion: nil)
        ProfileImg.image = image
        imageSelected = true
    }
    
    @IBAction func addBtnPressed(sender: AnyObject!){
        presentViewController(imagePickerUser, animated: true, completion: nil)
    }
    

    @IBAction func backButton(segue: UIStoryboardSegue) {
        self.performSegueWithIdentifier("returnToLogin", sender: nil)
        self.navigationController?.navigationBarHidden = true;
    }
    
    
    @IBAction func returnToRegistration(segue: UIStoryboardSegue) {
        
    }

    @IBAction func BacktoProfilePressed(sender: AnyObject!) {
        self.performSegueWithIdentifier("BacktoProfile", sender: nil)
    }
    
    
    //Screen Size Adjustment
    
    func screenHeight() -> CGFloat {
        return UIScreen.mainScreen().bounds.height
    }
    
    func stackViewYAdjust() -> CGFloat {
        switch(self.screenHeight()) {
        case 568:
            return 195
        case 667:
            return 270
        case 736:
            return 310
        default:
            return 270
        }
    }
    
    func okayPressed(alert:UIAlertAction!) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    
}





