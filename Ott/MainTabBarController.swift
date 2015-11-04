//
//  MainTabBarController.swift
//  Ott
//
//  Created by Max on 8/28/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    static var activeController: MainTabBarController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        MainTabBarController.activeController = self
    }
    
    
    enum ViewControllerPositions: Int {
        
        case Scan = 0
        case LocalTopics = 1
        case Following = 2
        case Search = 3
        case User = 4
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadViewControllers()
        updateViewControllers()
        
        // don't start with scan
        selectedViewController = viewControllers?[ViewControllerPositions.LocalTopics.rawValue]
        
        startObservations()
    }

    
    private let noPermissionViewController: UIViewController = {
        
        let storyboard = UIStoryboard(name: "LocationNoPermissionViewController", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("initialViewController")
        }()
    
    
    private let scanViewController: UIViewController = {
        
        let storyboard = UIStoryboard(name: "Scan", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("scanViewController")
        }()
    
    
    private let localTopicsViewController: UIViewController = {
        
        let storyboard = UIStoryboard(name: "LocalTopics", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("initialViewController")
        }()
    
    
    private let searchViewController: UIViewController = {
        
        let storyboard = UIStoryboard(name: "Search", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("initialViewController")
        }()
    
    
    private let followingViewController: UIViewController = {
        
        let storyboard = UIStoryboard(name: "Following", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("initialViewController")
        }()
    
    
    private let userSummaryViewController: UIViewController = {
        
        let storyboard = UIStoryboard(name: "User", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("initialViewController")
        }()
    
    
    var didLoadViewControllers = false
    private func loadViewControllers() {
        
        if didLoadViewControllers {
            return
        }
        
        viewControllers = [scanViewController, localTopicsViewController, followingViewController, searchViewController, userSummaryViewController]
        didLoadViewControllers = true
    }
    
    
    /*
    test for location permission to display local topics
    TODO:  test for camera access permission to display scan
    */
    private func updateViewControllers() {
        
        // scan
        
        if ScanViewController.cameraAccessGranted() {
            
        }
        else {
            
        }
        
        
        
        
        // location
        
        if LocationManager.sharedInstance.permissionGranted {
            
            if viewControllers!.contains(localTopicsViewController) {
                return
            }
        }
        else {
            
            if viewControllers!.contains(noPermissionViewController) {
                return
            }
        }
        
        viewControllers!.removeAtIndex(ViewControllerPositions.LocalTopics.rawValue)
        
        let viewController = LocationManager.sharedInstance.permissionGranted ? localTopicsViewController : noPermissionViewController
        viewControllers!.insert(viewController, atIndex: ViewControllerPositions.LocalTopics.rawValue)
        
        
        
    }
    
    
    
    //MARK: - Observations
    
    func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocationPermissionDidChangeNotification:", name: LocationManager.Notifications.PermissionDidChange, object: nil)
    }
    
    
    private func endObservations() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func handleLocationPermissionDidChangeNotification(notification: NSNotification) {
        
        updateViewControllers()
    }
}
