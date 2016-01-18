//
//  Post.swift
//  shawn-showcase
//
//  Created by Shawn on 1/14/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
class Post {
    private var _postDescription: String! //exclamation is required
    private var _imageUrl: String?
    private var _likes: Int!
    private var _username: String!
    private var _postKey: String!
    private var _postRef: Firebase!
    private var _profileImageUrl: String?
    
    var postDescription: String {
        return _postDescription
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var username: String {
        return _username
    }
    
    var profileImageUrl: String? {
        return _profileImageUrl
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(description: String, imageUrl: String?, Username: String, ProfileImageUrl: String?) {
        self._postDescription = description
        self._imageUrl = imageUrl
        self._username = Username
        self._profileImageUrl = ProfileImageUrl
    }
    
    init(postKey:String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        if let profileimgUrl = dictionary["ProfileUrl"] as? String {
            self._profileImageUrl = profileimgUrl
        }
        
        if let userName = dictionary["Username"] as? String {
            self._username = userName
        }
        
        self._postRef = DataService.ds.REF_POSTS.childByAppendingPath(self._postKey!)
        
    
    }
    
    func adjustLikes(addLike: Bool) {
        
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = _likes - 1
        }
        
        _postRef.childByAppendingPath("likes").setValue(_likes)
    }
    
    
    
    
 

    }
    
    


