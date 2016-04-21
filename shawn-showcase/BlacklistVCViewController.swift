//
//  BlacklistVCViewController.swift
//  shawn-showcase
//
//  Created by Shawn on 4/9/16.
//  Copyright © 2016 Shawn. All rights reserved.
//

import UIKit

class BlacklistVCViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var blockedUser = [User]() //Fix this so it is only the blacklist Username
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("BlacklistCell") as? BlacklistCell {
            cell.configureCell(<#T##user: User##User#>)
        }
            
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 87.0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedUser.count
    }
    

   

}
