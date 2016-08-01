//
//  User.swift
//  shawn-showcase
//
//  Created by Shawn on 1/16/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import Foundation
import Firebase

class User {
    private var _username: String!
    private var _userKey: String!
    private var _blacklistUserKey: String!
    private var _userRef: FIRDatabaseReference!
    private var _userblacklistRef: FIRDatabaseReference!
    private var _profileImageUrl: String?
    private var _firstName: String!
    private var _lastName: String!
    private var _email: String!
    private var _blacklist: Dictionary < Int, String >?
    
    var username: String {
        return _username
    }
    
    var firstName: String {
        return _firstName
    }
    
    var lastName: String {
        return _lastName
    }
    
    var email: String {
        return _email
    }
    
    var profileImageUrl: String? {
        return _profileImageUrl
    }
    
    var userKey: String? {
        return _userKey
    }
    
    var blacklistUserKey: String? {
        return _blacklistUserKey
    }


    var blacklist: Dictionary < Int, String >? {
        return _blacklist
    }
    
    init(Username: String, FirstName: String, LastName: String, Email: String, ProfileImage: String, Blacklist: Dictionary < Int, String >) {
        self._username = Username
        self._firstName = FirstName
        self._lastName = LastName
        self._email = Email
        self._profileImageUrl = ProfileImage
        self._blacklist = Blacklist
    }

    
    init(userKey:String, dictionary: Dictionary<String, AnyObject>) {
        self._userKey = userKey
        
        if let profileimgUrl = dictionary["profileUrl"] as? String {
            self._profileImageUrl = profileimgUrl
        }
        
        if let userName = dictionary["username"] as? String {
            self._username = userName
        }
        
        if let firstname = dictionary["First Name"] as? String {
            self._firstName = firstname
        }
        
        if let lastname = dictionary["Last Name"] as? String {
            self._lastName = lastname
        }
        
        if let Email = dictionary["email"] as? String {
            self._email = Email
        }
        
        if let blackList = dictionary["blacklist"] as? Dictionary<Int, String> {
            self._blacklist = blackList
        }
        
        
        self._userRef = DataService.ds.REF_USERS.childByAppendingPath(self._userKey!)
//        self._userblacklistRef = DataService.ds.REF_USERS.childByAppendingPath(self._userKey!).childByAppendingPath(self._blacklistUserKey!)
    }
}