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
    
    
    @IBAction func presentTopicScanViewController(sender: AnyObject) {
        
        if let navController = navigationController as? NavigationController {
            navController.presentTopicScanViewController()
        }
    }
}
