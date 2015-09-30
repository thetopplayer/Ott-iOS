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
    
    
    func presentOKAlert(title title: String?, message: String?, actionHandler: AlertPresentionHandler?) {
        
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
            action in
            dispatch_async(dispatch_get_main_queue()) {
                actionHandler?()
            }})
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
        
        let detailViewController: TopicDetailViewController = {
            
            var theController: TopicDetailViewController? = nil
            for vc in navigationController!.viewControllers {
                if vc is TopicDetailViewController {
                    theController = vc as? TopicDetailViewController
                }
            }
            
            if let theController = theController {
                return theController
            }
            
            let storyboard = UIStoryboard(name: "TopicDetail", bundle: nil)
            theController = storyboard.instantiateViewControllerWithIdentifier("topicDetailViewController") as? TopicDetailViewController
            
            return theController!
            }()
        
        func presentController() {
            
            detailViewController.exitMethod = exitMethod
            detailViewController.topic = topic
            navigationController!.pushViewController(detailViewController, animated: true)
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
    
    
    func presentUserDetailViewController(withUser user: User?, exitMethod: UserDetailViewController.ExitMethod = .Back) {
        
        let detailViewController: UserDetailViewController = {
            
            var theController: UserDetailViewController? = nil
            for vc in navigationController!.viewControllers {
                if vc is UserDetailViewController {
                    theController = vc as? UserDetailViewController
                }
            }
            
            if let theController = theController {
                return theController
            }
            
            let storyboard = UIStoryboard(name: "UserDetail", bundle: nil)
            theController = storyboard.instantiateViewControllerWithIdentifier("userDetailViewController") as?UserDetailViewController
            
            return theController!
            }()
        
        func presentController() {
            
            detailViewController.exitMethod = exitMethod
            detailViewController.user = user
            navigationController!.pushViewController(detailViewController, animated: true)
        }
        
        presentController()
    }
    
    
    func presentUserDetailViewController(withTopic topic: Topic?, exitMethod: UserDetailViewController.ExitMethod = .Back) {
        
        let detailViewController: UserDetailViewController = {
            
            var theController: UserDetailViewController? = nil
            for vc in navigationController!.viewControllers {
                if vc is UserDetailViewController {
                    theController = vc as? UserDetailViewController
                }
            }
            
            if let theController = theController {
                return theController
            }
            
            let storyboard = UIStoryboard(name: "UserDetail", bundle: nil)
            theController = storyboard.instantiateViewControllerWithIdentifier("userDetailViewController") as?UserDetailViewController
            
            return theController!
            }()
        
        func presentController() {
            
            detailViewController.exitMethod = exitMethod
            detailViewController.fetchUserFromTopic(topic!)
            navigationController!.pushViewController(detailViewController, animated: true)
        }
        
        presentController()
    }

}
