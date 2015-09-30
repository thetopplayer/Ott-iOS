//
//  NavigationController.swift
//  Ott
//
//  Created by Max on 7/15/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


class SegueToScanViewController: UIStoryboardSegue {
    
    static let identifier = "segueToScan"
    
    init(source: UIViewController) {
        
        let scanViewController: UIViewController = {
            
            let storyboard = UIStoryboard(name: "Scan", bundle: nil)
            return storyboard.instantiateViewControllerWithIdentifier("scanViewController")
        }()

        super.init(identifier: SegueToScanViewController.identifier, source: source, destination: scanViewController)
    }
    
    override func perform() {
        
        sourceViewController.presentViewController(destinationViewController, animated: true, completion: nil)
    }
}


class SegueToExportViewController: UIStoryboardSegue {
    
    static let identifier = "segueToExport"
    
    init(source: UIViewController, object: PFObject) {
        
        let destinationViewController: NavigationController = {
            
            let storyboard = UIStoryboard(name: "Export", bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("exportViewController") as! NavigationController
            
            controller.payload = object
            return controller
            }()
        
        super.init(identifier: SegueToExportViewController.identifier, source: source, destination: destinationViewController)
    }
    
    override func perform() {
        
        sourceViewController.presentViewController(destinationViewController, animated: true, completion: nil)
    }
}




class NavigationController: UINavigationController {
    
    var topic: Topic?
    var post: Post?
    var user: User?
    var payload: PFObject?
    
    
    func presentTopicScanViewController() {
        
        //todo - request camera permission before presenting
        
        let segue = SegueToScanViewController(source: self)
        segue.perform()
    }
    
    
    func presentExportViewController(withTopic theTopic: Topic) {
        
        let segue = SegueToExportViewController(source: self, object: theTopic)
        segue.perform()
    }
    
    
    func presentExportViewController(withUser theUser: User) {
        
        let segue = SegueToExportViewController(source: self, object: theUser)
        segue.perform()
    }
    
    
    
}
