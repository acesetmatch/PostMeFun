//
//  UsernameVCViewController.swift
//  shawn-showcase
//
//  Created by Shawn on 1/15/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire
class UsernameVCViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var ProfileImg: UIImageView!
    @IBOutlet weak var UserTextField: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    var imagePickerUser: UIImagePickerController!
    var imageSelected = false
    var postType: Post!
    var userGlobal: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerUser = UIImagePickerController()
        imagePickerUser.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePickerUser.dismissViewControllerAnimated(true, completion: nil)
        ProfileImg.image = image
        addBtn.hidden = true
        
    }
    
    @IBAction func addBtnPressed(sender: AnyObject!){
        presentViewController(imagePickerUser, animated: true, completion: nil)
        imageSelected = true
    }
    
    @IBAction func StartPosting(sender: AnyObject!) {
        if let username = UserTextField.text where username != "" {
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
                                case .Success(let upload, _, _): //.success is a closure, if it is success we want response JSON from server
                                    upload.responseJSON(completionHandler: { response in
                                        if let info = response.result.value as? Dictionary<String, AnyObject> { //returns JSON format of primary dictionary and (string, anyobject)
                                            if let links = info["links"] as? Dictionary<String, AnyObject> { //returns the secondary dictionary of links
                                                if let imgLink = links["image_link"] as? String {
                                                    self.UpdateUserImageToFirebase(imgLink, Username: username)
                                                    
                                                    
                                                    
                                                }
                                            }
                                        }
                                    })
                                    
                                case .Failure(let error):
                                    print(error)
                                }
                        }
                    } else {
                        self.UpdateUserImageToFirebase(nil, Username:username)
                    }
            
            
            
            self.performSegueWithIdentifier("usernameSet", sender: nil)
        

        } else {
            self.displayAlertError("Cannot Post", Message: "Please enter a username and add an image")
        }
    }
    
    @IBAction func logOut(sender: AnyObject?){
        
       self.displayAlertError("Logging Out", Message: "Are you sure you want to log out?")
       self.navigationController!.popViewControllerAnimated(true)
       DataService.ds.REF_USER_CURRENT.unauth()
       
    }
    
    
    
    func displayAlertError(Title: String, Message: String) {
        let alertmessage = UIAlertController(title: Title, message: Message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertmessage.addAction(action)
        presentViewController(alertmessage, animated: true, completion: nil)
        
    }

    func UpdateUserImageToFirebase(profileimgUrl: String?, Username: String) {
        
        let firebaseUser = DataService.ds.REF_USER_CURRENT //creates new database entry of autoiD
        firebaseUser.setValue(Username) //set post of new child autoid into firebase
        
        let firebaseProfile = DataService.ds.REF_USER_CURRENT//creates new database entry of autoid
        let ProfileimgUrl: Dictionary < String, AnyObject > = ["Username": Username, "ProfileUrl":profileimgUrl!]
        
        firebaseProfile.setValue(ProfileimgUrl) //set post of new child autoid into firebase
        
    }

}