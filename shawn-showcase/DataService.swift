//
//  DataService.swift
//  shawn-showcase
//
//  Created by Shawn on 1/14/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
let URL_BASE = Database.database().reference()
//"https://shawn-showcase.firebaseio.com/"
let STORAGE_BASE = Storage.storage().reference()
class DataService {
    
    static let ds = DataService() //static variable, one instance in memory so people don't destroy it.
    
    fileprivate var _REF_BASE = URL_BASE //reference to specific Firebase account
    fileprivate var _REF_POSTS = URL_BASE.child("posts")
    fileprivate var _REF_USERS = URL_BASE.child("users")
    fileprivate var _REF_POST_IMAGES = STORAGE_BASE.child("post-pics")
    fileprivate var _REF_PROFILE_IMAGES = STORAGE_BASE.child("profile-pics")
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: DatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: DatabaseReference {
        let uid = UserDefaults.standard.value(forKey: KEY_UID) as! String
        let user = URL_BASE.child("users").child(uid)
        return user
    }
    
    var REF_POST_CURRENT: DatabaseReference {
        let uid = UserDefaults.standard.value(forKey: KEY_UID) as! String
        let user = URL_BASE.child("posts").child(uid)
        return user
    }
    
    var REF_POST_IMAGES: StorageReference {
        return _REF_POST_IMAGES
    }
    
    var REF_PROFILE_IMAGES: StorageReference {
        return _REF_PROFILE_IMAGES
    }
    
    func createFirebaseUser(_ uid: String, user: Dictionary <String, String>) {
//        REF_USERS.child(byAppendingPath: uid).updateChildValues(user) //setValue will save uid for the whole path or creates a new one
        REF_USERS.child(uid).updateChildValues(user)
    }
}
