//
//  CurrentUserDetailViewController.swift
//  Ott
//
//  Created by Max on 9/30/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class CurrentUserDetailViewController: UserDetailViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        user = currentUser()
    }

    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = false
    }
    
    
    @IBAction func presentTopicCreationAction(sender: AnyObject) {
        
        presentTopicCreationViewController()
    }
    
    
    //MARK: - Observations and Delegate Methods
    
    override func startObservations() {
        
        super.startObservations()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleFollowDidChangeNotification:", name: RemoveFollowOperation.Notifications.DidRemove, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleFollowDidChangeNotification:", name: CreateFollowOperation.Notifications.DidCreate, object: nil)
    }
    
    
    func handleFollowDidChangeNotification(notification: NSNotification) {
        
        updateCurrentlyDisplayedData()
    }
    

}
