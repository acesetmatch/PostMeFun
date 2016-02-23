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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
    var posts = [Post]()
    var imageSelected = false
    var post: Post!
    
    var user: User!
    var imagePicker: UIImagePickerController!
//    var flagRef: Firebase!
    var postCellTableView: PostCellTableViewCell!
    
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 358
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imageSelectorImage.layer.cornerRadius = 2.0
        imageSelectorImage.clipsToBounds = true
        
     
        DataService.ds.REF_USER_CURRENT.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value) //Prints value of snapshot
            //            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
            
            
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                let user = User(userKey: key, dictionary: userDict)
                let blacklistuser = user.blacklist
                DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
                    print(snapshot.value) //Prints value of snapshot
                    if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                        self.posts = []
                        
                        for snap in snapshots {
                            print("SNAP: \(snap)")
                            
                            if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                let key = snap.key
                                let post = Post(postKey: key, dictionary: postDict)
//                                if post.Uid = user.blacklist
                                self.posts.append(post)
                            }
                        }
                        
                    }
                    self.tableView.reloadData()
                    
                })
            }
        })

    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = self.posts[indexPath.row]

        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCellTableViewCell", forIndexPath: indexPath) as? PostCellTableViewCell {
            cell.request?.cancel()
            cell.returnButton.tag = indexPath.row
            cell.returnButton.addTarget(self, action: "returnTapped:", forControlEvents: UIControlEvents.TouchUpInside)
            
            var img: UIImage? //making an empty image
            var proImg: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage //passing iamge from the cache if it exists. Returns value of the key(url).
            }
            if let proUrl = post.profileImageUrl {
                proImg = FeedVC.imageCache.objectForKey(proUrl) as? UIImage //FeedVC is publicly available
            }
            cell.configureCell(post, img: img, ProfileImage: proImg)
            return cell
        } else {
            return PostCellTableViewCell()
        }
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        
        if post.imageUrl == nil {
            return 150 //smaller values return smaller row height
        } else {
            return tableView.estimatedRowHeight
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        imageSelectorImage.image = image
        imageSelected = true
    }

    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
   
    //When post is made, image is compressed on the server
    @IBAction func makePost(sender: AnyObject) {
        if let txt = postField.text where txt != ""{
            if let img = imageSelectorImage.image where imageSelected == true {
                let urlStr = "https://post.imageshack.us/upload_api.php" //imageshack api website endpoint
                let url = NSURL(string:urlStr)!
                //Alamofire only takes in NSData
                let imgData = UIImageJPEGRepresentation(img, 0.2)! //0.2 is really compressed converted to jpeg
                let keyData = API_Key.dataUsingEncoding(NSUTF8StringEncoding)! //converting string into data
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)! //converts json to data , unwraps to eliminate errors
                var imageLink = ""
                //uploads on alamofire in correct imageshack parameter format
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in //what special data to include in http post data.
                    
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
                                        if let imgLink = links["image_link"] as? String { //grabs the key image_link and gets the values as string
                                            imageLink = imgLink
                                            self.postToFirebase(imageLink)
                                        
                                            
                                        
                                        }
                                    }
                                }
                            })
                            
                        case .Failure(let error):
                            print(error)
                        }
            }
            } else {
                showErrorAlert("Image Required", msg: "You must select an image")
            }
        } else {
            showErrorAlert("Description Required", msg: "You must enter a description")
        }
    }
    
    func returnTapped(sender:UIButton!) {
        let alertController = UIAlertController(title: "Inappropriate Content", message: "Select an option", preferredStyle: .Alert)
        let blockUser = UIAlertAction(title: "Block User", style: .Default, handler:nil)
        let Report = UIAlertAction(title: "Report Inappropriate", style: .Default, handler: postCellTableView.flagReference)
        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler:nil)
        alertController.addAction(blockUser)
        alertController.addAction(Report)
        alertController.addAction(cancel)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
   
    

    
    func showErrorAlert(title: String, msg: String) {
        let alert = UIAlertController(title:title, message: msg, preferredStyle: .Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }

    func postToFirebase(imgUrl: String?) {
        let theUid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let Uid = DataService.ds.REF_USER_CURRENT
        Uid.observeSingleEventOfType(.Value, withBlock: { snapshot in
                let UIDdict = (snapshot.value)
                var post: Dictionary < String, AnyObject >= ["Uid":theUid, "UidDict": UIDdict,
                    "description" : self.postField.text!,
                    "likes": 0, "flags": 0]
                if imgUrl != nil {
                    post["imageUrl"] = imgUrl!
                }
                
                let firebasePost = DataService.ds.REF_POSTS.childByAutoId() //creates new database entry of autoid
                firebasePost.setValue(post)//set post of new child autoid into firebase
                self.postField.text = ""
                self.imageSelectorImage.image = UIImage(named: "camera 2")
                self.imageSelected = false
                self.tableView.reloadData()

                }, withCancelBlock: {error in
                    print(error.description)
            })
     
        
    }


}