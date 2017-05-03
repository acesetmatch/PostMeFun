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
import NVActivityIndicatorView
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
        //self.activityIndicatorView.startAnimating()
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
        
        //if let img = img, let ProfileImage = ProfileImage {
        downloadFromFirebaseStorage(imageUrl: post.imageUrl, outletImgView: self.showcaseImg, img: img)
        downloadFromFirebaseStorage(imageUrl: post.profileImageUrl, outletImgView: self.profileImg, img: ProfileImage)
        //}
        //self.activityIndicatorView.stopAnimating()
        
        likeRef.observeSingleEvent(of: .value, with: { snapshot in //check value only once
            if (snapshot.value as? NSNull) != nil { //if there is no data in value, you need to check it agaisnt NSNULL. We have not liked this specific post.
                self.likeImage.image = UIImage(named: "heart-empty")
            } else {
                self.likeImage.image = UIImage(named: "heart-full")
            }
        })
    }
    
    // Downloading images from Firebase Storage.
    func downloadFromFirebaseStorage(imageUrl: String?, outletImgView: UIImageView, img: UIImage?) {
        //if imageUrl != nil {
            if img != nil {
                outletImgView.image = img
            } else {
                //getting an image request then call the response
                if let imageURL = imageUrl {
                    let ref = FIRStorage.storage().reference(forURL: imageURL)
                    ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            print("unable to download image from Firebase Storage")
                        } else {
                            print("image downloaded")
                            if let imgData = data {
                                if let img = UIImage(data: imgData) {
                                    outletImgView.image = img
                                    FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl as AnyObject)
                                }
                            }
                        }
                    })
                }
            }
        /*
        } else {
            outletImgView.isHidden = true
        }
 */
    }
    
    func likeTapped(_ sender: UITapGestureRecognizer) {
        likeRef.observeSingleEvent(of: .value, with: { snapshot in //check value only once
            if (snapshot.value as? NSNull) != nil { //if there is no data in value, you need to check it agaisnt NSNULL. We have not liked this specific post.
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
    
    

