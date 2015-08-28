//
//  MainTabBarController.swift
//  Ott
//
//  Created by Max on 8/28/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        
        super.viewDidLoad()
        updateViewControllers()
        startObservations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    var didInsertLocalTopicsViewController = false
    
    private func updateViewControllers() {
        
        let localTopicsViewControllerIndex = 0
        
        func noPermissionViewController() -> UIViewController {
            
            let storyboard = UIStoryboard(name: "LocationNoPermissionViewController", bundle: nil)
            return storyboard.instantiateViewControllerWithIdentifier("initialViewController")
        }
        
        func localTopicsViewController() -> UIViewController {
            
            let storyboard = UIStoryboard(name: "LocalTopics", bundle: nil)
            return storyboard.instantiateViewControllerWithIdentifier("initialViewController")
        }
        
        if didInsertLocalTopicsViewController {
            viewControllers?.removeAtIndex(localTopicsViewControllerIndex)
        }
        
        let viewController = LocationManager.sharedInstance.permissionGranted ? localTopicsViewController() : noPermissionViewController()
        
        viewControllers?.insert(viewController, atIndex: localTopicsViewControllerIndex)
        didInsertLocalTopicsViewController = true
        
        selectedViewController = viewController
    }
    
    
    //MARK: - Observations
    
    private var didStartObservations = false
    func startObservations() {
        
        if didStartObservations {
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocationPermissionDidChangeNotification:", name: LocationManager.Notifications.PermissionDidChange, object: nil)
        
        didStartObservations = true
    }
    
    
    private func endObservations() {
        
        if didStartObservations == false {
            return
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        didStartObservations = false
    }
    
    
    func handleLocationPermissionDidChangeNotification(notification: NSNotification) {
        
        updateViewControllers()
    }
}
