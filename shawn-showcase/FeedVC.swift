//
//  FeedVC.swift
//  shawn-showcase
//
//  Created by Shawn on 1/14/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import FirebaseStorage

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    var posts = [Post]()
    var users = [User]()
    var flagRef:FIRDatabaseReference!
    var blockRef: FIRDatabaseReference!
    var blacklistRef: FIRDatabaseReference!
    var postRef: FIRDatabaseReference!
    var imageSelected = false
    var post: Post!
    var user: User!
    var blacklistUser: User!
    var Uid: String!
    var imagePicker: UIImagePickerController!
    var postCellTableView: PostCellTableViewCell = PostCellTableViewCell()
    
    static var imageCache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 358
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imageSelectorImage.layer.cornerRadius = 2.0
        imageSelectorImage.clipsToBounds = true
        initObservers()
    }

    
    func initObservers() {
        DataService.ds.REF_USER_CURRENT.observe(.value, with: { snapshot in
            self.tableView.reloadData()
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                let user = User(userKey: key, dictionary: userDict)
                self.user = user
                self.users.append(user)
                DataService.ds.REF_POSTS.observe(.value, with: { snapshot in
                    if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                        self.posts = []
                        for snap in snapshots.reversed() {
                            if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let post = Post(postKey: key, dictionary: postDict)
                                self.postRef = DataService.ds.REF_POSTS.child(post.postKey)
                                self.blacklistRef = DataService.ds.REF_USER_CURRENT.child("blacklist")
                                self.posts.append(post)
                                for post in self.posts {
                                    self.blacklistRef.observeSingleEvent(of: .value, with: { snapshot in //check value only once
                                        if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                                            for snap in snapshots {
                                                if let blacklistDict = snap.value as? String {
                                                    let blacklistPost = post.Uid
                                                    if blacklistDict == blacklistPost {
                                                        self.posts = self.posts.filter({$0.Uid != blacklistDict})
                                                        self.tableView.reloadData()
                                                    } else {
                                                        self.tableView.reloadData()
                                                    }
                                                    
                                                }
                                            }
                                        }
                                    })
                                    
                                }
                            }
                            
                        }
                        self.tableView.reloadData()
                        
                    }
                    
                })
            }
        })
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.row]
        self.post = post
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCellTableViewCell", for: indexPath) as? PostCellTableViewCell {
            cell.request?.cancel()
            cell.returnButton.tag = indexPath.row
            cell.returnButton.addTarget(self, action: #selector(returnTapped), for: UIControlEvents.touchUpInside)
            var img: UIImage? //making an empty image
            var proImg: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.object(forKey: url as AnyObject) as? UIImage //passing iamge from the cache if it exists. Returns value of the key(url).
            }
            if let proUrl = post.profileImageUrl {
                proImg = FeedVC.imageCache.object(forKey: proUrl as AnyObject) as? UIImage //FeedVC is publicly available
            }
            cell.configureCell(post, img: img, ProfileImage: proImg)
            return cell
        } else {
            return PostCellTableViewCell()
        }
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150 //smaller values return smaller row height
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismiss(animated: true, completion: nil)
        imageSelectorImage.image = image
        imageSelected = true
    }

    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }
   
    //When post is made, image is compressed on the server
    @IBAction func makePost(_ sender: AnyObject) {
        createPost()
    }
    
    func returnTapped(_ sender:UIButton!) {
        self.post = self.posts[sender.tag]
        self.Uid = self.post.Uid
        let alertController = UIAlertController(title: "Inappropriate Content", message: "Select an option", preferredStyle: .actionSheet)
        let blockUser = UIAlertAction(title: "Block User", style: .default, handler:confirmingBlockUser)
        let Report = UIAlertAction(title: "Report Inappropriate", style: .default, handler: confirmingReport)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        alertController.addAction(blockUser)
        alertController.addAction(Report)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func confirmingReport(_ alert: UIAlertAction!) {
        let secondAlertController = UIAlertController(title: "Report Post", message: "Are you sure you want to report this post?", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Yes", style: .default, handler:reportConfirmed)
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        secondAlertController.addAction(confirm)
        secondAlertController.addAction(cancel)
        self.present(secondAlertController, animated: true, completion: nil)
    }
    
    func reportConfirmed(_ alert:UIAlertAction!) {
        let thirdAlertController = UIAlertController(title: "Post Report", message: "This post has been flagged as inappropriate", preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .cancel, handler: flagReference)
        thirdAlertController.addAction(okay)
        self.present(thirdAlertController, animated: true, completion: nil)
    }
    
    func flagReference(_ alert: UIAlertAction!) {
        flagRef = DataService.ds.REF_POSTS.child(post.postKey).child("flags").child(user.userKey!)
        flagRef.observeSingleEvent(of: .value, with: { snapshot in //check value only once
            if let doesNotExist = snapshot.value as? NSNull { //if there is no data in value, you need to check it agaisnt NSNULL. We have not liked this specific post.
                self.flagRef.setValue(true)
            } else {
                self.flagRef.removeValue()
            }
        })
    }
    
    
    func confirmingBlockUser(_ alert: UIAlertAction!) {
        let secondAlertController = UIAlertController(title: "Block User", message: "Are you sure you want to block this user?", preferredStyle: .alert)
        let confirm = UIAlertAction(title: "Yes", style: .default, handler:blockUserConfirmed)
        let cancel = UIAlertAction(title: "No", style: .cancel, handler: nil)
        secondAlertController.addAction(confirm)
        secondAlertController.addAction(cancel)
        self.present(secondAlertController, animated: true, completion: nil)
    }
    
    func blockUserConfirmed(_ alert:UIAlertAction!) {
        let thirdAlertController = UIAlertController(title: "User Blocked", message: "You have blocked this user", preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .cancel, handler: blockReference)
            
        thirdAlertController.addAction(okay)
        self.present(thirdAlertController, animated: true, completion: nil)
    }

    
    func createPost() {
        guard let text = postField.text, text != "" else {
            let alert = Helper.showErrorAlert("Description Required", msg: "You must enter a description")
            present(alert, animated: true, completion: nil)
            return
        }
        
        guard let img = imageSelectorImage.image, imageSelected == true else {
            let alert = Helper.showErrorAlert("Image Required", msg: "You must select an image")
            present(alert, animated: true, completion: nil)
            return
        }
        
        //Uploading image to Firebase Storage
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metaData) { (metadata, error) in
                if error != nil {
                    print("Unable to load image to Firebase Storage")
                } else {
                    print("Successfully uploaded")
                    let downloadURL = metaData.downloadURL()?.absoluteString
                    self.postToFirebase(downloadURL)
                }
            }
        }
        
        
        
        
        
//        
//            if let txt = postField.text, txt != ""{
//                if let img = imageSelectorImage.image, imageSelected == true {
//                    let urlStr = "https://post.imageshack.us/upload_api.php" //imageshack api website endpoint
//                    let url = URL(string:urlStr)!
//                    //Alamofire only takes in NSData
//                    let imgData = UIImageJPEGRepresentation(img, 0.2)! //0.2 is really compressed converted to jpeg
//                    let keyData = API_Key.data(using: String.Encoding.utf8)! //converting string into data
//                    let keyJSON = "json".data(using: String.Encoding.utf8)! //converts json to data , unwraps to eliminate errors
//                    var imageLink = ""
//                    //uploads on alamofire in correct imageshack parameter format
//                    Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in //what special data to include in http post data.
//                        
//                        multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg") //Passing in the key and value of image for imageshack parameters
//                        multipartFormData.appendBodyPart(data: keyData, name: "key") //name = key, data = keyData
//                        multipartFormData.appendBodyPart(data: keyJSON, name: "format")
//                        
//                        //when upload is done
//                    }) { encodingResult in
//                        switch encodingResult {
//                        case .Success(let upload, _, _): //.success is a closure, if it is success we want response JSON from server
//                            upload.responseJSON(completionHandler: { response in
//                                if let info = response.result.value as? Dictionary<String, AnyObject> { //returns JSON format of primary dictionary and (string, anyobject)
//                                    if let links = info["links"] as? Dictionary<String, AnyObject> { //returns the secondary dictionary of links
//                                        if let imgLink = links["image_link"] as? String { //grabs the key image_link and gets the values as string
//                                            imageLink = imgLink
//                                            self.postToFirebase(imageLink)
//                                        }
//                                    }
//                                }
//                            })
//                            
//                        case .Failure(let error):
//                            print(error)
//                        }
//                    }
//                } else {
//                    let alert = Helper.showErrorAlert("Image Required", msg: "You must select an image")
//                    present(alert, animated: true, completion: nil)
//                }
//            } else {
//                let alert = Helper.showErrorAlert("Description Required", msg: "You must enter a description")
//                present(alert, animated: true, completion: nil)
//            }
        
    }
    
    func blockReference(_ alert: UIAlertAction!) {
        blockRef = DataService.ds.REF_USER_CURRENT.child("blacklist")
        let blacklistUid: Dictionary <String,String> = ["1": self.Uid]
        self.blockRef.updateChildValues(blacklistUid)
    }

    // Put Post dictionary to firebase database. 
    func postToFirebase(_ imgUrl: String?) {
        let theUid = UserDefaults.standard.value(forKey: KEY_UID) as! String
        let Uid = DataService.ds.REF_USER_CURRENT
        Uid.observeSingleEvent(of: .value, with: { (snapshot) in
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                let user = User(userKey: key, dictionary: userDict)
                let userProfileImg = user.profileImageUrl
                let userUsername = user.username
                var post: Dictionary < String, AnyObject >= ["Uid":theUid as AnyObject, "username": userUsername as AnyObject,
                    "description" : self.postField.text! as AnyObject,
                    "likes": 0 as AnyObject]
                if imgUrl != nil {
                    post["imageUrl"] = imgUrl! as AnyObject?
                }
                
                if userProfileImg != nil {
                    post["profileUrl"] = userProfileImg! as AnyObject?
                }
            
                let firebasePost = DataService.ds.REF_POSTS.childByAutoId() //creates new database entry of autoid
                firebasePost.setValue(post)//set post of new child autoid into firebase
                self.postField.text = ""
                self.imageSelectorImage.image = UIImage(named: "camera 2")
                self.imageSelected = false
                self.tableView.reloadData()
                
                let postAlertController = UIAlertController(title: "Post", message: "You just made a post!", preferredStyle: .alert)
                let okay = UIAlertAction(title: "OK", style: .default) { (UIAlertAction) in
                    
                }
                self.present(postAlertController, animated: true, completion: nil)
                postAlertController.addAction(okay)
            }
        })
//
//        }) {(error) in
//                print(error.localizedDescription)
//        
        
        
    }


}
