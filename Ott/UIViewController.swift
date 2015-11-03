//
//  UIViewController.swift
//  Ott
//
//  Created by Max on 8/8/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


import UIKit


func topmostViewController() -> UIViewController? {
    
    return UIApplication.sharedApplication().keyWindow?.rootViewController!.topmostViewController()
}


typealias AlertPresentionHandler = () -> Void

extension UIViewController {
    
    func topmostViewController() -> UIViewController? {
        
        var controller: UIViewController?
        
        switch self {
            
        case let tabBarController as UITabBarController:
            controller = tabBarController.selectedViewController!.topmostViewController()
            
        case let navigationController as UINavigationController:
            controller = navigationController.visibleViewController!.topmostViewController()
            
        default:
            
            if presentedViewController != nil {
                controller = presentedViewController!.topmostViewController()
            }
            else if self.childViewControllers.count > 0 {
                controller = self.childViewControllers.last
            }
            else {
                controller = self
            }
        }
        
        return controller
    }
    
    
    
    //MARK: - Alerts
    
    func presentOKAlert(title title: String?, message: String?, actionHandler: AlertPresentionHandler? = nil) {
        
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
            action in
            
            if let actionHandler = actionHandler {
                
                dispatch_async(dispatch_get_main_queue()) {
                    actionHandler()
                }           }
        })
        alertViewController.addAction(okAction)
        
        presentViewController(alertViewController, animated: true, completion: nil)
    }
    
    
    func presentOKAlertWithError(error: NSError, messagePreamble: String? = nil, actionHandler: AlertPresentionHandler? = nil) {
        
        let title = "Error"
        
        var message: String
        if let messagePreamble = messagePreamble {
            message = messagePreamble + "  " + error.localizedDescription
        }
        else {
            message = error.localizedDescription
        }
        
        presentOKAlert(title: title, message: message, actionHandler: actionHandler)
    }    

    
    
    //MARK: - Navigation
    
    func presentViewController(storyboard storyboard: String, identifier: String, completion: (() -> Void)?) -> UIViewController {
        
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(identifier) as! NavigationController
        presentViewController(vc, animated: true, completion: completion)
        
        return vc
    }
    
    
    func presentViewController(storyboard storyboard: String, identifier: String, topic: Topic?, completion: (() -> Void)?) -> UIViewController {
        
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
    
    
    func presentTopicDetailViewController(withTopic topic: Topic?, exitMethod: TopicDetailViewController.ExitMethod = .Back) {
        
        let detailViewController: UIViewController = {
            
            var controller: UIViewController
            
            if exitMethod == .Back {
                
                // if one is already on the stack, use it
                var detailController: TopicDetailViewController? = nil
                for vc in navigationController!.viewControllers {
                    if vc is TopicDetailViewController {
                        detailController = vc as? TopicDetailViewController
                    }
                }
                
                if detailController == nil {
                    
                    let storyboard = UIStoryboard(name: "TopicDetail", bundle: nil)
                    detailController = storyboard.instantiateViewControllerWithIdentifier("topicDetailViewController") as? TopicDetailViewController
                }
                
                detailController!.topic = topic
                detailController!.exitMethod = .Back
                controller = detailController!
            }
            else {
                
                let storyboard = UIStoryboard(name: "TopicDetail", bundle: nil)
                let navController: NavigationController = (storyboard.instantiateViewControllerWithIdentifier("initialViewController") as? NavigationController)!
                
                navController.topic = topic                
                controller = navController
            }
            
            return controller
            }()
        
        
        func presentController() {
            
            if exitMethod == .Back {
                navigationController!.pushViewController(detailViewController, animated: true)
            }
            else {
                presentViewController(detailViewController, animated: true, completion: nil)
            }
        }
        
        if LocationManager.sharedInstance.permissionGranted {
            presentController()
        }
        else {
            LocationManager.sharedInstance.requestPermission({ (granted) -> Void in
                if granted {
                    presentController()
                }
            })
        }
    }
    
    
    // this is always presented modally
    private func presentUserDetailViewController(withObject object: PFObject?) {
        
        guard serverIsReachable() else {
            
            presentOKAlert(title: "Offline", message: "Unable to reach server.  Please make sure you have WiFi or a cell signal and try again.", actionHandler: { () -> Void in
            })
            return
        }
        
        let detailViewController: NavigationController = {
            
            let storyboard = UIStoryboard(name: "UserDetail", bundle: nil)
            let theController = storyboard.instantiateViewControllerWithIdentifier("initialViewController") as?NavigationController
            
            return theController!
            }()
        
        if let user = object as? User {
            detailViewController.user = user
        }
        else if let topic = object as? Topic {
            detailViewController.topic = topic
        }
        else if let post = object as? Post {
            detailViewController.post = post
        }
        else {
            assert(false)
        }
        
        presentViewController(detailViewController, animated: true, completion: nil)
    }
    
    
    func presentUserDetailViewController(withUser user: User?) {
        
        presentUserDetailViewController(withObject: user)
    }
    
    
    func presentUserDetailViewController(withTopic topic: Topic?) {
        
        presentUserDetailViewController(withObject: topic)
    }
    
    
    func presentUserDetailViewController(withPost post: Post?) {
        
        presentUserDetailViewController(withObject: post)
    }
    
    
    private func pushUserDetailViewController(withObject object: PFObject?) {
        
        guard serverIsReachable() else {
            
            presentOKAlert(title: "Offline", message: "Unable to reach server.  Please make sure you have WiFi or a cell signal and try again.", actionHandler: { () -> Void in
            })
            return
        }
        
        let detailViewController: UserDetailViewController = {
            
            // if one is already on the stack, use it
            var theController: UserDetailViewController? = nil
            for vc in navigationController!.viewControllers {
                if vc is UserDetailViewController {
                    theController = vc as? UserDetailViewController
                }
            }
            
            if let theController = theController {
                return theController
            }
            
            // else instantiate it
            let storyboard = UIStoryboard(name: "UserDetail", bundle: nil)
            theController = storyboard.instantiateViewControllerWithIdentifier("userDetailViewController") as?UserDetailViewController
            
            return theController!
            }()
        
        detailViewController.exitMethod = .Back
        
        if let user = object as? User {
            detailViewController.user = user
        }
        else if let topic = object as? Topic {
            detailViewController.fetchUserFromTopic(topic)
        }
        
        navigationController!.pushViewController(detailViewController, animated: true)
    }
    
    func pushUserDetailViewController(withUser user: User?) {
        
        pushUserDetailViewController(withObject: user)
    }
    
    
    func pushUserDetailViewController(withTopic topic: Topic?) {
        
        pushUserDetailViewController(withObject: topic)
    }
}
