//
//  PostCellTableViewCell.swift
//  shawn-showcase
//
//  Created by Shawn on 1/14/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import FirebaseStorage

protocol PostCellTableViewDelegate {
    func returnTapped()
}

class PostCellTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var returnImage: UIImageView!
    @IBOutlet weak var returnButton: UIButton!
    
    var post: Post! //store post
    var request: Request? //Request is Firebase object
    var request2: Request?
    var likeRef:FIRDatabaseReference!
    var flagRef:FIRDatabaseReference!
    var blockRef: FIRDatabaseReference!
    var user: User!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostCellTableViewCell.likeTapped(_:))) //colon passes tap gesture recognizer.
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.isUserInteractionEnabled = true
        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        profileImg.clipsToBounds = true
        showcaseImg.clipsToBounds = true
        showcaseImg.layer.cornerRadius = 10.0
        returnButton.imageView?.contentMode = UIViewContentMode.scaleAspectFit
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ post: Post, img: UIImage?, ProfileImage: UIImage?) {
        self.post = post
        likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        flagRef = DataService.ds.REF_USER_CURRENT.child("flags").child(post.postKey)
        self.descriptionText.text = post.postDescription       //extracts like data from likes and sees if that post exists
        self.likesLbl.text = "\(post.likes)"
        self.usernameLbl.text = post.username
        if post.imageUrl != nil {
            if img != nil {
                self.showcaseImg.image = img
            } else {
                //getting an image request then call the response
                if let imageURL = post.imageUrl {
                    let ref = FIRStorage.storage().reference(forURL: imageURL)
                    ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            print("unable to download image from Firebase Storage")
                        } else {
                            print("image downloaded")
                            if let imgData = data {
                                if let img = UIImage(data: imgData) {
                                    self.showcaseImg.image = img
                                    FeedVC.imageCache.setObject(img, forKey: post.imageUrl as AnyObject)
                                }
                            }
                        }
                    })
                }
                
//                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
//                
//                    if err == nil
//                    {
//                        let img = UIImage(data: data!)!
//                        self.showcaseImg.image = img
//                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
//                    }
//                })
            }
        } else {
            self.showcaseImg.isHidden = true
        }
        
        if post.profileImageUrl != nil {
            if ProfileImage != nil {
                self.profileImg.image = ProfileImage
            } else {
                request = Alamofire.request(.GET, post.profileImageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        if let ProfileImage = UIImage(data: data!) {
                            self.profileImg.image = ProfileImage
                            FeedVC.imageCache.setObject(ProfileImage, forKey: self.post.profileImageUrl!)
                        }
                    }
                })
            }
    
        } else {
            self.profileImg.isHidden = false
        }
        
  
        likeRef.observeSingleEvent(of: .value, with: { snapshot in //check value only once
            if let doesNotExist = snapshot.value as? NSNull { //if there is no data in value, you need to check it agaisnt NSNULL. We have not liked this specific post.
                self.likeImage.image = UIImage(named: "heart-empty")
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
    }
    
    func downloadFromFirebaseStorage() {
        
    }
    
    func likeTapped(_ sender: UITapGestureRecognizer) {
        likeRef.observeSingleEvent(of: .value, with: { snapshot in //check value only once
            if let doesNotExist = snapshot.value as? NSNull { //if there is no data in value, you need to check it agaisnt NSNULL. We have not liked this specific post.
                self.likeImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true) //creates a like on life ref when set to true
            } else {
                self.likeImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue() //deletes entire key all together with reference
            }
        })
    }
    

    


}
    
    

