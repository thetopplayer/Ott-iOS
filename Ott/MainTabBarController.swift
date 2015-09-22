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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        loadViewControllers()
        updateViewControllers()
        startObservations()
    }

    
    enum ViewControllerPositions: Int {
        
        case LocalTopics = 0
        case Trending = 1
        case Following = 2
        case User = 3
    }
    
    
    private lazy var noPermissionViewController: UIViewController = {
        
        let storyboard = UIStoryboard(name: "LocationNoPermissionViewController", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("initialViewController")
        }()
    
    
    private lazy var localTopicsViewController: UIViewController = {
        
        let storyboard = UIStoryboard(name: "LocalTopics", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("initialViewController")
        }()
    
    
    private lazy var trendingViewController: UIViewController = {
        
        let storyboard = UIStoryboard(name: "Trending", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("initialViewController")
        }()
    
    
    private lazy var followingViewController: UIViewController = {
        
        let storyboard = UIStoryboard(name: "Following", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("initialViewController")
        }()
    
    
    private lazy var userSummaryViewController: UIViewController = {
        
        let storyboard = UIStoryboard(name: "UserSummary", bundle: nil)
        return storyboard.instantiateViewControllerWithIdentifier("initialViewController")
        }()
    
    
    
    var didLoadViewControllers = false
    private func loadViewControllers() {
        
        if didLoadViewControllers {
            return
        }
        
        viewControllers = [trendingViewController, followingViewController, userSummaryViewController]
        didLoadViewControllers = true
    }
    
    
    var didInsertLocalTopicsViewController = false
    private func updateViewControllers() {
        
        func updateLocalTopicsVC() {
            
            if didInsertLocalTopicsViewController {
                viewControllers?.removeAtIndex(ViewControllerPositions.LocalTopics.rawValue)
            }
            
            let viewController = LocationManager.sharedInstance.permissionGranted ? localTopicsViewController : noPermissionViewController
            
            viewControllers?.insert(viewController, atIndex: ViewControllerPositions.LocalTopics.rawValue)
            didInsertLocalTopicsViewController = true
        }
        
        updateLocalTopicsVC()
        
        selectedViewController = viewControllers?.first
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
