//
//  BlacklistCell.swift
//  shawn-showcase
//
//  Created by Shawn on 4/9/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
class BlacklistCell: UITableViewCell {
    
    @IBOutlet weak var blockedUserImg: UIImageView!
    @IBOutlet weak var blockUserUsername: UILabel!
    var blacklistRef: Firebase!
    var user: User!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        DataService.ds.REF_USER_CURRENT.observeEventType(.Value, withBlock: { snapshot in
            print(snapshot.value) //Prints value of snapshot
            //            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {

            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                let key = snapshot.key
                let user = User(userKey: key, dictionary: userDict)
                self.user = user
                //                let blacklistuser = user.blacklist
//                self.users.append(user)
                self.blacklistRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("blacklist")

            }
        })
    }

//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
    
    
    func configureCell(user:User) {
    }

}
