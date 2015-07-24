//
//  NavigationController.swift
//  Ott
//
//  Created by Max on 7/15/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    
    var topic: TopicObject?
    var post: PostObject?
    var author: AuthorObject?
    
    
    static func loginViewController() -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("loginViewController") as! NavigationController
    }
    
    
    static func mainViewController() -> UIViewController {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("loginViewController") as! NavigationController
    }
    
    
    
    
    func presentViewController(storyboard storyboard: String, identifier: String, completion: (() -> Void)?) -> UIViewController {
        
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(identifier) as! NavigationController
        presentViewController(vc, animated: true, completion: completion)
        
        return vc
    }
    
    
    func presentViewController(storyboard storyboard: String, identifier: String, topic: TopicObject?, completion: (() -> Void)?) -> UIViewController {
        
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(identifier) as! NavigationController
        vc.topic = topic
        presentViewController(vc, animated: true, completion: completion)
        
        return vc
    }
    
    
    func presentTopicCreationViewController() {
        
        if LocationManager.sharedInstance.permissionGranted {
            presentViewController(storyboard: "TopicCreation", identifier: "topicCreationViewController", completion: nil)
        }
        else {
            LocationManager.sharedInstance.requestPermission({ (granted) -> Void in
                if granted {
                    self.presentViewController(storyboard: "TopicCreation", identifier: "topicCreationViewController", completion: nil)
                }
            })
        }
    }
    
    
    func presentTopicScanViewController() {
        
        //todo - request camera permission before presenting
        
        presentViewController(storyboard: "TopicScan", identifier: "topicScanViewController", completion: nil)
    }
    
    
    func presentTopicDetailViewController(withTopic topic: TopicObject?) {
        
        if LocationManager.sharedInstance.permissionGranted {
            presentViewController(storyboard: "TopicDetail", identifier: "topicDetailViewController", topic: topic, completion: nil)
        }
        else {
            LocationManager.sharedInstance.requestPermission({ (granted) -> Void in
                if granted {
                    self.presentViewController(storyboard: "TopicDetail", identifier: "topicDetailViewController", topic: topic, completion: nil)
                }
            })
        }
    }
}
