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
import Firebase
import Alamofire
import FirebaseStorage
import NVActivityIndicatorView
class UsernameVCViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NVActivityIndicatorViewable {

    
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
    var posts = [Post]()
    var registerVC: RegisterVC!


    override func viewDidLoad() {
        super.viewDidLoad()
        ProfileImg.layer.cornerRadius = ProfileImg.frame.size.width/2
        ProfileImg.clipsToBounds = true
        
        imagePickerUser = UIImagePickerController()
        imagePickerUser.delegate = self
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = backgroundImg.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImg.addSubview(blurView)
        
        addBtn.isHidden = false
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        imagePickerUser.navigationBar.barTintColor = UIColor(red: 70/255.0, green: 90/255, blue: 255/255.0, alpha: 1.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
        self.navigationController?.isNavigationBarHidden = false
        initObservers()

    }
    
    
    // Fetch from Firebase Database and init the user text fields. The images will be fetched from Firebase Storage and cached.
    func initObservers() {
        startAnimating()
        DataService.ds.REF_USER_CURRENT.observe(.value, with: { snapshot in
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                let user = User(userKey: key, dictionary: userDict)
                self.firstNameTxtField.text = user.firstName
                self.lastNameTxtField.text = user.lastName
                self.emailTxtField.text = user.email
                self.usernameTxtField.text = user.username
                if let proUrl = user.profileImageUrl {
                    self.proImg = FeedVC.imageCache.object(forKey: proUrl as AnyObject) as? UIImage //passing image from the cache if it exists. Returns value of the key(url). FeedVC is single instance
                    //if user.profileImageUrl != nil {
                        if self.proImg != nil {
                            self.ProfileImg.image = self.proImg
                            self.backgroundImg.image = self.proImg
                            self.stopAnimating()
                        } else {
                            //if let imageURL = self.user.profileImageUrl {
                                let ref = FIRStorage.storage().reference(forURL: proUrl)
                                ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                                    if error != nil {
                                        print("unable to download image from Firebase Storage")
                                    } else {
                                        print("image downloaded")
                                        if let imgData = data {
                                            if let img = UIImage(data: imgData) {
                                                self.ProfileImg.image = img
                                                self.backgroundImg.image = img
                                                FeedVC.imageCache.setObject(img, forKey: proUrl as AnyObject)
                                                self.stopAnimating()
                                            }
                                        }
                                    }
                                })
                        }
                    
                }
                
            }
        })

    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePickerUser.dismiss(animated: true, completion: nil)
        ProfileImg.image = image
        backgroundImg.image = image
        imageSelected = true
    }
    
    @IBAction func addBtnPressed(_ sender: UIButton){
        present(imagePickerUser, animated: true, completion: nil)

    }
    
    @IBAction func StartPosting(_ sender: AnyObject!) {
        guard let img = ProfileImg.image else {
            let alert = Helper.showErrorAlert("Image Required", msg: "You must select an image")
            present(alert, animated: true, completion: nil)
            return
        }
        
        //Uploading image to Firebase Storage
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            DataService.ds.REF_PROFILE_IMAGES.child(imgUid).put(imgData, metadata: metaData) { (metdata, error) in
                if error != nil {
                    print("Unable to load image to Firebase Storage")
                } else {
                    print("Successfully uploaded")
                    let downloadURL = metdata?.downloadURL()?.absoluteString
                    if downloadURL != nil {
                        self.UpdateUserImageToFirebase(downloadURL)
                    }
                }
            }
        }
                   self.performSegue(withIdentifier: "usernameSet", sender: nil)

    }
    
    
    @IBAction func logOut(_ unwindSegue: UIStoryboardSegue){
    
        let alertmessage = UIAlertController(title: "Are you sure you want to log out?", message: "Pressing ok will log you out!", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "OK", style: .default, handler: unAuthenticateUser)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        alertmessage.addAction(okayAction)
        alertmessage.addAction(cancelAction)
        present(alertmessage, animated: true, completion: nil)
        
    }
    
    
    
    @IBAction func settingsOnPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "settingsSet", sender: nil)
    }
    
    

    
    func unAuthenticateUser(_ alert: UIAlertAction!) {
        try! FIRAuth.auth()?.signOut()
       
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "storedEmail") != "" && defaults.string(forKey: "storedPassword") != "" {
            defaults.removeObject(forKey: "storedEmail")
            defaults.removeObject(forKey: "storedPassword")
        }
        self.performSegue(withIdentifier: "loggingOutofUsername", sender: nil)
        self.navigationController?.isNavigationBarHidden = true;
    }
    

    
    func displayAlertError(_ Title: String, Message: String) {
        let alertmessage = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertmessage.addAction(action)
        present(alertmessage, animated: true, completion: nil)
        
    }
    

    func UpdateUserImageToFirebase(_ profileimgUrl: String?) {
        let firebaseProfile = DataService.ds.REF_USER_CURRENT//creates new database entry of autoid
        if profileimgUrl != nil {
            let ProfileimgUrl: Dictionary < String, AnyObject > = ["profileUrl":profileimgUrl! as AnyObject]
            firebaseProfile.updateChildValues(ProfileimgUrl) //set post of new child autoid into firebase
        }
    }
    
            
        
}

