//
//  Globals.swift
//  Ott
//
//  Created by Max on 6/30/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


//MARK: - Vars

class Globals {
    
   static let sharedInstance = Globals()
    

    //MARK: - Login and Sign Up
    
    var handleUsedToLogin = ""
    var nameUsedToLogin = ""
    var phoneNumberUsedToLogin = ""
    
    
    //MARK: - User Defaults
    
    private let lastUpdatedAuthoredTopicsKey = "lastUpdatedAuthoredTopicsKey"
    var lastUpdatedAuthoredTopics: NSDate? {
        
        get {
            if let date = NSUserDefaults.standardUserDefaults().objectForKey(lastUpdatedAuthoredTopicsKey) as? NSDate {
                return date
            }
            return nil
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: lastUpdatedAuthoredTopicsKey)
        }
    }
    
    
    private let lastUpdatedAuthoredPostsKey = "lastUpdatedAuthoredPostsKey"
    var lastUpdatedAuthoredPosts: NSDate? {
        
        get {
            if let date = NSUserDefaults.standardUserDefaults().objectForKey(lastUpdatedAuthoredPostsKey) as? NSDate {
                return date
            }
            return nil
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: lastUpdatedAuthoredPostsKey)
        }
    }
    
    
    private let lastUpdatedFolloweesKey = "lastUpdatedFollowees"
    var lastUpdatedFollowees: NSDate? {
        
        get {
            if let date = NSUserDefaults.standardUserDefaults().objectForKey(lastUpdatedFolloweesKey) as? NSDate {
                return date
            }
            return nil
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: lastUpdatedFolloweesKey)
        }
    }
    
    
    private let lastUpdatedFolloweeTopicsKey = "lastUpdatedFolloweeTopics"
    var lastUpdatedFolloweeTopics: NSDate? {
        
        get {
            if let date = NSUserDefaults.standardUserDefaults().objectForKey(lastUpdatedFolloweeTopicsKey) as? NSDate {
                return date
            }
            return nil
        }
        
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: lastUpdatedFolloweeTopicsKey)
        }
    }
    
    
    private let requestedAccessUserDefaultsKey = "requestedCameraAccess"
    var didRequestCameraAccess: Bool {
        
        get {

            return NSUserDefaults.standardUserDefaults().boolForKey(requestedAccessUserDefaultsKey)
        }
        
        set {
            
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: self.requestedAccessUserDefaultsKey)
        }
    }
    
    
    private let remindersToPostKey = "remindersToPost"
    var remindersToPostToTopic: Int {
        
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey(remindersToPostKey)
        }
        
        set {
            
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: remindersToPostKey)
        }
    }
}




//MARK: - Utilities

func openSettings() {
    
    if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
        UIApplication.sharedApplication().openURL(url)
    }
}


func performOnMainQueueAfterDelay(delay: NSTimeInterval, block: () -> Void) {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), block)
}




//MARK: - Directories

func documentsDirectory() -> String {
    
    do {
        
        let documentURL = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false)
        return documentURL.path!
    }
    catch {
        print("error getting document directory")
        return ""
    }
}


func documentsDirectory(withSubpath subpath: String) -> String? {
    
    do {
        
        let documentURL = try NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: NSSearchPathDomainMask.UserDomainMask, appropriateForURL: nil, create: false)
        return documentURL.path! + subpath
    }
    catch {
        print("error getting document directory")
        return nil
    }
}





