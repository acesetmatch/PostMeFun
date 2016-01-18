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

class PostCellTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    
    var post: Post! //store post
    var request: Request? //Request is Firebase object
    var request2: Request?
    var likeRef:Firebase!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:") //colon passes tap gesture recognizer. 
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
        
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(post: Post, img: UIImage?, ProfileImage: UIImage?, username:String) {
        self.post = post
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        self.descriptionText.text = post.postDescription       //extracts like data from likes and sees if that post exists
        self.likesLbl.text = "\(post.likes)"
        self.usernameLbl.text = post.username
        if post.imageUrl != nil {
            if img != nil {
                self.showcaseImg.image = img
            } else {
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                
                    if err == nil {
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    }
                })
            }
        } else {
            self.showcaseImg.hidden = false
        }
        
        if post.profileImageUrl != nil {
            if ProfileImage != nil {
                self.profileImg.image = ProfileImage
            } else {
                request2 = Alamofire.request(.GET, post.profileImageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    
                    if err == nil {
                        if let ProfileImage = UIImage(data: data!) {
                        self.profileImg.image = ProfileImage
                        FeedVC.imageCache.setObject(ProfileImage, forKey: self.post.profileImageUrl!)
                        }
                    }
                })
            }
        } else {
            self.profileImg.hidden = false
        }
     

        
  
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in //check value only once
            if let doesNotExist = snapshot.value as? NSNull { //if there is no data in value, you need to check it agaisnt NSNULL. We have not liked this specific post. 
                self.likeImage.image = UIImage(named: "heart-empty")
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
        
        
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in //check value only once
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
