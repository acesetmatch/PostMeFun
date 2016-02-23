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

protocol PostCellTableViewCellDelegate{
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
    var likeRef:Firebase!
    var flagRef:Firebase!
    var blockRef: Firebase!
    var user: User!
    var delegate: PostCellTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:") //colon passes tap gesture recognizer. 
        tap.numberOfTapsRequired = 1
        likeImage.addGestureRecognizer(tap)
        likeImage.userInteractionEnabled = true
        
//        let tap1 = UITapGestureRecognizer(target: self, action: "returnTapped:") //colon passes tap gesture recognizer.
//        tap1.numberOfTapsRequired = 1
        
        profileImg.layer.cornerRadius = profileImg.frame.size.width/2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
        
    }
    
    
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(post: Post, img: UIImage?, ProfileImage: UIImage?) {
        self.post = post
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        flagRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("flags").childByAppendingPath(post.postKey)
//        blockRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("blacklist").childByAppendingPath(post.postKey)
        self.descriptionText.text = post.postDescription       //extracts like data from likes and sees if that post exists
        self.likesLbl.text = "\(post.likes)"
//        let usernameRef = DataService.ds.REF_USER_CURRENT
        self.usernameLbl.text = post.username
        //if the imageurl is there then run this code, but if isn't then
        if post.imageUrl != nil {
            if img != nil {
                self.showcaseImg.image = img
            } else {
                //getting an image request then call the response
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                
                    if err == nil
                    {
                        let img = UIImage(data: data!)!
                        self.showcaseImg.image = img
                        FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                    }
                })
            }
        } else {
            self.showcaseImg.hidden = true
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
            self.profileImg.hidden = false
        }
        
  
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in //check value only once
            if let doesNotExist = snapshot.value as? NSNull { //if there is no data in value, you need to check it agaisnt NSNULL. We have not liked this specific post.
                self.likeImage.image = UIImage(named: "heart-empty")
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
        
        flagRef.observeSingleEventOfType(.Value, withBlock: { snapshot in //check value only once
            if let doesNotExist = snapshot.value as? NSNull { //if there is no data in value, you need to check it agaisnt NSNULL. We have not liked this specific post.
                self.post.adjustFlags(true)
                self.flagRef.setValue(true) //creates a like on life ref when set to true
            } else {
                self.post.adjustFlags(false)
                self.flagRef.removeValue() //deletes entire key all together with reference
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
    
    func flagReference(alert: UIAlertAction!) {
        
        flagRef.observeSingleEventOfType(.Value, withBlock: { snapshot in //check value only once
            if let doesNotExist = snapshot.value as? NSNull { //if there is no data in value, you need to check it agaisnt NSNULL. We have not liked this specific post.
                self.post.adjustFlags(true)
                self.flagRef.setValue(true) //creates a like on life ref when set to true
            } else {
                self.post.adjustFlags(false)
                self.flagRef.removeValue() //deletes entire key all together with reference
            }
        })
    }
    
    @IBAction func returnBtn(sender:AnyObject?) {
        self.delegate?.returnTapped()
    }
    
    
    
    
    
//    func returnTapped() {
//        let alertController = UIAlertController(title: "Inappropriate Content", message: "Select an option", preferredStyle: .Alert)
//        let blockUser = UIAlertAction(title: "Block User", style: .Default, handler:nil)
//        let Report = UIAlertAction(title: "Report Inappropriate", style: .Default, handler:nil)
//        alertController.addAction(blockUser)
//        alertController.addAction(Report)
//        self.presentViewController(alertController, animated: true, completion: nil)
//
//        flagRef.observeSingleEventOfType(.Value, withBlock: { snapshot in //check value only once
//            if let doesNotExist = snapshot.value as? NSNull { //if there is no data in value, you need to check it agaisnt NSNULL. We have not liked this specific post.
//                self.post.adjustFlags(true)
//                self.flagRef.setValue(true) //creates a like on life ref when set to true
//            } else {
//                self.post.adjustFlags(false)
//                self.flagRef.removeValue() //deletes entire key all together with reference
//            }
//        })
//        let alertmessage = UIAlertController(title: "Are you sure you want to flag the post?", message: "Pressing ok will flag the post!", preferredStyle: .Alert)
//        let okayAction = UIAlertAction(title: "Ok", style: .Default, handler: markFlagged)
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
//        alertmessage.addAction(okayAction)
//        alertmessage.addAction(cancelAction)
//        presentViewController(alertmessage, animated: true, completion: nil)

    

}
    
    

