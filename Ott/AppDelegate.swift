//
//  AppDelegate.swift
//  Ott
//
//  Created by Max on 6/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


func introViewController() -> UIViewController {
    
    let storyboard = UIStoryboard(name: "Startup", bundle: nil)
    return storyboard.instantiateViewControllerWithIdentifier("introViewController")
}


func mainViewController() -> UITabBarController {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    return storyboard.instantiateViewControllerWithIdentifier("mainViewController") as! UITabBarController
}




@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var didPresentFirstViewController = false
    
    func presentFirstViewController() {
        
        if didPresentFirstViewController {
            return
        }
        
        if userIsLoggedIn() {
            topmostViewController()?.presentViewController(mainViewController(), animated: true, completion: nil)
        }
        else {
            topmostViewController()?.presentViewController(introViewController(), animated: true, completion: nil)
        }
        
        didPresentFirstViewController = true
     }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        func setupParseBackend() {
            
            // must initialize subclasses of PFObject before initializing parse
            Follow.initialize()
            Post.initialize()
            PrivateUserData.initialize()
            Topic.initialize()
            User.initialize()
            MapSector.initialize()
            
            Parse.enableLocalDatastore()
            
            Parse.setApplicationId("7GY3LkR9Yiz7iAJnfB61NE49om410NzmOKzttKcB",
                clientKey: "7QelBFF4KAOY6QiZtAdgW39MPfS5G0NpcjqZ4sX8")
            PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        }
        
        setupParseBackend()
        CacheManager.sharedInstance.start()
        LocationManager.sharedInstance.start()
        
        UITabBar.appearance().tintColor = UIColor.tint()
        UINavigationBar.appearance().tintColor = UIColor.tint()
        UINavigationBar.appearance().barTintColor = UIColor.navigationBar()
        UIControl.appearance().tintColor = UIColor.tint()
        return true
    }

    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        guard let query = ScanTransformer.sharedInstance.queryForURL(url.absoluteString) else {
            
            topmostViewController()?.presentOKAlert(title: "Ooops", message: "\(url.absoluteString) is not a valid link.")
            return true
        }
        
        presentFirstViewController()
        
        query.findObjectsInBackgroundWithBlock({ (fetchResults, error) -> Void in
            
            if let theObject = fetchResults?.first! {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if let user = theObject as? User {
                        topmostViewController()?.presentUserDetailViewController(withUser: user)
                    }
                    else if let topic = theObject as? Topic {
                        topmostViewController()?.presentTopicDetailViewController(withTopic: topic, exitMethod: .Dismiss)
                    }
                }
            }
            else {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if let error = error {
                        topmostViewController()?.presentOKAlertWithError(error)
                    }
                    else {
                        topmostViewController()?.presentOKAlert(title: "Ooops", message: "Unable to locate a topic or user associated with the code.")
                    }
                }
            }
        })
        
        return true
    }
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
    }

    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        presentFirstViewController()
    }

    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        CacheManager.sharedInstance.stop()
    }

}

