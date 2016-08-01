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
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _flags: Int!
    private var _username: String?
    private var _profileImageUrl: String?
    private var _Uid: String!
        
    var postDescription: String {
        return _postDescription
    }
    
    var imageUrl: String? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var flags: Int {
        return _flags
    }
    
    var username: String? {
        return _username
    }
    
    var profileImageUrl: String? {
        return _profileImageUrl
    }
    
    var postRef: FIRDatabaseReference! {
        return _postRef
    }
    
    var postKey: String {
        return _postKey
    }
    
    var Uid: String! {
        return _Uid
    }

    
    init(description: String, imageUrl: String?) {
        self._postDescription = description
        self._imageUrl = imageUrl
    }
    
    init(postKey:String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        if let likes = dictionary["likes"] as? Int {
            self._likes = likes
        }
        
        if let flags = dictionary["flags"] as? Int {
            self._flags = flags
        }
        
        if let imgUrl = dictionary["imageUrl"] as? String {
            self._imageUrl = imgUrl
        }
        
        if let desc = dictionary["description"] as? String {
            self._postDescription = desc
        }
        
        if let user = dictionary["username"] as? String {
            self._username = user
        }
        
        if let profileimgUrl = dictionary["profileUrl"] as? String {
            self._profileImageUrl = profileimgUrl
        }
        
        if let uid = dictionary["Uid"] as? String {
            self._Uid = uid
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
    
    func adjustFlags(addFlag: Bool) {
        
        if addFlag {
            _flags = _flags + 1
        } else {
            _flags = _flags - 1
        }
        
        _postRef.childByAppendingPath("flags").setValue(_flags)
    }
    



    }
    
    


