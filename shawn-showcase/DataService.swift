//
//  DataService.swift
//  shawn-showcase
//
//  Created by Shawn on 1/14/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "https://shawn-showcase.firebaseio.com/"

class DataService {
    
    static let ds = DataService() //static variable, one instance in memory so people don't destroy it.
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)") //reference to specific Firebase account
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_POSTS: Firebase {
        return _REF_POSTS
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        return user!
    }
    
    var REF_POST_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("posts").childByAppendingPath(uid)
        return user
    }
    
    func createFirebaseUser(uid: String, user: Dictionary <String, String>) {
        REF_USERS.childByAppendingPath(uid).setValue(user) //setValue will save uid for the whole path or creates a new one
    }
}