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

}
