//
//  UIViewController.swift
//  Ott
//
//  Created by Max on 8/8/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


import UIKit

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
}



func topmostViewController() -> UIViewController? {
    
    return UIApplication.sharedApplication().keyWindow?.rootViewController!.topmostViewController()
}



