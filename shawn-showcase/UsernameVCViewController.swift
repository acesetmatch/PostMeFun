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
import Firebase


class UsernameVCViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    
    @IBOutlet weak var ProfileImg: UIImageView!
    @IBOutlet weak var UserTextField: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var usernameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var firstNameTxtField: UITextField!
    @IBOutlet weak var lastNameTxtField: UITextField!
    @IBOutlet weak var backgroundImg: UIImageView!
    
    var imagePickerUser: UIImagePickerController!
    var imageSelected = false
    var user: User!
    var proImg: UIImage?
    var request: Request?
    var post: Post! //store post
//    var profRef:Firebase!
    var posts = [Post]()
    var registerVC: RegisterVC!




    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileImg.layer.cornerRadius = ProfileImg.frame.size.width/2
        ProfileImg.clipsToBounds = true
        
        imagePickerUser = UIImagePickerController()
        imagePickerUser.delegate = self
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = backgroundImg.bounds
        blurView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        backgroundImg.addSubview(blurView)
        
        addBtn.hidden = false
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        DataService.ds.REF_USER_CURRENT.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value) //Prints value of snapshot
//            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
            
                
                   if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                        let key = snapshot.key
                        let user = User(userKey: key, dictionary: userDict)
                        print(user.firstName)
                        print(user.lastName)
                        print(user.email)
                        print(user.username)
                        self.firstNameTxtField.text = user.firstName
                        self.lastNameTxtField.text = user.lastName
                        self.emailTxtField.text = user.email
                        self.usernameTxtField.text = user.username
                        if let proUrl = user.profileImageUrl {
                            self.proImg = FeedVC.imageCache.objectForKey(proUrl) as? UIImage //passing image from the cache if it exists. Returns value of the key(url). FeedVC is single instance
                            if user.profileImageUrl != nil {
                                if self.proImg != nil {
                                    self.ProfileImg.image = self.proImg
                                    self.backgroundImg.image = self.proImg
                                } else {
                                    self.request = Alamofire.request(.GET, user.profileImageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                                        
                                        if err == nil {
                                            if let ProfileImage = UIImage(data: data!) {
                                                self.ProfileImg.image = ProfileImage
                                                self.backgroundImg.image = ProfileImage
                                                //                            FeedVC.imageCache.setObject(ProfileImage, forKey: self.user.profileImageUrl!)
                                            }
                                        }
                                    })
                                }
                                
                            } else {
                                self.ProfileImg.hidden = false
                            }
                            
                    }


                    }
            
                
//            }
            
        })
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.navigationBarHidden = false
        
    }
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePickerUser.dismissViewControllerAnimated(true, completion: nil)
        ProfileImg.image = image
        backgroundImg.image = image
        imageSelected = true
        

    }
    
    @IBAction func addBtnPressed(sender: UIButton){
        presentViewController(imagePickerUser, animated: true, completion: nil)
//        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//        let registerVC = self.storyboard?.instantiateViewControllerWithIdentifier("RegisterVC") as? RegisterVC
//        self.navigationController?.pushViewController(registerVC!, animated: true) as? UIViewController

    }
    
    @IBAction func StartPosting(sender: AnyObject!) {
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
            
            self.performSegueWithIdentifier("usernameSet", sender: nil)

    }
    
        
    @IBAction func logOut(unwindSegue: UIStoryboardSegue){
        
        let alertmessage = UIAlertController(title: "Are you sure you want to log out?", message: "Pressing ok will log you out!", preferredStyle: .Alert)
        let okayAction = UIAlertAction(title: "Ok", style: .Default, handler: unAuthenticateUser)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alertmessage.addAction(okayAction)
        alertmessage.addAction(cancelAction)
        presentViewController(alertmessage, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func settingsOnPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("settingsSet", sender: nil)
    }
    
    

    
    func unAuthenticateUser(alert: UIAlertAction!) {
        DataService.ds.REF_USERS.unauth()
       
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.stringForKey("storedEmail") != "" && defaults.stringForKey("storedPassword") != "" {
            defaults.removeObjectForKey("storedEmail")
            defaults.removeObjectForKey("storedPassword")
        }
        self.performSegueWithIdentifier("loggingOutofUsername", sender: nil)
        self.navigationController?.navigationBarHidden = true;
    }
    

    
    func displayAlertError(Title: String, Message: String) {
        let alertmessage = UIAlertController(title: Title, message: Message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alertmessage.addAction(action)
        presentViewController(alertmessage, animated: true, completion: nil)
        
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
    
            
        
}

