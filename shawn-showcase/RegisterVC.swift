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
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        self.stackViewHeightConstraint = NSLayoutConstraint(item: self.textStackView, attribute: .height, relatedBy: .equal, toItem: self.view, attribute: .height, multiplier: 0.0, constant: stackViewYAdjust())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    
    func keyboardWillHide(_ sender: Notification) {
        let userInfo: [AnyHashable: Any] = sender.userInfo!

        let animationDuration: Double = (userInfo[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        self.registerBtnLeftConstraint.constant = 40.0
        self.registerBtnRightConstraint.constant = 40.0
        self.registerBtnBottomConstraint.constant = 40.0
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.registerBtn.layer.cornerRadius = 4.0
            self.stackViewHeightConstraint.isActive = false
            self.view.layoutIfNeeded()
        })
    }

    func keyboardWillShow(_ sender: Notification) {
        let userInfo: [AnyHashable: Any] = sender.userInfo!
        let endSize: CGSize = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue.size
        let animationDuration: Double = (userInfo[UIKeyboardAnimationDurationUserInfoKey]! as AnyObject).doubleValue
        self.registerBtnLeftConstraint.constant = -20
        self.registerBtnRightConstraint.constant = -20
        self.registerBtnBottomConstraint.constant = endSize.height-15.0
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.registerBtn.layer.cornerRadius = 0.0
            self.stackViewHeightConstraint.isActive = true
            self.view.layoutIfNeeded()
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func registerOnPressed(_ segue: UIStoryboardSegue) {
        if let username = usernameLbl.text, username != "", let email = emailTextField.text, email != "", let password = passwordTextField.text, password != "", let confirmpassword = confirmPasswordTextField.text, confirmpassword != "", let firstName = firstNameTextField.text, firstName != "", let lastName = lastNameTextField.text, lastName != ""{
            if confirmpassword == password {
                let users = DataService.ds.REF_USERS
                users.queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value, with: { snapshot in
                    if snapshot.exists() {
                        let emailExistsAlertController = UIAlertController(title: "Error", message: "Email is already taken. Please select another one", preferredStyle: .alert)
                        let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
                        self.present(emailExistsAlertController, animated: true, completion: nil)
                        emailExistsAlertController.addAction(okay)
                        
                    } else {
                        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil {
                                let alert = Helper.showErrorAlert("Could not create account", msg: "Problem relating account. Try something else")
                                self.present(alert, animated: true, completion: nil)
                            } else {
                                UserDefaults.standard.setValue(user?.uid, forKey: KEY_UID)
                                let userData = ["provider": "email", "First Name":firstName, "Last Name": lastName, "email": email, "username": username] //swift dictionary
                                
                                let registerAlertController = UIAlertController(title: "Registration", message: "You have successfully registered!", preferredStyle: .alert)
                                let okay = UIAlertAction(title: "OK", style: .default, handler: self.okayPressed)
                                self.present(registerAlertController, animated: true, completion: nil)
                                registerAlertController.addAction(okay)
                                DataService.ds.createFirebaseUser(user!.uid, user: userData)
//                                self.performSegueWithIdentifier("returnToLogin", sender: nil)
                                _ = self.navigationController?.popToRootViewController(animated: true)
                            }
                        })
                        
                    }
                })
            } else {
                self.errorMessageLbl.isHidden = false
                self.errorMessageLbl.text = "Passwords do not match"
            }
        } else {
            let fillfieldsAlertController = UIAlertController(title: "Error", message: "Please fill in all fields", preferredStyle: .alert)
            let okay = UIAlertAction(title: "OK", style: .default, handler: nil)
            self.present(fillfieldsAlertController, animated: true, completion: nil)
            fillfieldsAlertController.addAction(okay)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePickerUser.dismiss(animated: true, completion: nil)
        ProfileImg.image = image
        imageSelected = true
    }
    
    @IBAction func addBtnPressed(_ sender: AnyObject!){
        present(imagePickerUser, animated: true, completion: nil)
    }
    

    @IBAction func backButton(_ segue: UIStoryboardSegue) {
        self.performSegue(withIdentifier: "returnToLogin", sender: nil)
        self.navigationController?.isNavigationBarHidden = true;
    }
    
    
    @IBAction func returnToRegistration(_ segue: UIStoryboardSegue) {
        
    }

    @IBAction func BacktoProfilePressed(_ sender: AnyObject!) {
        self.performSegue(withIdentifier: "BacktoProfile", sender: nil)
    }
    
    
    //Screen Size Adjustment
    
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height
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
    
    func okayPressed(_ alert:UIAlertAction!) {
        _ = self.navigationController?.popToRootViewController(animated: true)
    }

    
}





