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
        imagePickerUser = UIImagePickerController()
        imagePickerUser.delegate = self
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        addBtn.hidden = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name:UIKeyboardWillHideNotification, object: nil);
    }

    func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.textFieldToBottomLayoutGuideConstraint?.constant += keyboardSize.height
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            self.textFieldToBottomLayoutGuideConstraint?.constant -= keyboardSize.height
        }
    }
    
   

    



    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        self.navigationController?.navigationBarHidden = true;

        //        self.navigationItem.setHidesBackButton(true, animated: false)
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
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
                                        self.SaveProfileImage()

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
        } else {
            self.errorMessageLbl.hidden = false
            self.errorMessageLbl.text = "Please fill in all fields"
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
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func backButton(segue: UIStoryboardSegue) {
        self.performSegueWithIdentifier("returnToLogin", sender: nil)
        self.navigationController?.navigationBarHidden = true;
    }
    
    
    
    func UpdateUserImageToFirebase(profileimgUrl: String?) {
        
        //        let firebaseUser = DataService.ds.REF_USER_CURRENT //creates new database entry of autoiD
        //        firebaseUser.setValue(Username) //set post of new child autoid into firebase
        
        let firebaseProfile = DataService.ds.REF_USER_CURRENT//creates new database entry of autoid
        if profileimgUrl != nil {
            let ProfileimgUrl: Dictionary < String, AnyObject > = ["profileUrl":profileimgUrl!]
            firebaseProfile.updateChildValues(ProfileimgUrl) //set post of new child autoid into firebase
        }
    }
    
    func SaveProfileImage() {
        if let profileimage = ProfileImg.image where imageSelected == true {
            let urlStr = "https://post.imageshack.us/upload_api.php" //imageshack api website endpoint
            let url = NSURL(string:urlStr)!
            //Alamofire only takes in NSData
            let imgData = UIImageJPEGRepresentation(profileimage, 0.2)! //0.2 is really compressed converted to jpeg
            let keyData = API_Key.dataUsingEncoding(NSUTF8StringEncoding)! //converting string into data
            let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)! //converts json to data , unwraps to eliminate errors
            //uploads on alamofire in correct imageshack parameter format
            Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                
                multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg") //Passing in the key and value of image for imageshack parameters
                multipartFormData.appendBodyPart(data: keyData, name: "key") //name = key, data = keyData
                multipartFormData.appendBodyPart(data: keyJSON, name: "format")
                
                //when upload is done
                }) { encodingResult in
                    switch encodingResult {
                    case .Success(let upload, _, _): //.success is a closure, if it is success we want to upload response JSON from server
                        upload.responseJSON(completionHandler: { response in
                            if let info = response.result.value as? Dictionary<String, AnyObject> { //returns JSON format of primary dictionary and (string, anyobject)
                                if let links = info["links"] as? Dictionary<String, AnyObject> { //returns the secondary dictionary of links
                                    if let imgLink = links["image_link"] as? String {
                                        self.UpdateUserImageToFirebase(imgLink)
                                        
                                        
                                        
                                    }
                                }
                            }
                        })
                        
                    case .Failure(let error):
                        print(error)
                    }
            }
        } else {
            self.UpdateUserImageToFirebase(nil)
        }
        
        //        } else {
        //            self.displayAlertError("Cannot Post", Message: "Please add a Profile Image")
        //        }
    }

    @IBAction func returnToRegistration(segue: UIStoryboardSegue) {
        
    }
    

    @IBAction func BacktoProfilePressed(sender: AnyObject!) {
        self.performSegueWithIdentifier("BacktoProfile", sender: nil)
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


