//
//  DataService.swift
//  shawn-showcase
//
//  Created by Shawn on 1/14/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = FIRDatabase.database().reference()
//"https://shawn-showcase.firebaseio.com/"

class DataService {
    
    static let ds = DataService() //static variable, one instance in memory so people don't destroy it.
    
    fileprivate var _REF_BASE = URL_BASE //reference to specific Firebase account
    fileprivate var _REF_POSTS = URL_BASE.child("posts")
    fileprivate var _REF_USERS = URL_BASE.child("users")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        let uid = UserDefaults.standard.value(forKey: KEY_UID) as! String
        let user = URL_BASE.child("users").child(uid)
        return user
    }
    
    var REF_POST_CURRENT: FIRDatabaseReference {
        let uid = UserDefaults.standard.value(forKey: KEY_UID) as! String
        let user = URL_BASE.child("posts").child(uid)
        return user
    }
    
    func createFirebaseUser(_ uid: String, user: Dictionary <String, String>) {
        REF_USERS.child(byAppendingPath: uid).updateChildValues(user) //setValue will save uid for the whole path or creates a new one
    }
}
