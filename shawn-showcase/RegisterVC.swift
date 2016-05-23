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
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet var textFieldToBottomLayoutGuideConstraint: NSLayoutConstraint!
    var imagePickerUser: UIImagePickerController!
    var imageSelected = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let endSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        let animationDuration: Double = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.view.frame.origin.y = 0+endSize.height/4
        })
        
    }
    
    
    
    func keyboardWillShow(sender: NSNotification) {
        
        let userInfo: [NSObject : AnyObject] = sender.userInfo!
        let endSize: CGSize = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue.size
        let keyboardSize: CGSize = userInfo[UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size
        
        let animationDuration: Double = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.view.frame.origin.y = -endSize.height/5
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
                        DataService.ds.REF_BASE.createUser(email, password: password, withValueCompletionBlock: { error, result in
                            if error != nil {
                                self.showErrorAlert("Could not create account", msg: "Problem relating account. Try something else")
                            } else {
                                NSUserDefaults.standardUserDefaults().setValue(result[KEY_UID], forKey: KEY_UID)
                                
                                DataService.ds.REF_BASE.authUser(email, password:password, withCompletionBlock: {err, authData in
                                    
                                    let user = ["provider": authData.provider!, "First Name":firstName, "Last Name": lastName, "email": email, "username": username] //swift dictionary
                                    
                                    let registerAlertController = UIAlertController(title: "Registration", message: "You have successfully registered!", preferredStyle: .Alert)
                                    let okay = UIAlertAction(title: "OK", style: .Default, handler: nil)
                                    self.presentViewController(registerAlertController, animated: true, completion: nil)
                                    registerAlertController.addAction(okay)
                                    DataService.ds.createFirebaseUser(authData.uid, user: user)
                                    //                                        self.SaveProfileImage()
                                    
                                })
                                
                                self.performSegueWithIdentifier("returnToLogin", sender: nil)
                                self.navigationController?.navigationBarHidden = true;
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
            //            self.errorMessageLbl.hidden = false
            //            self.errorMessageLbl.text = "Please fill in all fields"
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
    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title:title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
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
    
    
}





