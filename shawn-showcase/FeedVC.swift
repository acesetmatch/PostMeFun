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

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImage: UIImageView!
   
    var posts = [Post]()
    var imageSelected = false
    var posted: Post!
    var userGlobal: User!
    var imagePicker: UIImagePickerController!
    static var imageCache = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 363
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value) //Prints value of snapshot
            self.posts = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dictionary: postDict)
                        self.posts.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
        })

        // Do any additional setup after loading the view.
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCellTableViewCell") as? PostCellTableViewCell {
            cell.request?.cancel()
            
            let post = self.posts[indexPath.row]
            var img: UIImage? //making an empty image
            var proImg: UIImage?
            
            if let url = post.imageUrl {
                img = FeedVC.imageCache.objectForKey(url) as? UIImage //passing iamge from the cache if it exists. Returns value of the key(url).
            }
            if let proUrl = post.profileImageUrl {
                proImg = FeedVC.imageCache.objectForKey(proUrl) as? UIImage //passing iamge from the cache if it exists. Returns value of the key(url). FeedVC is single instance
            }
            let username = post.username
            cell.configureCell(post, img: img, ProfileImage: proImg, username:username )
            
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
        if let txt = postField.text where txt != "" {
            if let img = imageSelectorImage.image where imageSelected == true{
               
                let urlStr = "https://post.imageshack.us/upload_api.php" //imageshack api website endpoint
                let url = NSURL(string:urlStr)!
                //Alamofire only takes in NSData
                let imgData = UIImageJPEGRepresentation(img, 0.2)! //0.2 is really compressed converted to jpeg
                let keyData = API_Key.dataUsingEncoding(NSUTF8StringEncoding)! //converting string into data
                let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)! //converts json to data , unwraps to eliminate errors
                var imageLink = ""
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
            self.postToFirebase(nil)
        }
        }
    }
    

    func postToFirebase(imgUrl: String?) {
        let User = DataService.ds.REF_USER_CURRENT.childByAppendingPath("Username")
        User.observeEventType(.Value, withBlock: { snapshot in
            let theUser = (snapshot.value)
            let Uid = DataService.ds.REF_USERS
            Uid.observeEventType(.Value, withBlock: { snapshot in
                let theUid = (snapshot.value)
                var post: Dictionary < String, AnyObject >= ["Uid":theUid, "Username": theUser,
                    "description" : self.postField.text!,
                    "likes": 0]
                if imgUrl != nil {
                    post["imageUrl"] = imgUrl!
                }
                
                let firebasePost = DataService.ds.REF_POSTS.childByAutoId() //creates new database entry of autoid
                firebasePost.setValue(post)//set post of new child autoid into firebase
                self.postField.text = ""
                self.imageSelectorImage.image = UIImage(named: "camera 2")
                self.tableView.reloadData()

                }, withCancelBlock: {error in
                    print(error.description)
            })
            
                        }, withCancelBlock: {error in
                print(error.description)
        })
     
        
    }


}